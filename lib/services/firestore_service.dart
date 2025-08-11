// 📁 lib/services/firestore_service.dart

import 'dart:async'; // <--- 형님, 이 부분의 오타를 수정했습니다.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
    return _db.collection('posts').doc(postId).collection('comments').snapshots().switchMap((commentsSnapshot) {
      int directCommentsCount = commentsSnapshot.docs.length;
      if (commentsSnapshot.docs.isEmpty) {
        return Stream.value(0);
      }
      List<Stream<int>> replyCountStreams = commentsSnapshot.docs.map((commentDoc) {
        return _db.collection('posts').doc(postId).collection('comments').doc(commentDoc.id)
            .collection('replies').snapshots().map((replySnapshot) => replySnapshot.size);
      }).toList();
      return CombineLatestStream.list(replyCountStreams).map((replyCounts) {
        int totalRepliesCount = replyCounts.fold(0, (sum, count) => sum + count);
        return directCommentsCount + totalRepliesCount;
      });
    });
  }

  Future<void> addComment(String postId, String text, Map<String, dynamic> author) async {
    await _db.collection('posts').doc(postId).collection('comments').add({
      'text': text,
      'author': author,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addReply(String postId, String commentId, String text, Map<String, dynamic> author) async {
    await _db.collection('posts').doc(postId).collection('comments').doc(commentId)
        .collection('replies').add({
      'text': text,
      'author': author,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateComment(DocumentReference docRef, String newText) async {
    await docRef.update({'text': newText});
  }

  Future<void> deleteComment(DocumentReference docRef) async {
    await docRef.delete();
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