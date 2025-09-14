import 'package:flutter/material.dart';
import 'package:spotter/features/user/presentation/screens/user_profile_screen.dart';

class FollowListScreen extends StatelessWidget {
  final int initialIndex;

  const FollowListScreen({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: initialIndex,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('스포터', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: '125 팔로워'),
              Tab(text: '3 팔로잉'),
            ],
            indicatorColor: Colors.orange,
            labelColor: Colors.orange,
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: TabBarView(
          children: [
            _buildUserListView(context: context, isFollower: true),
            _buildUserListView(context: context, isFollower: false),
          ],
        ),
      ),
    );
  }

  Widget _buildUserListView({required BuildContext context, required bool isFollower}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      itemCount: isFollower ? 125 : 3,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
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
                    : FilledButton(
                  onPressed: () {},
                  child: const Text('팔로잉'),
                  style: FilledButton.styleFrom(
                    backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                    foregroundColor: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}