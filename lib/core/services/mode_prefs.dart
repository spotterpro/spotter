// 📁 lib/services/mode_prefs.dart

import 'package:shared_preferences/shared_preferences.dart';

class ModePrefs {
  static const String _storeModeKey = 'isStoreMode';

  // 가게 모드 상태 저장
  static Future<void> setStoreMode(bool isStoreMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_storeModeKey, isStoreMode);
  }

  // 가게 모드 상태 불러오기
  static Future<bool> getStoreMode() async {
    final prefs = await SharedPreferences.getInstance();
    // 저장된 값이 없으면 기본값은 false (사용자 모드)
    return prefs.getBool(_storeModeKey) ?? false;
  }
}