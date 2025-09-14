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
      body: _widgetOptions.elementAt(_selectedIndex),
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
        // 테마에서 색상 등을 관리하므로 개별 속성 지정 최소화
      ),
    );
  }
}