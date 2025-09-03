import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotter/firebase_options.dart';
import 'package:spotter/features/admin/presentation/screens/admin_login_screen.dart';
import 'package:spotter/features/admin/presentation/screens/admin_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          brightness: Brightness.light,
          primarySwatch: Colors.orange,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0.5,
            titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
            iconTheme: IconThemeData(color: Colors.black),
          ),
          cardColor: Colors.white,
          tabBarTheme: TabBarThemeData(
            labelColor: Colors.orange[800],
            unselectedLabelColor: Colors.grey[600],
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 3, color: Colors.orange[800]!),
            ),
          )
      ),
      home: const AdminAuthWrapper(),
    );
  }
}

class AdminAuthWrapper extends StatelessWidget {
  const AdminAuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<IdTokenResult>(
            future: snapshot.data!.getIdTokenResult(true),
            builder: (context, tokenSnapshot) {
              if (tokenSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              if (tokenSnapshot.hasData && tokenSnapshot.data?.claims?['admin'] == true) {
                return const AdminDashboardScreen();
              }

              // [아우] 🔥🔥🔥 여기가 핵심 수정 지점입니다! 🔥🔥🔥
              // Scaffold에서 const를 제거하여, onPressed 함수를 포함할 수 있도록 합니다.
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('관리자 계정이 아닙니다. 접근 권한이 없습니다.'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => FirebaseAuth.instance.signOut(),
                        child: const Text('로그아웃'),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        }
        return const AdminLoginScreen();
      },
    );
  }
}