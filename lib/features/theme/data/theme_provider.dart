import 'package:flutter/material.dart';

// 앱 전체의 테마 모드를 관리하는 클래스
// ValueNotifier를 사용하여 상태 변경을 감지하고 화면에 알립니다.
class ThemeProvider extends ValueNotifier<ThemeMode> {
  // 초기값은 시스템 설정을 따르도록 설정
  ThemeProvider() : super(ThemeMode.system);

  void toggleTheme(bool isDarkMode) {
    value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }
}

// 앱 어디서든 쉽게 접근할 수 있도록 전역 변수로 인스턴스 생성
final themeProvider = ThemeProvider();