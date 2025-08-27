// 📁 lib/src/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spotter/main.dart';
import 'package:spotter/models/user_model.dart';
import 'home_screen.dart';
import 'community_screen.dart';
import 'stamp_screen.dart';
import 'mypage_screen.dart';
import 'upload_feed_screen.dart';

class MainScreen extends StatefulWidget {
  final UserProfile currentUserProfile;

  const MainScreen({
    super.key,
    required this.currentUserProfile,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    final currentUserMap = widget.currentUserProfile.toMap();

    _pages = [
      // --- 🔥🔥🔥 수정된 부분: HomeScreen이 스스로 데이터를 가져오도록 변경 ---
      HomeScreen(currentUser: currentUserMap),
      CommunityScreen(currentUser: currentUserMap),
      const StampScreen(),
      Container(), // 피드 작성 탭을 위한 빈 컨테이너
      MyPageScreen(
        currentUserProfile: widget.currentUserProfile,
      ),
    ];

    mainScreenNavigator.addListener(_onNavigate);
  }

  @override
  void dispose() {
    mainScreenNavigator.removeListener(_onNavigate);
    super.dispose();
  }

  void _onNavigate() {
    if (mounted && mainScreenNavigator.value >= 0 && mainScreenNavigator.value < 5 && mainScreenNavigator.value != 3) {
      _onItemTapped(mainScreenNavigator.value);
    }
  }

  void _onItemTapped(int index) {
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UploadFeedScreen(currentUser: widget.currentUserProfile.toMap())),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
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
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: '커뮤니티',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.stamp),
            label: '스탬프',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
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
        selectedItemColor: Colors.orange[800],
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}