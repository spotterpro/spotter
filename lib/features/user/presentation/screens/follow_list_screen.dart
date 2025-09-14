import 'package:flutter/material.dart';
import 'package:spotter/features/user/presentation/screens/user_profile_screen.dart'; // [추가]

class FollowListScreen extends StatelessWidget {
  const FollowListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('스포터', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: '125 팔로워'),
              Tab(text: '3 팔로잉'),
            ],
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
          ),
        ),
        body: TabBarView(
          children: [
            _buildUserListView(context: context, isFollower: true), // context 전달
            _buildUserListView(context: context, isFollower: false), // context 전달
          ],
        ),
      ),
    );
  }

  Widget _buildUserListView({required BuildContext context, required bool isFollower}) {
    return ListView.builder(
      itemCount: isFollower ? 125 : 3,
      itemBuilder: (context, index) {
        // [수정] ListTile과 InkWell을 사용하여 탭 효과와 네비게이션 기능을 추가합니다.
        return InkWell(
          onTap: () {
            // 탭하면 유저 프로필 화면으로 이동합니다.
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const UserProfileScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const CircleAvatar(radius: 24, backgroundColor: Colors.grey),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('먹깨비', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('LV.50 도시 개척자', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                isFollower
                    ? OutlinedButton(onPressed: () {}, child: const Text('삭제'), style: OutlinedButton.styleFrom(foregroundColor: Colors.grey))
                    : FilledButton(onPressed: () {}, child: const Text('팔로잉'), style: FilledButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black)),
              ],
            ),
          ),
        );
      },
    );
  }
}