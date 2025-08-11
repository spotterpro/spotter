// 📁 lib/services/auth.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final DocumentSnapshot userDoc = await _db.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          // --- 형님의 요청대로 수정된 부분 ---
          // 모든 성장 관련 지표를 0으로 초기화합니다.
          await _db.collection('users').doc(user.uid).set({
            'userName': '스포터',
            'email': user.email,
            'userImageSeed': 'user_${user.uid.substring(0, 5)}',
            'bio': '스포터 앱에 오신 것을 환영합니다!',
            'createdAt': FieldValue.serverTimestamp(),
            'xp': 0,
            'crewCount': 0,
            'myCrewCount': 0,
            'influence': 0,
          });
        }
      }
      return user;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Stream<User?> get user => _auth.authStateChanges();
}