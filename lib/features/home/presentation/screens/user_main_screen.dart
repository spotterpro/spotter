// 📁 lib/src/screens/user_main_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// 이 화면은 형님의 기존 MainScreen.dart 파일을 대체하거나,
// MainScreen이 이 화면을 포함하는 구조로 변경될 수 있습니다.
class UserMainScreen extends StatelessWidget {
  final User user;
  const UserMainScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // 이 부분은 형님의 기존 MainScreen의 build 메소드 내용을 가져오시면 됩니다.
    // 예시로 간단한 화면만 구성합니다.
    return Scaffold(
      appBar: AppBar(title: const Text('스포터 (사용자 모드)')),
      body: Center(
        child: Text('안녕하세요, ${user.displayName ?? '사용자'}님!'),
        // TODO: 여기에 형님의 기존 BottomNavigationBar와 HomeScreen 등이 포함된
        // MainScreen의 Scaffold 내용을 통합하십시오.
      ),
    );
  }
}