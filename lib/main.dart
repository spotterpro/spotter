// 📁 lib/main.dart (최종 수정본 - 초기화 코드 복원)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
// --- 🔥🔥🔥 이 부분이 다시 필요합니다, 형님! ---
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:spotter/firebase_options.dart';
import 'package:spotter/models/user_model.dart';
import 'package:spotter/src/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotter/src/screens/app_decider.dart';

ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- 🔥🔥🔥 제가 삭제하라고 했던 이 코드를 다시 복원해야 합니다! ---
  // 형님의 네이티브 앱 키: 3f7eeaf7f86b376c410316e1280d0bac
  AuthRepository.initialize(appKey: '3f7eeaf7f86b376c410316e1280d0bac');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  runApp(const MyApp());
}

// MyApp 클래스와 AuthWrapper 클래스는 기존과 동일합니다.
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
          return const LoginScreen();
        }

        final userProfile = UserProfile.fromDocument(snapshot.data!);
        return AppDecider(user: user, userProfile: userProfile);
      },
    );
  }
}