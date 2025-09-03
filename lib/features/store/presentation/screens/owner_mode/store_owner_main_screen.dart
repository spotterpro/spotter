import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spotter/core/models/user_model.dart';
import 'package:spotter/core/services/mode_prefs.dart';
import 'package:spotter/core/services/store_mode_service.dart';
import 'package:spotter/features/home/presentation/screens/main_screen.dart';
import 'package:spotter/features/store/presentation/screens/owner_mode/community_screen.dart';
import 'package:spotter/features/store/presentation/screens/owner_mode/dashboard_screen.dart';
import 'package:spotter/features/store/presentation/screens/owner_mode/management_screen.dart';
import 'package:spotter/features/store/presentation/screens/owner_mode/messages_screen.dart';
import 'package:spotter/features/store/presentation/screens/owner_mode/operations_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StoreOwnerMainScreen extends StatefulWidget {
  final User user;
  const StoreOwnerMainScreen({super.key, required this.user});

  @override
  State<StoreOwnerMainScreen> createState() => _StoreOwnerMainScreenState();
}

class _StoreOwnerMainScreenState extends State<StoreOwnerMainScreen> {
  late final StoreModeService _storeModeService;
  int _selectedIndex = 0;
  Map<String, dynamic>? _currentUserMap;
  late List<Widget> _pages;
  final List<String> _pageTitles = const [
    '사장님 대시보드', '가게 운영', '가게 관리', '사장님 광장', '메시지'
  ];

  @override
  void initState() {
    super.initState();
    _storeModeService = StoreModeService(uid: widget.user.uid);
    _fetchCurrentUserAndInitPages();

    _storeModeService.listenForStatusChanges(onDeauthorized: () {
      if (mounted) {
        _exitToUserMode(context);
      }
    });
  }

  Future<void> _fetchCurrentUserAndInitPages() async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).get();
    if(userDoc.exists && mounted) {
      setState(() {
        _currentUserMap = userDoc.data();
        _pages = [
          DashboardScreen(storeId: widget.user.uid),
          OperationsScreen(storeId: widget.user.uid),
          ManagementScreen(storeId: widget.user.uid),
          OwnerCommunityScreen(storeId: widget.user.uid, currentUser: _currentUserMap!),
          OwnerMessagesScreen(storeId: widget.user.uid),
        ];
      });
    }
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
    if (!context.mounted) return;
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
    if (_currentUserMap == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: '대시보드'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: '가게 운영'),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.sliders), label: '가게 관리'),
          BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), activeIcon: Icon(Icons.groups), label: '사장님 광장'),
          BottomNavigationBarItem(icon: Icon(Icons.message_outlined), activeIcon: Icon(Icons.message), label: '메시지'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.orange[800],
        // [아우] 🔥🔥🔥 여기가 핵심 수정 지점입니다! 🔥🔥🔥
        // 잘못된 파라미터 'unselectedLabelColor'를 올바른 'unselectedItemColor'로 수정합니다.
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}