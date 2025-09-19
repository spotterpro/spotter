import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:spotter_admin/screens/admin_dashboard_screen.dart';
import 'package:spotter_admin/screens/admin_login_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:webview_flutter_web/webview_flutter_web.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

const firebaseConfig = {
  "apiKey": "AIzaSyDJEpnSwrXk1ZVPvGzWlHwKrP3CRfiQzOU",
  "authDomain": "spotter-77c9b.firebaseapp.com",
  "projectId": "spotter-77c9b",
  "storageBucket": "spotter-77c9b.firebasestorage.app",
  "messagingSenderId": "725986283988",
  "appId": "1:725986283988:web:88a310fd7aa0748e210641",
  "measurementId": "G-FFPJN2YNQL"
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 웹 환경일 경우에만 WebView 엔진을 등록합니다.
  if (kIsWeb) {
    WebViewPlatform.instance = WebWebViewPlatform();
  }

  // 카카오맵 플러그인의 웹 실행을 위해 Kakao SDK 초기화가 필요합니다.
  KakaoSdk.init(
    nativeAppKey: '5dfde38b0ada26ea098707572529159a',
    javaScriptAppKey: '3f7eeaf7f86b376c410316e1280d0bac',
  );

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: firebaseConfig['apiKey']!,
      authDomain: firebaseConfig['authDomain']!,
      projectId: firebaseConfig['projectId']!,
      storageBucket: firebaseConfig['storageBucket']!,
      messagingSenderId: firebaseConfig['messagingSenderId']!,
      appId: firebaseConfig['appId']!,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotter Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const AdminDashboardScreen();
        }
        return const AdminLoginScreen();
      },
    );
  }
}