// 📁 lib/src/screens/owner/store_owner_main_screen.dart (최종 수정본)

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spotter/main.dart'; // 🔥 AuthWrapper를 사용하기 위해 main.dart를 import 합니다.
import 'package:spotter/services/mode_prefs.dart';
import 'package:spotter/services/store_mode_service.dart';
import 'package:spotter/src/screens/owner/community_screen.dart';
import 'package:spotter/src/screens/owner/dashboard_screen.dart';
import 'package:spotter/src/screens/owner/management_screen.dart';
import 'package:spotter/src/screens/owner/messages_screen.dart';
import 'package:spotter/src/screens/owner/operations_screen.dart';

class StoreOwnerMainScreen extends StatefulWidget {
  final User user;
  const StoreOwnerMainScreen({super.key, required this.user});

  @override
  State<StoreOwnerMainScreen> createState() => _StoreOwnerMainScreenState();
}

class _StoreOwnerMainScreenState extends State<StoreOwnerMainScreen> {
  late final StoreModeService _storeModeService;
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _storeModeService = StoreModeService(uid: widget.user.uid);
    _storeModeService.listenForStatusChanges(onDeauthorized: () {
      if (mounted) {
        ModePrefs.setStoreMode(false).then((_) {
          Navigator.of(context).pushAndRemoveUntil(
            // 🔥🔥🔥 --- 바로 이 부분입니다, 형님! --- 🔥🔥🔥
            // 존재하지 않는 RoutingGuard 대신, 앱의 실제 시작점인 AuthWrapper를 호출합니다.
            MaterialPageRoute(builder: (_) => AuthWrapper(user: widget.user)),
                (route) => false,
          );
        });
      }
    });

    _pages = [
      DashboardScreen(storeId: widget.user.uid),
      OperationsScreen(storeId: widget.user.uid),
      ManagementScreen(storeId: widget.user.uid),
      OwnerCommunityScreen(storeId: widget.user.uid),
      OwnerMessagesScreen(storeId: widget.user.uid),
    ];
  }

  @override
  void dispose() {
    _storeModeService.dispose();
    super.dispose();
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