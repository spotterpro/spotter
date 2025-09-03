import 'package:flutter/material.dart';
import 'package:spotter/features/community_and_post/presentation/widgets/comment_section.dart';

class CommentBottomSheet extends StatelessWidget {
  final String collectionPath;
  final String postId;
  final Map<String, dynamic> currentUser;

  const CommentBottomSheet({
    Key? key,
    required this.collectionPath,
    required this.postId,
    required this.currentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // [아우] 🔥🔥🔥 여기가 마지막 수정 지점입니다! 🔥🔥🔥
    // 현재 테마의 밝기를 확인합니다.
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // 라이트 모드일 때는 흰색, 다크 모드일 때는 짙은 회색을 명시적으로 지정합니다.
    final backgroundColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      // [아우] padding을 추가하여 키보드가 올라왔을 때 입력창이 가려지지 않도록 합니다.
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      // [아우] Container 자체에 색상을 지정하는 대신, ClipRRect 안의 Material 위젯에 색상을 지정하여
      // 둥근 모서리 효과와 배경색을 모두 안전하게 적용합니다.
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Material(
          color: backgroundColor, // [아우] 불투명한 배경색을 여기에 적용합니다.
          child: Container(
            padding: const EdgeInsets.all(16.0),
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('댓글', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                const Divider(),
                Expanded(
                  child: CommentSection(
                    collectionPath: collectionPath,
                    postId: postId,
                    currentUser: currentUser,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}