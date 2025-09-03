import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:spotter/main.dart'; // [아우] 더 이상 필요 없으므로 이 import를 제거합니다.
import 'package:spotter/core/services/auth.dart';
import 'package:spotter/core/services/mode_prefs.dart';
import 'package:spotter/features/general/presentation/screens/announcements_screen.dart';
import 'package:spotter/features/general/presentation/screens/customer_service_screen.dart';
import 'package:spotter/features/profile_and_mypage/presentation/screens/edit_profile_screen.dart';
import 'package:spotter/app/navigation/store_mode_router.dart';
import 'package:spotter/features/general/presentation/screens/terms_and_policies_screen.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

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
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initSettings();
  }

  Future<void> _initSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = _prefs.getBool('notificationsEnabled') ?? true;
      _isDarkMode = _prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _saveBoolSetting(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  // [아우] 🔥🔥🔥 여기가 진짜 최종 수정 지점! 🔥🔥🔥
  // 가장 단순하고 올바른 방식으로 로그아웃 로직을 수정했습니다.
  Future<void> _handleLogout() async {
    // 1. 상태 변경 (로그아웃, 모드 초기화)
    await _authService.signOut();
    await ModePrefs.setStoreMode(false);

    // 2. 위젯 마운트 확인
    if (!mounted) return;

    // 3. 현재까지 쌓인 모든 화면을 닫고 첫 화면으로 돌아간다.
    //    그러면 main.dart의 StreamBuilder가 로그아웃 상태를 감지하고 LoginScreen을 보여줍니다.
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
          _card(
            child: _listTile('계정 관리', () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(
                    currentNickname: widget.currentUser['nickname'] ?? '',
                    currentBio: widget.currentUser['bio'] ?? '',
                  ),
                ),
              );
              if (result != null && result is Map<String, String>) {
                widget.onProfileUpdated(result);
              }
            }),
          ),
          _card(
            child: _listTile('공지사항', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnnouncementsScreen()))),
          ),
          _card(
            child: _listTile('고객센터', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerServiceScreen()))),
          ),
          _card(
            child: _listTile('약관 및 정책', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsAndPoliciesScreen()))),
          ),
          _card(
            child: _listTile('가게 전환', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StoreModeRouter()))),
          ),
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
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }

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