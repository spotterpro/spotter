// features/main_navigation/presentation/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:spotter/features/community/presentation/screens/community_screen.dart';
import 'package:spotter/features/map/presentation/screens/map_screen.dart';
import 'package:spotter/features/stamp/presentation/screens/stamp_screen.dart';
import 'package:spotter/features/user/presentation/screens/my_page_screen.dart';
import 'package:spotter/features/write_post/presentation/screens/write_post_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    MapScreen(),
    CommunityScreen(),
    StampScreen(),
    WritePostScreen(),
    MyPageScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
        title: const Text('Spotter', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 1,
        centerTitle: false,
        actions: [
          // [추가] 누락되었던 메시지 버튼을 복원했습니다.
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              // TODO: 채팅 화면으로 이동하는 로직 구현
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {
              // TODO: 알림 화면으로 이동하는 로직 구현
            },
          ),
        ],
      )
          : null,
      body: SafeArea(
        // 홈 탭이 아닐 때 상단 시스템 UI 침범 방지
        top: _selectedIndex != 0,
        child: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            activeIcon: Icon(Icons.groups),
            label: '커뮤니티',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.approval_outlined),
            activeIcon: Icon(Icons.approval),
            label: '스탬프',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: '피드작성',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '마이페이지',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}