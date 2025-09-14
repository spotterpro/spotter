import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:spotter/features/authentication/presentation/screens/login_screen.dart';
import 'package:spotter/features/theme/data/theme_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AuthRepository.initialize(appKey: '3f7eeaf7f86b376c410316e1280d0bac');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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

          // [수정] 라이트 테마 상세 정의
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.orange,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black, // 아이콘 및 텍스트 색상
              elevation: 1,
            ),
            cardColor: Colors.white,
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Color(0xFFFFA726),
              unselectedItemColor: Colors.grey,
            ),
          ),
          // [수정] 다크 테마 상세 정의
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.orange,
            scaffoldBackgroundColor: const Color(0xFF121212), // 기본 배경
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E), // 앱바 배경
              elevation: 1,
            ),
            cardColor: const Color(0xFF1E1E1E), // 카드 배경
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF1E1E1E),
              selectedItemColor: Color(0xFFFFA726),
              unselectedItemColor: Colors.grey,
            ),
            // 기타 색상들...
          ),
          themeMode: themeMode,

          home: const LoginScreen(),
        );
      },
    );
  }
}