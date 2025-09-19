// features/owner/presentation/screens/owner_main_screen.dart

import 'package:flutter/material.dart';
import 'package:spotter/features/owner/presentation/screens/owner_dashboard_screen.dart';

class OwnerMainScreen extends StatefulWidget {
  final String storeId;
  const OwnerMainScreen({super.key, required this.storeId});

  @override
  State<OwnerMainScreen> createState() => _OwnerMainScreenState();
}

class _OwnerMainScreenState extends State<OwnerMainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      // 대시보드 화면에 storeId를 전달하여 실시간 데이터를 조회하도록 합니다.
      OwnerDashboardScreen(storeId: widget.storeId),
      const Center(child: Text('마케팅/운영 화면')), // 임시 화면
      const Center(child: Text('가게 프로필 화면')), // 임시 화면
      const Center(child: Text('사장님 광장 화면')), // 임시 화면
      const Center(child: Text('메시지 화면')), // 임시 화면
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: '대시보드'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign_outlined), label: '마케팅/운영'),
          BottomNavigationBarItem(icon: Icon(Icons.store_outlined), label: '가게 프로필'),
          BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), label: '사장님 광장'),
          BottomNavigationBarItem(icon: Icon(Icons.message_outlined), label: '메시지'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}