// 📁 lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 가게와 그 아래 모든 하위 컬렉션(rewards, regulars 등)을 한번에 삭제합니다.
  Future<void> deleteStoreAndSubcollections(String storeId) async {
    debugPrint("--- [FirestoreService] 가게 연쇄 삭제 작업 시작: $storeId ---");
    try {
      final storeRef = _db.collection('stores').doc(storeId);
      final collectionsToDelete = [
        'rewards', 'regulars', 'nfc_tags', 'community_posts', 'owner_posts'
      ];
      for (final collectionName in collectionsToDelete) {
        debugPrint("[$storeId] >> 하위 컬렉션 '$collectionName' 확인 중...");
        final subcollectionRef = storeRef.collection(collectionName);
        final snapshot = await subcollectionRef.get();
        if (snapshot.docs.isEmpty) {
          debugPrint("[$storeId] -- '$collectionName'에 문서가 없어 넘어갑니다.");
          continue;
        }
        debugPrint("[$storeId] -- '$collectionName'에서 ${snapshot.docs.length}개의 문서를 발견. 삭제를 시작합니다.");
        final batch = _db.batch();
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        debugPrint("[$storeId] -- '$collectionName'의 모든 문서 삭제 완료.");
      }
      debugPrint("[$storeId] >> 모든 하위 컬렉션 청소 완료. 가게 본체를 삭제합니다.");
      await storeRef.delete();
      debugPrint("--- [FirestoreService] 가게 연쇄 삭제 작업 성공: $storeId ---");
    } catch (e) {
      debugPrint("--- [FirestoreService] 가게 연쇄 삭제 중 심각한 오류 발생: $e ---");
      rethrow;
    }
  }

  Future<void> togglePostLike(String postId, String userId) async {
    final postRef = _db.collection('posts').doc(postId);
    final likeDocRef = postRef.collection('likes').doc(userId);
    return _db.runTransaction((transaction) async {
      final likeDoc = await transaction.get(likeDocRef);
      if (likeDoc.exists) {
        transaction.delete(likeDocRef);
        transaction.update(postRef, {'likeCount': FieldValue.increment(-1)});
      } else {
        transaction.set(likeDocRef, {'likedAt': FieldValue.serverTimestamp()});
        transaction.update(postRef, {'likeCount': FieldValue.increment(1)});
      }
    });
  }

  Stream<bool> isPostLikedByUser(String postId, String userId) {
    return _db.collection('posts').doc(postId).collection('likes').doc(userId)
        .snapshots().map((snapshot) => snapshot.exists);
  }

  Stream<int> getPostLikeCount(String postId) {
    return _db.collection('posts').doc(postId)
        .snapshots()
        .map((snapshot) => (snapshot.data()?['likeCount'] as int?) ?? 0);
  }

  Future<void> incrementUserXp(String userId, int amount) async {
    final userRef = _db.collection('users').doc(userId);
    await userRef.update({'xp': FieldValue.increment(amount)});
  }

  Stream<QuerySnapshot> getComments(String postId) {
    return _db.collection('posts').doc(postId).collection('comments')
        .orderBy('createdAt', descending: false).snapshots();
  }

  Stream<QuerySnapshot> getReplies(String postId, String commentId) {
    return _db.collection('posts').doc(postId).collection('comments').doc(commentId)
        .collection('replies').orderBy('createdAt', descending: false).snapshots();
  }

  Stream<int> getCommentsAndRepliesCount(String postId) {
    return _db.collection('posts').doc(postId).snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return 0;
      return (snapshot.data()?['commentCount'] as int?) ?? 0;
    });
  }

  Future<void> addComment(String postId, String text, Map<String, dynamic> author) async {
    final postRef = _db.collection('posts').doc(postId);
    final newCommentRef = postRef.collection('comments').doc();
    final batch = _db.batch();
    batch.set(newCommentRef, {
      'text': text, 'author': author, 'createdAt': FieldValue.serverTimestamp(),
    });
    batch.update(postRef, {'commentCount': FieldValue.increment(1)});
    await batch.commit();
  }

  Future<void> addReply(String postId, String commentId, String text, Map<String, dynamic> author) async {
    final postRef = _db.collection('posts').doc(postId);
    final newReplyRef = postRef.collection('comments').doc(commentId).collection('replies').doc();
    final batch = _db.batch();
    batch.set(newReplyRef, {
      'text': text, 'author': author, 'createdAt': FieldValue.serverTimestamp(),
    });
    batch.update(postRef, {'commentCount': FieldValue.increment(1)});
    await batch.commit();
  }

  Future<void> updateComment(DocumentReference docRef, String newText) async {
    await docRef.update({'text': newText});
  }

  /// 댓글 또는 대댓글을 지능적으로 삭제하고 commentCount를 업데이트합니다.
  /// @param docRef 삭제할 댓글 또는 대댓글의 DocumentReference
  Future<void> deleteCommentOrReply(DocumentReference docRef) async {
    final isReply = docRef.path.contains('/replies/');

    DocumentReference postRef;
    if (isReply) {
      postRef = docRef.parent.parent!.parent.parent!;
    } else {
      postRef = docRef.parent.parent!;
    }

    if (!isReply) {
      final repliesSnapshot = await docRef.collection('replies').get();
      final repliesCount = repliesSnapshot.size;
      final decrementAmount = 1 + repliesCount;
      final batch = _db.batch();
      for (var doc in repliesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(docRef);
      batch.update(postRef, {'commentCount': FieldValue.increment(-decrementAmount)});
      await batch.commit();
    } else {
      final batch = _db.batch();
      batch.delete(docRef);
      batch.update(postRef, {'commentCount': FieldValue.increment(-1)});
      await batch.commit();
    }
  }

  Future<void> voteOnPoll({required String postId, required int optionIndex, required String userId}) async {
    final postRef = _db.collection('posts').doc(postId);
    return _db.runTransaction((transaction) async {
      final postSnapshot = await transaction.get(postRef);
      if (!postSnapshot.exists) {
        throw Exception("Post does not exist!");
      }
      final postData = postSnapshot.data() as Map<String, dynamic>;
      final pollData = postData['poll'] as Map<String, dynamic>?;
      if (pollData == null) return;
      final options = List<Map<String, dynamic>>.from(pollData['options'] ?? []);
      for (var option in options) {
        (option['votes'] as List).remove(userId);
      }
      if (optionIndex < options.length) {
        (options[optionIndex]['votes'] as List).add(userId);
      }
      transaction.update(postRef, {'poll.options': options});
    });
  }
}