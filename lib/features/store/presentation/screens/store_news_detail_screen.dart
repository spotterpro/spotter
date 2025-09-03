import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spotter/core/models/user_model.dart';
import 'package:spotter/core/services/firestore_service.dart';
import 'package:spotter/features/community_and_post/presentation/widgets/comment_section.dart';
import 'package:spotter/features/store/presentation/screens/store_detail_screen.dart';

class StoreNewsDetailScreen extends StatefulWidget {
  // [아우] 어떤 가게의 어떤 소식인지 ID를 받아옵니다.
  final String storeId;
  final String newsId;
  // [아우] 하위 위젯에 전달할 현재 사용자 정보를 받습니다.
  final Map<String, dynamic> currentUser;

  const StoreNewsDetailScreen({
    super.key,
    required this.storeId,
    required this.newsId,
    required this.currentUser,
  });

  @override
  State<StoreNewsDetailScreen> createState() => _StoreNewsDetailScreenState();
}

class _StoreNewsDetailScreenState extends State<StoreNewsDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  // [아우] 더 이상 하드코딩된 댓글 데이터는 필요 없습니다.
  // final TextEditingController _commentController = TextEditingController();
  // ...

  @override
  Widget build(BuildContext context) {
    // [아우] owner_posts 컬렉션을 사용한다고 가정합니다. (정책에 따라 'posts'가 될 수도 있습니다)
    final String collectionPath = 'owner_posts';

    return Scaffold(
      appBar: AppBar(
        title: const Text('가게 소식'),
      ),
      // [아우] StreamBuilder를 사용해 Firestore에서 실시간으로 데이터를 가져옵니다.
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection(collectionPath).doc(widget.newsId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('소식을 불러올 수 없습니다.'));
          }
          final newsData = snapshot.data!.data() as Map<String, dynamic>;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildPostContent(newsData),
                    // [아우] 저희가 만든 CommentSection 위젯을 재사용합니다.
                    CommentSection(
                      collectionPath: collectionPath,
                      postId: widget.newsId,
                      currentUser: widget.currentUser,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPostContent(Map<String, dynamic> newsData) {
    final author = newsData['author'] as Map<String, dynamic>? ?? {};
    // ... (이하 newsData에서 필요한 변수들을 추출)

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            // [아우] 🔥🔥🔥 여기가 핵심 수정 지점입니다! 🔥🔥🔥
            Navigator.push(context, MaterialPageRoute(builder: (context) => StoreDetailScreen(
              storeId: widget.storeId,
              currentUser: widget.currentUser,
            )));
          },
          child: Row(
            // ... (가게 정보 UI)
          ),
        ),
        const SizedBox(height: 24),
        if (newsData['imageUrl'] != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              newsData['imageUrl'],
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        const SizedBox(height: 24),
        Text(
          newsData['content'] ?? '내용 없음',
          style: const TextStyle(fontSize: 16, height: 1.6),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            // [아우] 좋아요/댓글 기능도 FirestoreService와 연동합니다.
            StreamBuilder<bool>(
                stream: _firestoreService.isPostLikedByUser(
                    collectionPath: 'owner_posts',
                    postId: widget.newsId,
                    userId: widget.currentUser['uid']
                ),
                builder: (context, snapshot) {
                  final isLiked = snapshot.data ?? false;
                  return InkWell(
                    onTap: () => _firestoreService.togglePostLike(
                      collectionPath: 'owner_posts',
                      postId: widget.newsId,
                      userId: widget.currentUser['uid'],
                    ),
                    child: Row(
                      children: [
                        Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.grey),
                        const SizedBox(width: 4),
                        StreamBuilder<int>(
                            stream: _firestoreService.getPostLikeCount(collectionPath: 'owner_posts', postId: widget.newsId),
                            builder: (context, countSnapshot) {
                              return Text('좋아요 ${countSnapshot.data ?? 0}');
                            }
                        ),
                      ],
                    ),
                  );
                }
            ),
            const SizedBox(width: 16),
            Row(
              children: [
                const Icon(Icons.chat_bubble_outline, color: Colors.grey),
                const SizedBox(width: 4),
                StreamBuilder<int>(
                    stream: _firestoreService.getCommentsAndRepliesCount(
                        collectionPath: 'owner_posts',
                        postId: widget.newsId
                    ),
                    builder: (context, snapshot) {
                      return Text('댓글 ${snapshot.data ?? 0}');
                    }
                ),
              ],
            ),
          ],
        ),
        const Divider(height: 32),
      ],
    );
  }
}