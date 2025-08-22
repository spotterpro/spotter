// 📁 lib/src/screens/owner/store_owner_main_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spotter/services/mode_prefs.dart';
import 'package:spotter/services/store_mode_service.dart';
import 'package:spotter/src/screens/owner/community_screen.dart';
import 'package:spotter/src/screens/owner/dashboard_screen.dart';
import 'package:spotter/src/screens/owner/management_screen.dart';
import 'package:spotter/src/screens/owner/messages_screen.dart';
import 'package:spotter/src/screens/owner/operations_screen.dart';

// --- 🔥🔥🔥 수정된 부분: 누락되었던 import들을 추가합니다. ---
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/models/user_model.dart';
import 'package:spotter/src/screens/main_screen.dart';


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
  final List<String> _pageTitles = [
    '사장님 대시보드',
    '가게 운영',
    '가게 관리',
    '사장님 광장',
    '메시지'
  ];

  @override
  void initState() {
    super.initState();
    _storeModeService = StoreModeService(uid: widget.user.uid);
    _storeModeService.listenForStatusChanges(onDeauthorized: () {
      if (mounted) {
        _exitToUserMode(context);
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

  Future<void> _exitToUserMode(BuildContext context) async {
    await ModePrefs.setStoreMode(false);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && context.mounted) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists && context.mounted) {
        final userProfile = UserProfile.fromDocument(userDoc);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => MainScreen(currentUserProfile: userProfile)),
              (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_pageTitles[_selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: '사용자 모드로 전환',
            onPressed: () => _exitToUserMode(context),
          ),
        ],
      ),
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
          // --- 🔥🔥🔥 수정된 부분: 아이콘 이름을 slidersH로 변경합니다. ---
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