import 'package:flutter/material.dart';
import 'package:spotter/features/user/presentation/screens/follow_list_screen.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '먹깨비님의 프로필',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: DefaultTabController(
        length: 1,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(child: _buildProfileHeader(context)),
              SliverPersistentHeader(
                delegate: _StickyHeaderDelegate(
                  TabBar(
                    tabs: const [Tab(text: '활동 피드')],
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            children: [_buildUserFeedGrid()],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey,
          ),
          const SizedBox(height: 12),
          const Text('먹깨비', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('LV.50 도시 개척자', style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 20),
          _buildProfileStats(context),
          const SizedBox(height: 20),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildProfileStats(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FollowListScreen(initialIndex: 0))),
          child: _buildStatItem("2,300", "팔로워"),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FollowListScreen(initialIndex: 1))),
          child: _buildStatItem("150", "팔로잉"),
        ),
        _buildStatItem("9,800", "영향력"),
      ],
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA726),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('팔로우', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: const Text('메시지 보내기'),
          ),
        ),
      ],
    );
  }

  Widget _buildUserFeedGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 15,
      itemBuilder: (context, index) {
        return Container(
          color: Colors.grey.shade300,
        );
      },
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _StickyHeaderDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}