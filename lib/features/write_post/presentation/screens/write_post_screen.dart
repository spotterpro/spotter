import 'package:flutter/material.dart';

class WritePostScreen extends StatelessWidget {
  const WritePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('글쓰기'),
      ),
      body: const Center(
        child: Text(
          '글쓰기 화면입니다.',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}