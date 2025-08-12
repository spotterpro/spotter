// 📁 lib/src/screens/settings_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotter/main.dart';
import 'package:spotter/services/auth.dart';
import 'package:spotter/src/screens/announcements_screen.dart';
import 'package:spotter/src/screens/application_status_screen.dart';
import 'package:spotter/src/screens/customer_service_screen.dart';
import 'package:spotter/src/screens/edit_profile_screen.dart';
import 'package:spotter/src/screens/owner/store_management_screen.dart'; // 👑 추가된 부분
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

  // --- 👑 형님의 요청대로 전면 수정된 부분 ---
  Future<void> _navigateToStoreSwitch() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 1. 이미 등록된 가게가 있는지 먼저 확인합니다.
    final storeDoc = await FirebaseFirestore.instance.collection('stores').doc(user.uid).get();

    if (mounted) {
      if (storeDoc.exists) {
        // 가게가 존재하면, 바로 가게 관리 대시보드로 이동합니다.
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StoreManagementScreen(storeId: user.uid)),
        );
      } else {
        // 가게가 없으면, 기존 로직대로 입점 신청 상태를 확인합니다.
        final applicationDoc = await FirebaseFirestore.instance
            .collection('store_applications')
            .doc(user.uid)
            .get();

        if (applicationDoc.exists) {
          // 신청 기록이 있으면 -> 신청 현황 화면으로
          final status = applicationDoc.data()?['status'] ?? 'pending';
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ApplicationStatusScreen(status: status, storeId: applicationDoc.id),
            ),
          );
        } else {
          // 신청 기록도 없으면 -> 신청서 작성 화면으로
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StoreSwitchScreen()),
          );
        }
      }
    }
  }

  Future<void> _handleLogout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

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