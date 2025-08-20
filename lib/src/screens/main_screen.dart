// 📁 lib/src/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  late List<Map<String, dynamic>> _allFeedItems;

  @override
  void initState() {
    super.initState();
    _allFeedItems = [
      {
        'id': 'poll_1',
        'isCertified': true,
        'author': {
          'name': '헬창', 'imageSeed': 'user3', 'levelTitle': 'LV.35', 'uid': 'some_other_uid'
        },
        'time': Timestamp.now(),
        'caption': '주말에 운동 어디로 갈까요?',
        'tags': ['#오운완', '#운동'],
        'poll': {
          'options': [
            { 'text': '헬스 클럽 (수성구)', 'votes': [] },
            { 'text': '요가 스튜디오 (남구)', 'votes': [] },
          ]
        },
      },
      {'id': 'cert_1', 'author': {'name': '스포터', 'imageSeed': 'user1', 'levelTitle': 'LV.15'}, 'storeName': '클린한 세탁소 · 3일 전', 'postImageSeed': 'laundry_feed', 'caption': '세탁 맡겼던 운동화 찾는 날. 새것처럼 깨끗해져서 기분 최고! ✨', 'tags': ['#세탁'], 'isCertified': true, 'time': Timestamp.fromMillisecondsSinceEpoch(DateTime.now().subtract(const Duration(days: 3)).millisecondsSinceEpoch)},
    ];
  }

  void _deleteFeedItem(String id) {
    setState(() {
      _allFeedItems.removeWhere((item) => item['id'] == id);
    });
  }

  void _updateProfile(Map<String, String> newProfile) {
    // TODO: Firestore users 컬렉션 업데이트 로직 필요
    print("프로필 업데이트: $newProfile");
  }

  @override
  Widget build(BuildContext context) {
    final currentUserMap = widget.currentUserProfile.toMap();

    final List<Widget> pages = [
      HomeScreen(
        feedItems: _allFeedItems,
        onDelete: _deleteFeedItem,
        currentUser: currentUserMap,
      ),
      CommunityScreen(currentUser: currentUserMap),
      const StampScreen(),
      UploadFeedScreen(currentUser: currentUserMap),
      MyPageScreen(
        currentUserProfile: widget.currentUserProfile,
        onProfileUpdated: _updateProfile,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home, color: Colors.orange[600]),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people, color: Colors.orange[600]),
            label: '커뮤니티',
          ),
          // --- 형님 지시대로 재수정된 부분 ---
          BottomNavigationBarItem(
            icon: const FaIcon(FontAwesomeIcons.stamp),
            activeIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[600], // 시그니처 배경색
                shape: BoxShape.circle,
              ),
              child: const FaIcon(
                FontAwesomeIcons.stamp,
                color: Colors.white, // 대비되는 아이콘 색상
                size: 20, // 아이콘 크기 조정
              ),
            ),
            label: '스탬프',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add_box_outlined),
            activeIcon: Icon(Icons.add_box, color: Colors.orange[600]),
            label: '피드작성',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person, color: Colors.orange[600]),
            label: '마이페이지',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}