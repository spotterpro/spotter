import 'package:flutter/material.dart';
import 'package:spotter/src/widgets/comment_section.dart';

class CommentBottomSheet extends StatelessWidget {
  final List<Map<String, dynamic>> initialComments;
  final Function(List<Map<String, dynamic>>) onCommentsUpdated;

  const CommentBottomSheet({
    super.key,
    required this.initialComments,
    required this.onCommentsUpdated,
  });

  @override
  Widget build(BuildContext context) {
    // --- 형님의 요청대로 수정된 부분 ---
    // 키보드가 올라올 때 화면이 가려지지 않도록 Padding을 추가합니다.
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
                initialComments: initialComments,
                onCommentsUpdated: onCommentsUpdated,
              ),
            ),
          ],
        ),
      ),
    );
  }
}