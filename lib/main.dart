// 📁 lib/main.dart

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

ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- 형님의 요청대로 수정된 부분 ---
  // 제공해주신 Javascript 키로 SDK를 초기화하고, 모든 통신을 HTTPS로 강제합니다.
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
              brightness: Brightness.light,
              primarySwatch: Colors.orange,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              scaffoldBackgroundColor: const Color(0xFFF5F5F5),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                elevation: 0.5,
              ),
              cardColor: Colors.white,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.orange,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              scaffoldBackgroundColor: const Color(0xFF121212),
              cardColor: const Color(0xFF1E1E1E),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1E1E1E),
                surfaceTintColor: Color(0xFF1E1E1E),
              ),
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

        return MainScreen(currentUserProfile: userProfile);
      },
    );
  }
}