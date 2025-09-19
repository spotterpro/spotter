// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:spotter/auth_gate.dart';
import 'package:spotter/features/theme/data/theme_provider.dart';
import 'firebase_options.dart';

// [복원] 앱의 시동을 거는 main 함수
void main() async {
  // 1. Flutter 엔진 바인딩 초기화 (필수)
  WidgetsFlutterBinding.ensureInitialized();

  // 2. .env 파일 로드
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("치명적 오류: .env 파일을 로드할 수 없습니다. pubspec.yaml 파일을 확인하십시오. 오류: $e");
    return;
  }

  // 3. 카카오맵 SDK 초기화
  AuthRepository.initialize(
    appKey: dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '',
  );

  // 4. Firebase 앱 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 5. 모든 초기화가 끝난 후 앱 실행
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeProvider,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'Spotter',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(), // 예시 테마
          darkTheme: ThemeData.dark(),  // 예시 테마
          themeMode: themeMode,
          home: const AuthGate(),
        );
      },
    );
  }
}