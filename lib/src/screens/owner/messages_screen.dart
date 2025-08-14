// 📁 lib/src/screens/owner/messages_screen.dart
import 'package:flutter/material.dart';

class OwnerMessagesScreen extends StatelessWidget {
  final String storeId;
  const OwnerMessagesScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('메시지'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: const Center(child: Text('메시지 화면')),
    );
  }
}