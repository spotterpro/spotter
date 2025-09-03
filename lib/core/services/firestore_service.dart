import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:spotter/core/models/user_model.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =========================
  // 유저
  // =========================

  Future<UserProfile?> getUserProfile(String uid) async {
    if (uid.isEmpty) return null;
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromDocument(doc);
      }
      return null;
    } catch (e) {
      debugPrint("Error getting user profile: $e");
      return null;
    }
  }

  Future<void> incrementUserXp(String userId, int amount) async {
    if (userId.isEmpty) return;
    final userRef = _db.collection('users').doc(userId);
    await userRef.update({'xp': FieldValue.increment(amount)});
  }

  // =========================
  // 게시물
  // =========================

  Future<String?> _uploadImage(File imageFile, String postId) async {
    try {
      final fileName = '${const Uuid().v4()}.jpg';
      final storagePath = 'post_photos/$postId/$fileName';
      final storageRef = FirebaseStorage.instance.ref().child(storagePath);
      final uploadTask = await storageRef.putFile(imageFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint("🚨 Storage 업로드 실패: $e");
      return null;
    }
  }

  Future<void> createPostWithImage({
    required String collectionPath,
    required String title,
    required String content,
    File? imageFile,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    final newPostRef = _db.collection(collectionPath).doc();
    final postId = newPostRef.id;

    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await _uploadImage(imageFile, postId);
      if (imageUrl == null) {
        throw Exception('Image upload failed.');
      }
    }

    final postData = {
      'id': postId,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.now(),
      'likeCount': 0,
      'commentCount': 0,
      'authorUid': user.uid,
      'author': {
        'uid': user.uid,
        'displayName': user.displayName ?? '이름없음',
        'photoURL': user.photoURL,
      },
    };

    await newPostRef.set(postData);
  }

  Future<void> deletePost(String collectionPath, String postId) async {
    if (collectionPath.isEmpty || postId.isEmpty) return;
    try {
      await _db.collection(collectionPath).doc(postId).delete();
    } catch (e) {
      debugPrint("[$collectionPath] 문서 삭제 오류: $e");
      rethrow;
    }
  }

  Future<void> updatePost(String collectionPath, String postId, String newCaption, List<String> newTags) async {
    if (collectionPath.isEmpty || postId.isEmpty) return;
    try {
      await _db.collection(collectionPath).doc(postId).update({
        'caption': newCaption,
        'tags': newTags,
      });
    } catch (e) {
      debugPrint("[$collectionPath] 문서 수정 오류: $e");
      rethrow;
    }
  }

  // =========================
  // 가게 + 연쇄 삭제 (Scalability 강화)
  // =========================

  Future<void> deleteStoreAndSubcollections(String storeId) async {
    debugPrint("--- [FirestoreService] 가게 연쇄 삭제 시작: $storeId ---");
    if (storeId.isEmpty) return;

    final storeRef = _db.collection('stores').doc(storeId);
    final collections = ['rewards', 'regulars', 'nfc_tags', 'community_posts', 'owner_posts'];

    for (final col in collections) {
      final subRef = storeRef.collection(col);
      await _deleteCollectionInBatches(subRef);
    }

    debugPrint("[$storeId] 본체 문서 삭제");
    await storeRef.delete();
    debugPrint("--- [FirestoreService] 가게 연쇄 삭제 완료: $storeId ---");
  }

  Future<void> _deleteCollectionInBatches(CollectionReference collection) async {
    QuerySnapshot querySnapshot = await collection.limit(400).get();
    while (querySnapshot.docs.isNotEmpty) {
      final batch = _db.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      debugPrint("[Soptter] ${collection.path} 문서 ${querySnapshot.docs.length}개 배치 삭제 완료.");
      querySnapshot = await collection.limit(400).get();
    }
  }

  // =========================
  // 포스트 좋아요 (리팩토링됨)
  // =========================

  Future<void> togglePostLike({
    required String collectionPath,
    required String postId,
    required String userId,
  }) async {
    if (collectionPath.isEmpty || postId.isEmpty || userId.isEmpty) return;
    final postRef = _db.collection(collectionPath).doc(postId);
    final likeDocRef = postRef.collection('likes').doc(userId);
    return _db.runTransaction((tx) async {
      final likeDoc = await tx.get(likeDocRef);
      if (likeDoc.exists) {
        tx.delete(likeDocRef);
        tx.update(postRef, {'likeCount': FieldValue.increment(-1)});
      } else {
        tx.set(likeDocRef, {'likedAt': FieldValue.serverTimestamp()});
        tx.update(postRef, {'likeCount': FieldValue.increment(1)});
      }
    });
  }

  Stream<bool> isPostLikedByUser({
    required String collectionPath,
    required String postId,
    required String userId,
  }) {
    if (collectionPath.isEmpty || postId.isEmpty || userId.isEmpty) return Stream.value(false);
    return _db.collection(collectionPath).doc(postId).collection('likes').doc(userId).snapshots().map((s) => s.exists);
  }

  Stream<int> getPostLikeCount({
    required String collectionPath,
    required String postId,
  }) {
    if (collectionPath.isEmpty || postId.isEmpty) return Stream.value(0);
    return _db.collection(collectionPath).doc(postId).snapshots().map((s) => (s.data()?['likeCount'] as int?) ?? 0);
  }

  // =========================
  // 댓글/대댓글 (리팩토링됨)
  // =========================

  Stream<QuerySnapshot> getComments({
    required String collectionPath,
    required String postId,
  }) {
    if (collectionPath.isEmpty || postId.isEmpty) return const Stream.empty();
    return _db.collection(collectionPath).doc(postId).collection('comments').orderBy('createdAt', descending: false).snapshots();
  }

  Stream<QuerySnapshot> getReplies({
    required String collectionPath,
    required String postId,
    required String commentId,
  }) {
    if (collectionPath.isEmpty || postId.isEmpty || commentId.isEmpty) return const Stream.empty();
    return _db.collection(collectionPath).doc(postId).collection('comments').doc(commentId).collection('replies').orderBy('createdAt', descending: false).snapshots();
  }

  Stream<int> getCommentsAndRepliesCount({
    required String collectionPath,
    required String postId,
  }) {
    if (collectionPath.isEmpty || postId.isEmpty) return Stream.value(0);
    return _db.collection(collectionPath).doc(postId).snapshots().map((s) => (s.data()?['commentCount'] as int?) ?? 0);
  }

  Future<void> addComment({
    required String collectionPath,
    required String postId,
    required String text,
    required Map<String, dynamic> author,
  }) async {
    if (collectionPath.isEmpty || postId.isEmpty || text.isEmpty) return;
    final postRef = _db.collection(collectionPath).doc(postId);
    final newRef = postRef.collection('comments').doc();
    final uid = (author['uid'] as String?) ?? '';
    final batch = _db.batch();
    batch.set(newRef, { 'text': text, 'author': author, 'authorUid': uid, 'createdAt': FieldValue.serverTimestamp(), 'isDeleted': false, });
    batch.update(postRef, {'commentCount': FieldValue.increment(1)});
    await batch.commit();
  }

  Future<void> addReply({
    required String collectionPath,
    required String postId,
    required String commentId,
    required String text,
    required Map<String, dynamic> author,
  }) async {
    if (collectionPath.isEmpty || postId.isEmpty || commentId.isEmpty || text.isEmpty) return;
    final postRef = _db.collection(collectionPath).doc(postId);
    final newRef = postRef.collection('comments').doc(commentId).collection('replies').doc();
    final uid = (author['uid'] as String?) ?? '';
    final batch = _db.batch();
    batch.set(newRef, { 'text': text, 'author': author, 'authorUid': uid, 'createdAt': FieldValue.serverTimestamp(), });
    batch.update(postRef, {'commentCount': FieldValue.increment(1)});
    await batch.commit();
  }

  Future<void> updateComment(DocumentReference docRef, String newText) async {
    await docRef.update({'text': newText});
  }

  Future<void> deleteCommentOrReply(DocumentReference docRef) async {
    final currentUid = _currentUid;
    await _deleteCommentOrReplyLogic(docRef, currentUid: currentUid);
  }

  Future<void> _deleteCommentOrReplyLogic(DocumentReference docRef, {required String currentUid}) async {
    final docSnap = await docRef.get();
    if (!docSnap.exists) { debugPrint("[Soptter] 삭제할 문서가 존재하지 않습니다: ${docRef.path}"); return; }
    final docData = docSnap.data() as Map<String, dynamic>;
    if (_extractAuthorUid(docData) != currentUid) { throw FirebaseException(plugin: 'Firestore', code: 'permission-denied', message: '자신이 작성한 글만 삭제할 수 있습니다.',); }
    final isReply = docRef.path.contains('/replies/');
    final postRef = isReply ? docRef.parent.parent!.parent.parent! : docRef.parent.parent!;
    if (isReply) {
      final batch = _db.batch();
      batch.delete(docRef);
      batch.update(postRef, {'commentCount': FieldValue.increment(-1)});
      await batch.commit();
      debugPrint("[Soptter] 대댓글 삭제 완료: ${docRef.id}");
      return;
    }
    final commentRef = docRef;
    final repliesCol = commentRef.collection('replies');
    final repliesSnap = await repliesCol.get();
    bool hasRepliesFromOthers = false;
    final List<DocumentReference> ownRepliesRefs = [];
    if (repliesSnap.docs.isNotEmpty) {
      for (final replyDoc in repliesSnap.docs) {
        final replyData = replyDoc.data();
        if (_extractAuthorUid(replyData) == currentUid) { ownRepliesRefs.add(replyDoc.reference); } else { hasRepliesFromOthers = true; }
      }
    }
    if (hasRepliesFromOthers) {
      await commentRef.update({ 'isDeleted': true, 'text': '삭제된 댓글입니다.', 'author': {}, 'authorUid': '', 'deletedAt': FieldValue.serverTimestamp(), 'deletedBy': currentUid, });
      debugPrint("[Soptter] 댓글 Soft-Delete 완료 (타인 대댓글 존재): ${commentRef.id}");
    } else {
      final totalToDelete = 1 + ownRepliesRefs.length;
      const chunkSize = 400;
      final allRefsToDelete = [commentRef, ...ownRepliesRefs];
      for (var i = 0; i < allRefsToDelete.length; i += chunkSize) {
        final slice = allRefsToDelete.skip(i).take(chunkSize);
        final batch = _db.batch();
        for (final ref in slice) { batch.delete(ref); }
        await batch.commit();
        debugPrint("[Soptter] Hard-Delete 배치 실행 (${i + 1}/${allRefsToDelete.length})");
      }
      await postRef.update({'commentCount': FieldValue.increment(-totalToDelete)});
      debugPrint("[Soptter] 댓글 Hard-Delete 및 카운트 차감 완료: ${commentRef.id}");
    }
  }

  // =========================
  // 투표
  // =========================

  Future<void> voteOnPoll({
    required String collectionPath,
    required String postId,
    required int optionIndex,
    required String userId,
  }) async {
    if (collectionPath.isEmpty || postId.isEmpty || userId.isEmpty) return;
    final postRef = _db.collection(collectionPath).doc(postId);
    return _db.runTransaction((tx) async {
      final snap = await tx.get(postRef);
      if (!snap.exists) { throw Exception("Post does not exist!"); }
      final data = snap.data() as Map<String, dynamic>;
      final poll = data['poll'] as Map<String, dynamic>?;
      if (poll == null) return;
      final options = List<Map<String, dynamic>>.from(poll['options'] ?? <Map<String, dynamic>>[]);
      for (final o in options) {
        final votes = (o['votes'] as List?) ?? <dynamic>[];
        votes.remove(userId);
        o['votes'] = votes;
      }
      if (optionIndex >= 0 && optionIndex < options.length) {
        final votes = (options[optionIndex]['votes'] as List?) ?? <dynamic>[];
        if (!votes.contains(userId)) votes.add(userId);
        options[optionIndex]['votes'] = votes;
      }
      tx.update(postRef, {'poll.options': options});
    });
  }

  // =========================
  // 유틸
  // =========================

  String? _extractAuthorUid(Map<String, dynamic> data) {
    final a1 = data['authorUid'];
    if (a1 is String && a1.isNotEmpty) return a1;
    final author = data['author'];
    if (author is Map) {
      final a2 = author['uid'];
      if (a2 is String && a2.isNotEmpty) return a2;
    }
    return null;
  }

  String get _currentUid {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw Exception('User is not authenticated.');
    }
    return uid;
  }
}