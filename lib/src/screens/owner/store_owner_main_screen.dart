// 📁 lib/src/screens/owner/store_owner_main_screen.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spotter/src/screens/owner/community_screen.dart';
import 'package:spotter/src/screens/owner/dashboard_screen.dart';
import 'package:spotter/src/screens/owner/management_screen.dart';
import 'package:spotter/src/screens/owner/messages_screen.dart';
import 'package:spotter/src/screens/owner/operations_screen.dart';

class StoreOwnerMainScreen extends StatefulWidget {
  final String storeId;

  const StoreOwnerMainScreen({
    super.key,
    required this.storeId,
  });

  @override
  State<StoreOwnerMainScreen> createState() => _StoreOwnerMainScreenState();
}

class _StoreOwnerMainScreenState extends State<StoreOwnerMainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardScreen(storeId: widget.storeId),
      OperationsScreen(storeId: widget.storeId),
      ManagementScreen(storeId: widget.storeId),
      OwnerCommunityScreen(storeId: widget.storeId),
      OwnerMessagesScreen(storeId: widget.storeId),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: '대시보드',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: '가게 운영',
          ),
          // 🔥🔥🔥 --- 바로 이 부분입니다, 형님! --- 🔥🔥🔥
          // 'sliders'를 올바른 아이콘 이름인 'slidersH'로 수정했습니다.
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.slidersH),
            activeIcon: FaIcon(FontAwesomeIcons.slidersH),
            label: '가게 관리',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            activeIcon: Icon(Icons.groups),
            label: '사장님 광장',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            activeIcon: Icon(Icons.message),
            label: '메시지',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.orange[800],
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}