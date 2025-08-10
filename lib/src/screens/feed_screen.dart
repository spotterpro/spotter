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
      fromFirestore: (snap, _) => snap.data()!,
      toFirestore: (data, _) => data,
    ).snapshots().map((s) => s.docs.map(FirePost.fromDoc).toList());
  }

  Future<void> toggleLike(String postId, String uid) async {
    final ref = _db.collection('posts').doc(postId).collection('likes').doc(uid);
    final cur = await ref.get();
    if (cur.exists) {
      await ref.delete();
    } else {
      await ref.set({'uid': uid, 'likedAt': Timestamp.fromDate(DateTime.now())});
    }
  }

  Stream<bool> iLiked(String postId, String uid) {
    return _db
        .collection('posts').doc(postId).collection('likes').doc(uid)
        .snapshots().map((d) => d.exists);
  }

  Stream<int> likeCount(String postId) {
    return _db.collection('posts').doc(postId).collection('likes')
        .snapshots().map((s) => s.size);
  }
}

final _repo = _Repo();

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final List<Map<String, String?>> _regions = const [
    {'label': '전체', 'value': null},
    {'label': '중구', 'value': 'DG-Junggu'},
    {'label': '달서구', 'value': 'DG-Dalseo'},
  ];
  String? _region;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('로그인이 필요합니다.')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('실시간 피드'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                const Icon(Icons.place_outlined, size: 18),
                const SizedBox(width: 8),
                DropdownButton<String?>(
                  value: _region,
                  underline: const SizedBox.shrink(),
                  items: _regions.map((e) => DropdownMenuItem(
                    value: e['value'],
                    child: Text(e['label']!),
                  )).toList(),
                  onChanged: (v) => setState(() => _region = v),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => setState(() {}),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('새로고침'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => setState(() {}),
              child: StreamBuilder<List<FirePost>>(
                stream: _repo.stream(regionId: _region, limit: 50),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(child: Text('에러: ${snap.error}'));
                  }
                  final items = snap.data ?? [];
                  if (items.isEmpty) {
                    return ListView(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                        const Center(child: Text('첫 글을 올려보십시오, 형님!')),
                      ],
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _PostTile(post: items[i], me: uid),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
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
                  builder: (context, s) {
                    final cnt = s.data ?? 0;
                    return Text('좋아요 $cnt');
                  },
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
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
  }
}
