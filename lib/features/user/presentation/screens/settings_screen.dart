import 'package:flutter/material.dart';
import 'package:spotter/features/authentication/data/services/auth_service.dart';
import 'package:spotter/features/authentication/presentation/screens/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('설정', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: 16),
                _buildMenuTile(title: '알림 설정', onTap: () {}),
                _buildMenuTile(title: '계정 관리', onTap: () {}),
                const SizedBox(height: 16),
                _buildMenuTile(title: '공지사항', onTap: () {}),
                _buildMenuTile(title: '고객센터', onTap: () {}),
                const SizedBox(height: 16),
                _buildMenuTile(title: '가게 전환', onTap: () {}),
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
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Spotter v1.2.0', // TODO: 앱 버전 동적으로 가져오기
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  // 메뉴 항목을 만드는 Helper 위젯
  Widget _buildMenuTile({required String title, required VoidCallback onTap, Color? textColor, bool hideArrow = false}) {
    return ListTile(
      title: Text(title, style: TextStyle(color: textColor ?? Colors.black)),
      trailing: hideArrow ? null : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  // 로그아웃 확인 다이얼로그
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
                  // 로그인 화면으로 이동하고, 이전의 모든 화면을 스택에서 제거
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
}