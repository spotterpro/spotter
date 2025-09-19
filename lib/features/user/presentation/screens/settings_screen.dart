// SettingsScreen.dart - '라우터' 연결 최종본

import 'package:flutter/material.dart';
import 'package:spotter/features/authentication/data/services/auth_service.dart';
import 'package:spotter/features/authentication/presentation/screens/login_screen.dart';
// [수정] 우리가 만든 '중앙 관제소(라우터)'를 import 합니다.
import 'package:spotter/features/owner/presentation/screens/owner_mode_router_screen.dart';
import 'package:spotter/features/policy/presentation/screens/policies_screen.dart';
import 'package:spotter/features/theme/data/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // [제거] 더 이상 필요 없는 중복 로직 함수를 완전히 삭제합니다.
  // Future<DocumentSnapshot?> _getStoreApplication() async { ... }

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
                  // [수정] 복잡한 로직을 모두 제거하고 '라우터'를 호출하는 한 줄로 변경
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const OwnerModeRouterScreen()));
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
              'Spotter v1.0.0', // 버전 정보는 필요에 따라 수정하시면 됩니다.
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  // --- 이하 UI 빌드 메서드들은 기존 코드와 동일합니다 ---

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
          _buildInfoRow('주소', '대구광역시 동구 동대구로 590'),
          _buildInfoRow('통신판매업신고번호', '제2025-대구동구-0918호'),
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