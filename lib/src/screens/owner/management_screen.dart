// 📁 lib/src/screens/owner/management_screen.dart
import 'package:flutter/material.dart';

class ManagementScreen extends StatelessWidget {
  final String storeId;
  const ManagementScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('가게 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: const Center(child: Text('가게 관리 화면')),
    );
  }
}