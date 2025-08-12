// 📁 lib/src/screens/owner/store_management_screen.dart

import 'package:flutter/material.dart';

class StoreManagementScreen extends StatelessWidget {
  final String storeId;

  const StoreManagementScreen({
    super.key,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('가게 관리 대시보드'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: '사용자 모드로 전환',
            onPressed: () {
              // MainScreen으로 돌아가는 로직 (추후 보강)
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.storefront, size: 80, color: Colors.orange),
              const SizedBox(height: 24),
              const Text(
                '사장님, 환영합니다!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                '이제 이곳에서 스탬프 투어와 리워드를 만들고\n가게를 관리할 수 있습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: 스탬프 생성 화면으로 이동
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('새 스탬프 투어 만들기'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}