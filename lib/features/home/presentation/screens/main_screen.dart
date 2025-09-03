import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spotter/core/models/user_model.dart';
import 'package:spotter/features/home/presentation/screens/home_screen.dart';
import 'package:spotter/features/community_and_post/presentation/screens/community_screen.dart';
import 'package:spotter/features/stamp_and_tour/presentation/screens/stamp_screen.dart';
import 'package:spotter/features/profile_and_mypage/presentation/screens/mypage_screen.dart';
import 'package:spotter/features/feed/presentation/screens/upload_feed_screen.dart';

// ValueNotifier를 전역으로 선언하여 다른 화면에서도 네비게이션을 제어할 수 있게 합니다.
final mainScreenNavigator = ValueNotifier<int>(0);

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
      HomeScreen(currentUser: currentUserMap),
      CommunityScreen(currentUser: currentUserMap),
      // [아우] 🔥🔥🔥 여기가 마지막 수정 지점입니다! 🔥🔥🔥
      // StampScreen에 currentUserProfile을 전달합니다.
      StampScreen(currentUserProfile: widget.currentUserProfile),
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