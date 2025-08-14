// 📁 lib/src/screens/owner/community_screen.dart
import 'package:flutter/material.dart';

class OwnerCommunityScreen extends StatelessWidget {
  final String storeId;
  const OwnerCommunityScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사장님 광장'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: const Center(child: Text('사장님 광장 화면')),
    );
  }
}