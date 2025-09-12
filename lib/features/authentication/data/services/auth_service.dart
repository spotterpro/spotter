import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 기존 구글 로그인 메소드 (변경 없음)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error: ${e.message}");
      return null;
    } catch (e) {
      print("General Error: $e");
      return null;
    }
  }

  // [추가] 홈 화면에서 호출할 로그아웃 메소드
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut(); // Google 계정 세션 종료
      await _firebaseAuth.signOut(); // Firebase 계정 세션 종료
    } catch (e) {
      print("Sign Out Error: $e");
    }
  }
}