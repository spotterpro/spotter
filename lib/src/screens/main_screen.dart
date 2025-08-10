import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
      'levelTitle': 'LV.25 골목대장', 'bio': '동성로 커피는 저에게 물어보세요.',
    };

    _allFeedItems = [
      {'id': 'cert_1', 'userName': '스포터', 'userImageSeed': 'user1', 'storeName': '클린한 세탁소 · 3일 전', 'postImageSeed': 'laundry_feed', 'caption': '세탁 맡겼던 운동화 찾는 날. 새것처럼 깨끗해져서 기분 최고! ✨', 'tags': ['#세탁'], 'likes': 78, 'isCertified': true, 'commentsList': []},
      {'id': 'cert_2', 'userName': '형님', 'userImageSeed': 'myprofile', 'storeName': '맛집 파스타 · 1일 전', 'postImageSeed': 'pasta_feed_my', 'caption': '오늘 저녁은 파스타로 정했다. 다들 맛저!', 'tags': ['#파스타맛집'], 'likes': 99, 'isCertified': true, 'commentsList': []},
      // --- 형님의 요청대로 수정된 부분 ---
      // CommunityScreen이 Firestore를 직접 사용하므로 로컬 목 데이터는 제거합니다.
      // {'id': 'comm_1', 'userName': '형님', 'userImageSeed': 'myprofile', 'storeName': '어제', 'postImageSeed': null, 'caption': '주말에 다들 뭐하시나요? 날씨도 좋은데 좋은 계획 있으시면 공유해주세요!', 'tags': ['#일상', '#수다'], 'likes': 34, 'isCertified': false, 'commentsList': [], 'levelTitle': 'LV.25', 'time': '어제', 'isHot': false},
    ];
  }

  void _deleteFeedItem(String id) {
    setState(() {
      _allFeedItems.removeWhere((item) => item['id'] == id);
    });
  }

  void _updateComments(String id, List<Map<String, dynamic>> newComments) {
    setState(() {
      final index = _allFeedItems.indexWhere((item) => item['id'] == id);
      if (index != -1) {
        _allFeedItems[index]['commentsList'] = newComments;
      }
    });
  }

  void _updatePost(String id, String newCaption) {
    setState(() {
      final index = _allFeedItems.indexWhere((item) => item['id'] == id);
      if (index != -1) {
        _allFeedItems[index]['caption'] = newCaption;
      }
    });
  }

  void _updateProfile(Map<String, String> newProfile) {
    setState(() {
      _currentUser['userName'] = newProfile['nickname']!;
      _currentUser['bio'] = newProfile['bio']!;
      for (var item in _allFeedItems) {
        if (item['id'] == 'cert_2' || item['id'] == 'comm_1') {
          item['userName'] = newProfile['nickname']!;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeFeeds = _allFeedItems.where((i) => i['isCertified'] == true).toList();
    // CommunityScreen이 직접 Firestore 데이터를 사용하므로 이 변수는 더 이상 필요 없습니다.
    // final communityFeeds = _allFeedItems.where((i) => i['isCertified'] == false).toList();
    final myCertifiedFeeds = _allFeedItems.where((i) => i['userName'] == '형님' && i['isCertified'] == true).toList();
    final myCommunityFeeds = _allFeedItems.where((i) => i['userName'] == '형님' && i['isCertified'] == false).toList();

    final List<Widget> pages = [
      HomeScreen(
        feedItems: homeFeeds,
        onDelete: _deleteFeedItem,
        onCommentsUpdated: _updateComments,
      ),
      // --- 형님의 요청대로 수정된 부분 ---
      // CommunityScreen을 파라미터 없이 호출합니다.
      const CommunityScreen(),
      const UploadFeedScreen(),
      const StampScreen(),
      MyPageScreen(
        currentUser: _currentUser,
        certifiedFeeds: myCertifiedFeeds,
        communityFeeds: myCommunityFeeds,
        onDelete: _deleteFeedItem,
        onCommentsUpdated: _updateComments,
        onProfileUpdated: _updateProfile,
        onPostUpdated: _updatePost,
      ),
    ];
    // --- 여기까지 수정되었습니다 ---

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