import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core 추가
import 'package:spotter/features/authentication/presentation/screens/login_screen.dart';
import 'firebase_options.dart'; // firebase_cli를 통해 생성된 파일

void main() async { // async 키워드 추가
  // main 함수에서 비동기 작업을 처리하기 위한 필수 코드
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase 앱 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LoginScreen(),
    );
  }
}