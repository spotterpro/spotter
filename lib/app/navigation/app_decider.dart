// 📁 lib/src/screens/app_decider.dart
// [아우] 2025-09-02 최종 수정: main.dart의 AuthWrapper와 연동되도록 구조 변경

import 'package:flutter/material.dart';
import 'package:spotter/core/models/user_model.dart';
import 'package:spotter/features/home/presentation/screens/main_screen.dart'; // MainScreen import 추가

// 이제 AppDecider는 인증 상태를 확인하는 대신,
// AuthWrapper로부터 완전한 프로필 정보를 전달받아 최종 화면을 결정하는 역할만 합니다.
class AppDecider extends StatelessWidget {
  final UserProfile userProfile;

  const AppDecider({
    super.key,
    required this.userProfile,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: 추후 여기에 사용자 모드/가게 모드를 전환하는 로직이 들어갈 수 있습니다.
    // 지금은 사용자 모드의 메인 화면으로 바로 연결합니다.
    return MainScreen(currentUserProfile: userProfile);
  }
}