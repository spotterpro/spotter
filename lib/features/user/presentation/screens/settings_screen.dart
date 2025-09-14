import 'package:flutter/material.dart';
import 'package:spotter/features/authentication/data/services/auth_service.dart';
import 'package:spotter/features/authentication/presentation/screens/login_screen.dart';
import 'package:spotter/features/owner/presentation/screens/store_application_screen.dart';
import 'package:spotter/features/policy/presentation/screens/policies_screen.dart';
import 'package:spotter/features/theme/data/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('설정', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: 16),
                _buildDarkModeTile(context, isDarkMode),
                _buildMenuTile(title: '알림 설정', onTap: () {}),
                _buildMenuTile(title: '계정 관리', onTap: () {}),
                const SizedBox(height: 16),
                _buildMenuTile(title: '공지사항', onTap: () {}),
                _buildMenuTile(title: '고객센터', onTap: () {}),
                _buildMenuTile(
                  title: '약관 및 정책',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PoliciesScreen())),
                ),
                const SizedBox(height: 16),
                _buildMenuTile(
                  title: '가게 전환',
                  onTap: () {
                    // 가게 심사 신청 화면으로 이동
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const StoreApplicationScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildMenuTile(
                  title: '로그아웃',
                  onTap: () => _showLogoutDialog(context),
                  textColor: Colors.red,
                  hideArrow: true,
                ),
              ],
            ),
          ),
          _buildBusinessInfo(),
          const Padding(
            padding: EdgeInsets.only(bottom: 20.0),
            child: Text(
              'Spotter v1.2.0',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkModeTile(BuildContext context, bool isDarkMode) {
    return ListTile(
      leading: Icon(isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
      title: const Text('다크 모드'),
      trailing: Switch(
        value: isDarkMode,
        onChanged: (value) {
          themeProvider.toggleTheme(value);
        },
        activeColor: Colors.orange,
      ),
    );
  }

  Widget _buildMenuTile({required String title, required VoidCallback onTap, Color? textColor, bool hideArrow = false}) {
    return ListTile(
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: hideArrow ? null : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('정말 로그아웃 하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('로그아웃'),
              onPressed: () async {
                await AuthService().signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (Route<dynamic> route) => false,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildBusinessInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 16),
          _buildInfoRow('사업자명', '스포터 (Spotter)'),
          _buildInfoRow('대표', '형님'),
          _buildInfoRow('사업자등록번호', '000-00-00000'),
          _buildInfoRow('주소', '대구광역시 중구 국채보상로 123'),
          _buildInfoRow('통신판매업신고번호', '제2025-대구중구-0913호'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text.rich(
        TextSpan(
          style: const TextStyle(color: Colors.grey, fontSize: 12),
          children: [
            TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: content),
          ],
        ),
      ),
    );
  }
}