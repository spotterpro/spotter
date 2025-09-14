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
      backgroundColor: Colors.white,
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
                    // 크루 스튜디오 화면으로 이동
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
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black,
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildPostGrid(), // '피드' 탭 뷰
                    _buildPostGrid(isEmpty: true), // '작성한 글' 탭 뷰 (예시로 비워둠)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 프로필 상단 헤더
  Widget _buildProfileHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 40), // 왼쪽 공간 확보용
              const CircleAvatar(radius: 40, backgroundColor: Colors.grey),
              SizedBox(
                width: 40,
                child: IconButton(
                  onPressed: () {
                    // 설정 화면으로 이동
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

  // 경험치 바
  Widget _buildXpBar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 나의 성장 기록 화면으로 이동
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
            backgroundColor: Colors.grey[200],
            color: Colors.orange,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  // 프로필 스탯
  Widget _buildProfileStats(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              // 팔로워/팔로잉 목록 화면으로 이동
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FollowListScreen()));
            },
            child: _buildStatItem("125", "팔로워"),
          ),
          GestureDetector(
            onTap: () {
              // 팔로워/팔로잉 목록 화면으로 이동
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FollowListScreen()));
            },
            child: _buildStatItem("3", "팔로잉"),
          ),
          GestureDetector(
            onTap: () {
              // 스팟 지수 상세 정보 화면으로 이동
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SpotIndexInfoScreen()));
            },
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

  // 게시물 그리드
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
      itemCount: 1, // 예시 아이템 개수
      itemBuilder: (context, index) {
        return Container(
          color: Colors.grey.shade300,
        );
      },
    );
  }
}