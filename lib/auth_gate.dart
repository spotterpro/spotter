// lib/auth_gate.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spotter/features/authentication/presentation/screens/login_screen.dart';
import 'package:spotter/features/main_navigation/presentation/screens/main_screen.dart'; // [수정] MapScreen이 아닌 MainScreen을 호출

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const MainScreen(); // 로그인 시 MainScreen으로
        }
        return const LoginScreen(); // 로그아웃 시 LoginScreen으로
      },
    );
  }
}