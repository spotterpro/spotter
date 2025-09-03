import 'package:flutter/material.dart';
import 'package:spotter/core/services/firestore_service.dart';
import 'package:spotter/features/feed/presentation/widgets/feed_card.dart';

// [아우] 게시물의 상세 정보를 보여주는 화면입니다.
// 어떤 종류의 게시물인지 알아야 하므로 collectionPath를 받습니다.
class PostDetailScreen extends StatefulWidget {
  final String collectionPath;
  final Map<String, dynamic> postItem;
  final Map<String, dynamic> currentUser;

  const PostDetailScreen({
    super.key,
    required this.collectionPath,
    required this.postItem,
    required this.currentUser,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _deletePost(String postId) async {
    try {
      await _firestoreService.deletePost(widget.collectionPath, postId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시물이 삭제되었습니다.')),
        );
        Navigator.of(context).pop(); // 삭제 후 뒤로 가기
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 중 오류가 발생했습니다: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _updatePost(String postId, String newCaption, List<String> newTags) async {
    try {
      await _firestoreService.updatePost(widget.collectionPath, postId, newCaption, newTags);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시물이 수정되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('수정 중 오류가 발생했습니다: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시물'),
      ),
      body: SingleChildScrollView(
        child: FeedCard(
          // [아우] 🔥🔥🔥 여기가 마지막 수정 지점입니다! 🔥🔥🔥
          // 생성자로부터 받은 collectionPath를 FeedCard에 그대로 전달합니다.
          collectionPath: widget.collectionPath,
          item: widget.postItem,
          currentUser: widget.currentUser,
          onDelete: () => _deletePost(widget.postItem['id']),
          onUpdate: (caption, tags) => _updatePost(widget.postItem['id'], caption, tags),
        ),
      ),
    );
  }
}