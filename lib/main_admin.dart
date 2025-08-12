// 📁 lib/main_admin.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotter/firebase_options.dart';
import 'package:spotter/src/screens/admin/admin_login_screen.dart';
import 'package:spotter/src/screens/admin/admin_dashboard_screen.dart';

// 관리자 페이지를 위한 별도의 main 함수
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 앱과 동일한 Firebase 프로젝트를 사용합니다.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotter Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            // 로그인 되어 있으면 대시보드로 이동
            return const AdminDashboardScreen();
          }
          // 로그인 안되어 있으면 로그인 화면으로 이동
          return const AdminLoginScreen();
        },
      ),
    );
  }
}