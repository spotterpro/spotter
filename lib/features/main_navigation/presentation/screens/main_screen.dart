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
          // [수정] 스탬프 아이콘을 도장(인증) 모양으로 변경했습니다.
          BottomNavigationBarItem(
            icon: Icon(Icons.approval_outlined),
            activeIcon: Icon(Icons.approval),
            label: '스탬프',
          ),
          // [수정] 글쓰기 아이콘을 '+' 모양으로, 라벨을 '피드작성'으로 변경했습니다.
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
        selectedItemColor: const Color(0xFFFFA726),
        onTap: _onItemTapped,
        showUnselectedLabels: true,
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 5,
      ),
    );
  }
}