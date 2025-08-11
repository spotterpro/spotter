// 📁 lib/src/widgets/comment_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:spotter/src/widgets/comment_section.dart';

class CommentBottomSheet extends StatelessWidget {
  final String postId;
  // --- 형님의 요청대로 수정된 부분 ---
  // 현재 사용자 정보를 받기 위한 파라미터 추가
  final Map<String, dynamic> currentUser;

  const CommentBottomSheet({
    super.key,
    required this.postId,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40, height: 5, margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            Expanded(
              child: CommentSection(
                postId: postId,
                // --- 형님의 요청대로 수정된 부분 ---
                // CommentSection으로 현재 사용자 정보 전달
                currentUser: currentUser,
              ),
            ),
          ],
        ),
      ),
    );
  }
}