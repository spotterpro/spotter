import 'package:flutter/material.dart';
import 'package:spotter/features/authentication/data/services/auth_service.dart';
import 'package:spotter/features/authentication/presentation/screens/login_screen.dart';
import 'package:spotter/features/user/presentation/screens/crew_studio_screen.dart';
import 'package:spotter/features/user/presentation/screens/growth_record_screen.dart';
import 'package:spotter/features/user/presentation/screens/follow_list_screen.dart';
import 'package:spotter/features/user/presentation/screens/spot_index_info_screen.dart';
import 'package:spotter/features/user/presentation/screens/settings_screen.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: SafeArea(
          child: Column(
            children: [
              _buildProfileHeader(context),
              _buildProfileStats(context),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const CrewStudioScreen()),
                    );
                  },
                  icon: const Icon(Icons.group_work_outlined),
                  label: const Text('크루 스튜디오'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: Colors.grey.shade800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const TabBar(
                tabs: [
                  Tab(text: '피드 (1)'),
                  Tab(text: '작성한 글 (0)'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildPostGrid(),
                    _buildPostGrid(isEmpty: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 40),
              const CircleAvatar(radius: 40, backgroundColor: Colors.grey),
              SizedBox(
                width: 40,
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                  icon: const Icon(Icons.settings_outlined, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('스포터', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('LV.25 동네 탐험가', style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 16),
          _buildXpBar(context),
        ],
      ),
    );
  }

  Widget _buildXpBar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const GrowthRecordScreen(),
            fullscreenDialog: true,
          ),
        );
      },
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('XP: 1530', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text('다음 레벨까지 470 XP', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: 1530 / (1530 + 470),
            backgroundColor: Colors.grey[300],
            color: Colors.orange,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStats(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FollowListScreen(initialIndex: 0))),
            child: _buildStatItem("125", "팔로워"),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FollowListScreen(initialIndex: 1))),
            child: _buildStatItem("3", "팔로잉"),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SpotIndexInfoScreen())),
            child: _buildStatItem("850", "스팟 지수"),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildPostGrid({bool isEmpty = false}) {
    if (isEmpty) {
      return const Center(child: Text('아직 작성한 글이 없습니다.', style: TextStyle(color: Colors.grey)));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 1,
      itemBuilder: (context, index) {
        return Container(
          color: Colors.grey.shade300,
        );
      },
    );
  }
}