// 📁 lib/main.dart
// [아우] 2025-09-02 최종 수정: AppDecider 호출부 수정

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:spotter/firebase_options.dart';
import 'package:spotter/core/models/user_model.dart';
import 'package:spotter/core/services/firestore_service.dart'; // FirestoreService import 추가
import 'package:spotter/features/auth/presentation/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotter/app/navigation/app_decider.dart';

final ValueNotifier<int> mainScreenNavigator = ValueNotifier(0);
ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AuthRepository.initialize(appKey: '3f7eeaf7f86b376c410316e1280d0bac');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (_, ThemeMode currentMode, __) {
          return MaterialApp(
            title: 'Spotter',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.orange,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            darkTheme: ThemeData.dark().copyWith(
              primaryColor: Colors.orange,
              indicatorColor: Colors.orange,
            ),
            themeMode: currentMode,
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }
                if (snapshot.hasData) {
                  return AuthWrapper(user: snapshot.data!);
                }
                return const LoginScreen();
              },
            ),
          );
        }
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final User user;
  const AuthWrapper({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>( // FirestoreService를 사용하도록 FutureBuilder로 변경
      future: FirestoreService().getUserProfile(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          // Firestore에 사용자 프로필이 없는 경우 (예: 회원가입 직후) 로그인 화면으로 보냅니다.
          // TODO: 또는 프로필 생성 화면으로 보내는 로직을 추가할 수 있습니다.
          return const LoginScreen();
        }

        final userProfile = snapshot.data!;
        // --- 🔥🔥🔥 [아우] 여기가 핵심 수정 지점! 🔥🔥🔥 ---
        // AppDecider에 user 객체 대신 완성된 userProfile을 전달합니다.
        return AppDecider(userProfile: userProfile);
      },
    );
  }
}