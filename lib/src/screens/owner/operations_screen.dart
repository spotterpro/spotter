// 📁 lib/src/screens/owner/operations_screen.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spotter/src/screens/owner/reward_management_screen.dart';

class OperationsScreen extends StatelessWidget {
  final String storeId;
  const OperationsScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': '리워드 만들기',
        'icon': FontAwesomeIcons.gift,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => RewardManagementScreen(storeId: storeId))),
      },
      {
        'title': '투어 기획하기',
        'icon': FontAwesomeIcons.mapSigns,
        'onTap': () => _navigateToPlaceholder(context, '투어 기획하기'),
      },
      {
        'title': '광고 관리하기',
        'icon': FontAwesomeIcons.bullhorn,
        'onTap': () => _navigateToPlaceholder(context, '광고 관리하기'),
      },
      {
        'title': '구독 관리',
        'icon': FontAwesomeIcons.creditCard,
        'onTap': () => _navigateToPlaceholder(context, '구독 관리'),
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _OperationMenuCard(
          title: item['title'],
          icon: item['icon'],
          onTap: item['onTap'],
        );
      },
    );
  }

  void _navigateToPlaceholder(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: Center(
            child: Text('$title 화면 준비 중입니다.', style: const TextStyle(fontSize: 18)),
          ),
        ),
      ),
    );
  }
}

class _OperationMenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _OperationMenuCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: Colors.orange.withOpacity(0.1),
          foregroundColor: Colors.orange[800],
          child: FaIcon(icon, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}