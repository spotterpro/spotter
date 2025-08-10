import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirePost {
  final String id;
  final String authorId;
  final String authorName;
  final String title;
  final String content;
  final String? regionId;
  final DateTime createdAt;

  FirePost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.content,
    required this.createdAt,
    this.regionId,
  });

  factory FirePost.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return FirePost(
      id: doc.id,
      authorId: d['authorId'] as String,
      authorName: (d['authorName'] as String?) ?? '스포터 유저',
      title: (d['title'] as String?) ?? '',
      content: (d['content'] as String?) ?? '',
      regionId: d['regionId'] as String?,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }
}

class _Repo {
  final _db = FirebaseFirestore.instance;

  Stream<List<FirePost>> stream({String? regionId, int limit = 50}) {
    Query<Map<String, dynamic>> q =
    _db.collection('posts').orderBy('createdAt', descending: true).limit(limit);
    if (regionId != null && regionId.isNotEmpty) {
      q = _db
          .collection('posts')
          .where('regionId', isEqualTo: regionId)
          .orderBy('createdAt', descending: true)
          .limit(limit);
    }
    return q.withConverter<Map<String, dynamic>>(
      fromFirestore: (s, _) => s.data()!,
      toFirestore: (d, _) => d,
    ).snapshots().map((s) => s.docs.map(FirePost.fromDoc).toList());
  }

  Future<void> toggleLike(String postId, String uid) async {
    final ref = _db.collection('posts').doc(postId).collection('likes').doc(uid);
    final cur = await ref.get();
    if (cur.exists) { await ref.delete(); }
    else { await ref.set({'uid': uid, 'likedAt': Timestamp.fromDate(DateTime.now())}); }
  }

  Stream<bool> iLiked(String postId, String uid) {
    return _db.collection('posts').doc(postId).collection('likes').doc(uid)
        .snapshots().map((d) => d.exists);
  }

  Stream<int> likeCount(String postId) {
    return _db.collection('posts').doc(postId).collection('likes')
        .snapshots().map((s) => s.size);
  }
}

final _repo = _Repo();

/// 홈 화면 아래에 삽입하는 실시간 스팟피드
class RealtimeSpotFeed extends StatelessWidget {
  /// 지역 필터 (없으면 전체)
  final String? regionId;

  /// 부모가 이미 스크롤이라면 true (ListView가 내부 스크롤을 끔)
  final bool insideScrollable;

  const RealtimeSpotFeed({
    super.key,
    this.regionId,
    this.insideScrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const SizedBox.shrink();
    }

    final listView = StreamBuilder<List<FirePost>>(
      stream: _repo.stream(regionId: regionId, limit: 50),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text('실시간 피드 오류: ${snap.error}'),
          );
        }
        final items = snap.data ?? [];
        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('아직 게시물이 없습니다. 첫 글을 올려보세요!')),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: insideScrollable
              ? const NeverScrollableScrollPhysics()
              : const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _PostTile(post: items[i], me: uid),
        );
      },
    );

    // CustomScrollView(슬리버) 환경에서도 쉽게 쓰도록 래핑
    return insideScrollable ? listView : Expanded(child: listView);
  }
}

class _PostTile extends StatelessWidget {
  final FirePost post;
  final String me;
  const _PostTile({required this.post, required this.me});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.regionId != null && post.regionId!.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.place_outlined, size: 14),
                  const SizedBox(width: 4),
                  Text(post.regionId!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            if (post.regionId != null && post.regionId!.isNotEmpty)
              const SizedBox(height: 6),
            Text(post.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(post.content),
            const SizedBox(height: 10),
            Row(
              children: [
                StreamBuilder<bool>(
                  stream: _repo.iLiked(post.id, me),
                  builder: (context, s) {
                    final liked = s.data ?? false;
                    return IconButton(
                      onPressed: () => _repo.toggleLike(post.id, me),
                      icon: Icon(liked ? Icons.favorite : Icons.favorite_border),
                      tooltip: liked ? '좋아요 취소' : '좋아요',
                    );
                  },
                ),
                StreamBuilder<int>(
                  stream: _repo.likeCount(post.id),
                  builder: (context, s) => Text('좋아요 ${s.data ?? 0}'),
                ),
                const Spacer(),
                Text(_pretty(post.createdAt), style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _pretty(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inHours < 1) return '${diff.inMinutes}분 전';
    if (diff.inDays < 1) return '${diff.inHours}시간 전';
    return '${dt.year}.${dt.month.toString().padLeft(2, "0")}.${dt.day.toString().padLeft(2, "0")}';
  }
}
