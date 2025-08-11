// 📁 lib/src/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'community_screen.dart';
import 'stamp_screen.dart';
import 'mypage_screen.dart';
import 'upload_feed_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late List<Map<String, dynamic>> _allFeedItems;
  late Map<String, dynamic> _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = {
      'userName': '형님', 'userImageSeed': 'myprofile',
      'levelTitle': 'LV.25',
      'bio': '동성로 커피는 저에게 물어보세요.',
    };

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
      {'id': 'cert_2', 'author': {'name': '형님', 'imageSeed': 'myprofile', 'levelTitle': 'LV.25'}, 'storeName': '맛집 파스타 · 1일 전', 'postImageSeed': 'pasta_feed_my', 'caption': '오늘 저녁은 파스타로 정했다. 다들 맛저!', 'tags': ['#파스타맛집'], 'isCertified': true, 'time': Timestamp.fromMillisecondsSinceEpoch(DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch)},
    ];
  }

  void _deleteFeedItem(String id) {
    setState(() {
      _allFeedItems.removeWhere((item) => item['id'] == id);
    });
  }

  void _updateProfile(Map<String, String> newProfile) {
    setState(() {
      _currentUser['userName'] = newProfile['nickname']!;
      _currentUser['bio'] = newProfile['bio']!;
      for (var item in _allFeedItems) {
        if (item['author']?['name'] == '형님') {
          item['author']['name'] = newProfile['nickname']!;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(
        feedItems: _allFeedItems, // 홈스크린에 전체 목업 데이터 전달
        onDelete: _deleteFeedItem,  // 삭제 함수 정상적으로 전달
      ),
      CommunityScreen(currentUser: _currentUser),
      UploadFeedScreen(currentUser: _currentUser),
      const StampScreen(),
      MyPageScreen(
        currentUser: _currentUser,
        onProfileUpdated: _updateProfile,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: '커뮤니티'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), activeIcon: Icon(Icons.add_box), label: '피드작성'),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.stamp), activeIcon: FaIcon(FontAwesomeIcons.stamp), label: '스탬프'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: '마이페이지'),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.orange[600],
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}