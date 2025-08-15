// 📁 lib/src/screens/app_decider.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spotter/models/user_model.dart';
import 'package:spotter/services/store_mode_service.dart';
import 'package:spotter/src/screens/main_screen.dart';
import 'package:spotter/src/screens/owner/store_owner_main_screen.dart';

class AppDecider extends StatelessWidget {
  final User user;
  final UserProfile userProfile;

  const AppDecider({
    super.key,
    required this.user,
    required this.userProfile,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: StoreModeService(uid: user.uid).shouldEnterStoreMode(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData && snapshot.data == true) {
          // 가게 모드로 진입
          return StoreOwnerMainScreen(user: user);
        } else {
          // 사용자 모드로 진입
          return MainScreen(currentUserProfile: userProfile);
        }
      },
    );
  }
}