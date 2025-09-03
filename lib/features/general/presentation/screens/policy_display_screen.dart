// 📁 lib/src/screens/policy_display_screen.dart

import 'package:flutter/material.dart';

class PolicyDisplayScreen extends StatelessWidget {
  final String title;
  final String content;

  const PolicyDisplayScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          content,
          style: const TextStyle(fontSize: 15, height: 1.6),
        ),
      ),
    );
  }
}