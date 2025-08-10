import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
// ↓↓↓↓↓↓↓↓↓↓ 이 한 줄의 오타를 바로 잡았습니다, 형님! ↓↓↓↓↓↓↓↓↓↓
import 'package:firebase_auth/firebase_auth.dart';
// ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
import 'package:google_sign_in/google_sign_in.dart';
import 'package:spotter/src/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSigningIn = false;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isSigningIn = true;
    });

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        if (mounted) {
          setState(() {
            _isSigningIn = false;
          });
        }
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);

    } catch (e) {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 중 문제가 발생했습니다: ${e.toString()}')),
        );
      }
    }
  }

  void _onKakaoPressed(BuildContext ctx) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('카카오 로그인은 현재 준비 중입니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = const TextStyle(
        fontSize: 36, fontWeight: FontWeight.bold, color: Colors.orange);
    final subtitleStyle = TextStyle(fontSize: 14, color: Colors.grey[700]);
    final disclaimerStyle =
    TextStyle(fontSize: 12, color: Colors.grey[500], height: 1.4);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Text('Spotter', style: titleStyle),
              const SizedBox(height: 8),
              Text(
                '내 동네의 재발견, 스포터와 함께',
                style: subtitleStyle,
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 4),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: GestureDetector(
                  onTap: () => _onKakaoPressed(context),
                  child: Image.asset(
                    'assets/images/kakao_signin_button.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (_isSigningIn)
                const Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: SignInButton(
                    Buttons.Google,
                    text: 'Sign in with Google',
                    onPressed: _signInWithGoogle,
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              const Spacer(flex: 5),
              Text(
                '로그인은 개인 정보 보호 정책 및 서비스 약관에 동의하는 것을 의미하며,\n'
                    '서비스 이용을 위해 이메일과 프로필 정보를 수집합니다.',
                style: disclaimerStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}