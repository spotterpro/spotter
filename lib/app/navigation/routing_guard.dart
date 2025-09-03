// 📁 lib/src/screens/routing_guard.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RoutingGuard extends StatelessWidget {
  final User user;
  const RoutingGuard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // 지시대로 임시로 Scaffold와 텍스트만 표시합니다.
    // 추후 이 위젯은 main.dart의 로직을 가져와 앱의 첫 화면을 결정하는 역할을 할 수 있습니다.
    return const Scaffold(
      body: Center(
        child: Text('Routing...'),
      ),
    );
  }
}