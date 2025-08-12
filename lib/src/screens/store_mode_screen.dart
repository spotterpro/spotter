// 📁 lib/src/screens/store_mode_screen.dart

import 'package:flutter/material.dart';

class StoreModeScreen extends StatelessWidget {
  final String storeId;

  const StoreModeScreen({
    super.key,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('가게 모드'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: 가게 관리 설정 화면으로 이동
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '가게 대시보드',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('가게 ID: $storeId'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: 스탬프 투어 생성 화면으로 이동
              },
              child: const Text('새로운 스탬프 투어 만들기'),
            )
          ],
        ),
      ),
    );
  }
}