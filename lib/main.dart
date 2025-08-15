// 📁 lib/main.dart (최종 수정본)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:spotter/firebase_options.dart';
import 'package:spotter/models/user_model.dart';
import 'package:spotter/src/screens/main_screen.dart';
import 'package:spotter/src/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotter/src/screens/app_decider.dart'; // AppDecider import

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
            theme: ThemeData( /* ...기존 테마 설정... */ ),
            darkTheme: ThemeData.dark( /* ...기존 다크 테마 설정... */ ),
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
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          // 사용자 프로필이 없는 경우 로그인 화면으로 보냅니다.
          // (예: 계정은 있지만 프로필 생성이 실패한 경우)
          return const LoginScreen();
        }

        final userProfile = UserProfile.fromDocument(snapshot.data!);

        // 🔥🔥🔥 --- 바로 이 부분입니다, 형님! --- 🔥🔥🔥
        // MainScreen으로 바로 가는 대신, AppDecider가 먼저 검문하도록 합니다.
        return AppDecider(user: user, userProfile: userProfile);
      },
    );
  }
}