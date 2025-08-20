// 📁 lib/src/screens/app_decider.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spotter/models/user_model.dart';
import 'package:spotter/services/mode_prefs.dart';
import 'package:spotter/src/screens/main_screen.dart';
import 'package:spotter/src/screens/store_mode_router.dart';

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
      future: ModePrefs.getStoreMode(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final bool userPrefersStoreMode = snapshot.data ?? false;

        if (userPrefersStoreMode) {
          return const StoreModeRouter();
        } else {
          return MainScreen(currentUserProfile: userProfile);
        }
      },
    );
  }
}