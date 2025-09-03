// 📁 lib/src/screens/store_mode_router.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotter/core/services/mode_prefs.dart'; // ModePrefs 임포트
import 'package:spotter/core/services/store_mode_service.dart';
import 'package:spotter/features/store/presentation/screens/application_status_screen.dart';
import 'package:spotter/features/store/presentation/screens/owner_mode/store_owner_main_screen.dart';
import 'package:spotter/features/store/presentation/screens/store_switch_screen.dart';
import 'package:spotter/features/store/presentation/screens/owner_mode/nfc_registration_screen.dart';

class StoreModeRouter extends StatefulWidget {
  const StoreModeRouter({super.key});

  @override
  State<StoreModeRouter> createState() => _StoreModeRouterState();
}

class _StoreModeRouterState extends State<StoreModeRouter> {
  @override
  void initState() {
    super.initState();
    _routeUser();
  }

  Future<void> _routeUser() async {
    await Future.delayed(Duration.zero);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.of(context).pop();
      return;
    }

    final status = await StoreModeService(uid: user.uid).getStoreStatus();

    if (!mounted) return;

    Widget destinationScreen;
    switch (status) {
      case 'approved':
      // --- 🔥🔥🔥 이 부분을 추가합니다! ---
      // 가게 주인임이 확인되면, '가게 모드'를 사용자의 기본값으로 저장합니다.
        await ModePrefs.setStoreMode(true);
        destinationScreen = StoreOwnerMainScreen(user: user);
        break;
      case 'awaiting_nfc':
        destinationScreen = NfcRegistrationScreen(applicationId: user.uid);
        break;
      case 'pending':
      case 'rejected':
        destinationScreen = ApplicationStatusScreen(status: status);
        break;
      case 'none':
      default:
        destinationScreen = const StoreSwitchScreen();
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => destinationScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}