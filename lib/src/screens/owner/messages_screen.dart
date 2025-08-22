// 📁 lib/src/screens/owner/messages_screen.dart
import 'package:flutter/material.dart';

class OwnerMessagesScreen extends StatelessWidget {
  final String storeId;
  const OwnerMessagesScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    // --- 🔥🔥🔥 수정된 부분: Scaffold와 AppBar를 제거하고 내용물인 Center만 남깁니다. ---
    return const Center(child: Text('메시지 기능 준비중 입니다.'));
  }
}