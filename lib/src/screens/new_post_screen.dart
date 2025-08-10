// 📁 new_post_screen.dart

import 'package:flutter/material.dart';

class NewPostScreen extends StatelessWidget {
  const NewPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시물 작성'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: '내용',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                expands: true,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // 저장 로직 (추후 연동)
                Navigator.pop(context);
              },
              child: const Text('작성 완료'),
            ),
          ],
        ),
      ),
    );
  }
}
