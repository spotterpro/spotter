import 'package:flutter/material.dart';
import 'package:spotter/features/community_and_post/presentation/screens/post_detail_screen.dart';

class PostGridItem extends StatelessWidget {
  // [아우] 🔥🔥🔥 이 위젯이 알아야 할 정보들을 추가합니다. 🔥🔥🔥
  final String collectionPath;
  final Map<String, dynamic> post;
  final Map<String, dynamic> currentUser;

  const PostGridItem({
    super.key,
    required this.collectionPath,
    required this.post,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = post['imageUrl'] as String?;

    return GestureDetector(
      onTap: () {
        // [아우] 🔥🔥🔥 PostDetailScreen에 모든 정보를 정확히 전달합니다. 🔥🔥🔥
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(
              collectionPath: collectionPath,
              postItem: post,
              currentUser: currentUser,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          image: imageUrl != null && imageUrl.isNotEmpty
              ? DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          )
              : null,
        ),
        child: imageUrl == null || imageUrl.isEmpty
            ? const Icon(Icons.image_not_supported, color: Colors.grey)
            : null,
      ),
    );
  }
}