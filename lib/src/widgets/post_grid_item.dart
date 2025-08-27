// 📁 lib/src/widgets/post_grid_item.dart

import 'package:flutter/material.dart';
import 'package:spotter/src/screens/post_detail_screen.dart'; // 🔥🔥🔥 상세 페이지 임포트

class PostGridItem extends StatelessWidget {
  final Map<String, dynamic> post;
  const PostGridItem({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final imageUrl = post['imageUrl'] as String?;
    final isCertified = post['isCertified'] as bool? ?? false;

    return InkWell(
      // --- 🔥🔥🔥 수정된 부분: 탭하면 게시물 상세 페이지로 이동 ---
      onTap: () {
        final postId = post['id'] as String?;
        if (postId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailScreen(postId: postId),
            ),
          );
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl != null
                ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                return progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2.0));
              },
              errorBuilder: (_,__,___) => Container(color: Colors.grey[300], child: const Icon(Icons.image_not_supported, color: Colors.white)),
            )
                : Container(color: Colors.grey[300], child: const Icon(Icons.image_not_supported, color: Colors.white)),
          ),
          if (isCertified)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Colors.greenAccent, size: 18),
              ),
            ),
        ],
      ),
    );
  }
}