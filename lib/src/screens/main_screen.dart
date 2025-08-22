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
  // _allFeedItems는 HomeScreen으로 전달되므로, 여기서는 더 이상 필요하지 않습니다.
  // late List<Map<String, dynamic>> _allFeedItems;

  @override
  void initState() {
    super.initState();
    final currentUserMap = widget.currentUserProfile.toMap();

    // --- 🔥🔥🔥 수정된 부분: 페이지 목록을 5개로 정확하게 맞춥니다. ---
    _pages = [
      // 페이지 0: 홈
      HomeScreen(
        feedItems: const [], // 피드 데이터는 HomeScreen 자체에서 불러오는 것이 좋습니다.
        onDelete: (id) {},
        currentUser: currentUserMap,
      ),
      // 페이지 1: 커뮤니티
      CommunityScreen(currentUser: currentUserMap),
      // 페이지 2: 스탬프
      const StampScreen(),
      // 페이지 3: 피드작성 (IndexedStack용 빈 컨테이너, 실제 화면은 onTap에서 처리)
      Container(),
      // 페이지 4: 마이페이지
      MyPageScreen(
        currentUserProfile: widget.currentUserProfile,
        onProfileUpdated: _updateProfile,
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
    // 탭 인덱스가 범위 내에 있을 때만 상태를 변경합니다.
    if (mounted && mainScreenNavigator.value >= 0 && mainScreenNavigator.value < _pages.length) {
      _onItemTapped(mainScreenNavigator.value);
    }
  }

  void _updateProfile(Map<String, String> newProfile) {
    // TODO: Firestore users 컬렉션 업데이트 로직 필요
    print("프로필 업데이트: $newProfile");
  }

  void _onItemTapped(int index) {
    // 탭 인덱스 3이 피드 작성이므로 분기 처리
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