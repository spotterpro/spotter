// 📁 lib/src/screens/settings_screen.dart (최종 수정본)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotter/main.dart';
import 'package:spotter/services/auth.dart';
import 'package:spotter/services/mode_prefs.dart'; // ModePrefs import
import 'package:spotter/src/screens/announcements_screen.dart';
import 'package:spotter/src/screens/application_status_screen.dart';
import 'package:spotter/src/screens/customer_service_screen.dart';
import 'package:spotter/src/screens/edit_profile_screen.dart';
import 'package:spotter/src/screens/owner/store_owner_main_screen.dart';
import 'package:spotter/src/screens/store_switch_screen.dart';
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
  // ...(initState 등 다른 코드는 모두 동일)...
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
    prefs.setBool(key, value);
  }


  // 🔥🔥🔥 --- 바로 이 부분입니다, 형님! --- 🔥🔥🔥
  Future<void> _navigateToStoreSwitch() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final storeDoc = await FirebaseFirestore.instance.collection('stores').doc(user.uid).get();

    if (mounted) {
      // 1. 가게 문서가 존재하고, NFC 등록까지 완료되었는지 확인
      if (storeDoc.exists && storeDoc.data()?['nfcEnabled'] == true) {
        // 2. '가게 주인 신분증'을 발급합니다.
        await ModePrefs.setStoreMode(true);

        // 3. 가게 모드 메인 화면으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StoreOwnerMainScreen(user: user)),
        );
      } else {
        // 4. 조건 미충족 시, 기존 신청/등록 절차 진행
        final applicationDoc = await FirebaseFirestore.instance
            .collection('store_applications')
            .doc(user.uid)
            .get();

        if (applicationDoc.exists) {
          final status = applicationDoc.data()?['status'] ?? 'pending';
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ApplicationStatusScreen(status: status, storeId: applicationDoc.id),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StoreSwitchScreen()),
          );
        }
      }
    }
  }

  Future<void> _handleLogout() async {
    // 🔥 로그아웃 시, 신분증을 파기합니다.
    await ModePrefs.setStoreMode(false);
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  // ...(build 메소드 등 이하 모든 코드는 기존과 동일)...
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection(
            children: [
              SwitchListTile(
                title: const Text('알림 설정'),
                value: _notificationsEnabled,
                onChanged: (bool value) {
                  setState(() { _notificationsEnabled = value; });
                  _saveBoolSetting('notificationsEnabled', value);
                },
                activeColor: Colors.orange[400],
              ),
              const Divider(height: 1, indent: 16),
              SwitchListTile(
                title: const Text('다크 모드'),
                value: _isDarkMode,
                onChanged: (bool value) {
                  setState(() { _isDarkMode = value; });
                  _saveBoolSetting('isDarkMode', value);
                  themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                },
                activeColor: Colors.orange[400],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSection(
              children: [
                _buildSettingsItem(context, '계정 관리', () async {
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen(
                    currentNickname: widget.currentUser['userName'],
                    currentBio: widget.currentUser['bio'],
                  )));
                  if (result != null && result is Map<String, String>) {
                    widget.onProfileUpdated(result);
                  }
                }),
              ]
          ),
          const SizedBox(height: 12),
          _buildSection(
              children: [
                _buildSettingsItem(context, '공지사항', () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AnnouncementsScreen()));
                }),
                const Divider(height: 1, indent: 16),
                _buildSettingsItem(context, '고객센터', () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomerServiceScreen()));
                }),
                const Divider(height: 1, indent: 16),
                _buildSettingsItem(context, '약관 및 정책', () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsAndPoliciesScreen()));
                }),
              ]
          ),
          const SizedBox(height: 12),
          _buildSection(
              children: [
                _buildSettingsItem(context, '가게 전환', _navigateToStoreSwitch),
              ]
          ),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('로그아웃', style: TextStyle(color: Colors.red)),
            onTap: _handleLogout,
            tileColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}