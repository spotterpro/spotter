// 📁 lib/src/screens/owner/operations_screen.dart
import 'package:flutter/material.dart';

class OperationsScreen extends StatelessWidget {
  final String storeId;
  const OperationsScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('가게 운영'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: const Center(child: Text('가게 운영 화면')),
    );
  }
}