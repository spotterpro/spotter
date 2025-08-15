// 📁 lib/services/mode_prefs.dart

import 'package:shared_preferences/shared_preferences.dart';

class ModePrefs {
  static const _storeModeKey = 'forceStoreMode';

  static Future<void> setStoreMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_storeModeKey, enabled);
  }

  static Future<bool> getStoreMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_storeModeKey) ?? false;
  }
}