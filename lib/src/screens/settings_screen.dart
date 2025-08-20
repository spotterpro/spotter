// 📁 lib/src/screens/settings_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotter/main.dart';
import 'package:spotter/services/auth.dart';
import 'package:spotter/services/mode_prefs.dart';
import 'package:spotter/src/screens/announcements_screen.dart';
import 'package:spotter/src/screens/customer_service_screen.dart';
import 'package:spotter/src/screens/edit_profile_screen.dart';
import 'package:spotter/src/screens/store_mode_router.dart';
import 'package:spotter/src/screens/terms_and_policies_screen.dart';

class SettingsScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  final Function(Map<String, String>) onProfileUpdated;

  const SettingsScreen({
    super.key,
    required this.currentUser,
    required this.onProfileUpdated,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _isDarkMode = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _saveBoolSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _handleLogout() async {
    await ModePrefs.setStoreMode(false);
    await _authService.signOut();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔔 알림 토글
          _card(
            child: SwitchListTile(
              title: const Text('알림 설정'),
              value: _notificationsEnabled,
              onChanged: (v) {
                setState(() => _notificationsEnabled = v);
                _saveBoolSetting('notificationsEnabled', v);
              },
              activeColor: Colors.orange[400],
            ),
          ),

          // 🌙 다크 모드
          _card(
            child: SwitchListTile(
              title: const Text('다크 모드'),
              value: _isDarkMode,
              onChanged: (v) {
                setState(() => _isDarkMode = v);
                _saveBoolSetting('isDarkMode', v);
                themeNotifier.value = v ? ThemeMode.dark : ThemeMode.light;
              },
              activeColor: Colors.orange[400],
            ),
          ),

          // 👤 계정 관리
          _card(
            child: _listTile(
              '계정 관리',
                  () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(
                      currentNickname: widget.currentUser['userName'],
                      currentBio: widget.currentUser['bio'],
                    ),
                  ),
                );
                if (result != null && result is Map<String, String>) {
                  widget.onProfileUpdated(result);
                }
              },
            ),
          ),

          // 📢 공지사항
          _card(
            child: _listTile(
              '공지사항',
                  () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AnnouncementsScreen()),
              ),
            ),
          ),

          // ☎️ 고객센터
          _card(
            child: _listTile(
              '고객센터',
                  () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CustomerServiceScreen()),
              ),
            ),
          ),

          // 📑 약관 및 정책
          _card(
            child: _listTile(
              '약관 및 정책',
                  () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TermsAndPoliciesScreen()),
              ),
            ),
          ),

          // 🏪 가게 전환
          _card(
            child: _listTile(
              '가게 전환',
                  () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StoreModeRouter())
              ),
            ),
          ),

          // 🚪 로그아웃
          _card(
            child: ListTile(
              title: const Text('로그아웃', style: TextStyle(color: Colors.red)),
              trailing: const Icon(Icons.chevron_right, color: Colors.red),
              onTap: _handleLogout,
            ),
          ),
        ],
      ),
    );
  }

  /// 단일 아이템용 카드 래퍼 (라운드 + 옅은 테두리 + 리플)
  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.15),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias, // 리플이 둥근 모양 안에서만 보이도록
        child: child,
      ),
    );
  }

  /// 우측 화살표 기본 항목
  Widget _listTile(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      dense: false,
      visualDensity: const VisualDensity(vertical: 0),
    );
  }
}