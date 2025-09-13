import 'package:flutter/material.dart';

class StampScreen extends StatelessWidget {
  const StampScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('스탬프'),
      ),
      body: const Center(
        child: Text(
          '스탬프 화면입니다.',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}