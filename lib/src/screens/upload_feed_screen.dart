// 📁 lib/src/screens/upload_feed_screen.dart

import 'package:flutter/material.dart';
import 'package:spotter/src/screens/create_community_post_screen.dart';

class UploadFeedScreen extends StatelessWidget {
  // --- 형님의 요청대로 수정된 부분 ---
  final Map<String, dynamic> currentUser;

  const UploadFeedScreen({
    super.key,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 게시물'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // TODO: 인증샷 올리기 화면으로 이동
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('인증샷 올리기 (NFC)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                // --- 형님의 요청대로 수정된 부분 ---
                // 글쓰기 화면으로 이동할 때 currentUser 정보를 전달합니다.
                Navigator.push(context, MaterialPageRoute(builder: (context) => CreateCommunityPostScreen(currentUser: currentUser)));
              },
              icon: const Icon(Icons.edit),
              label: const Text('커뮤니티 글쓰기'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}