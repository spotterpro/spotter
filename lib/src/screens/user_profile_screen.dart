import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              pinned: false,
              expandedHeight: 340.0, // 공간을 넉넉하게 늘렸습니다.
              flexibleSpace: FlexibleSpaceBar(
                background: _buildProfileHeader(context),
              ),
            ),
            SliverPersistentHeader(
              delegate: _TabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).textTheme.bodyLarge?.color,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Theme.of(context).textTheme.bodyLarge?.color,
                  tabs: const [
                    Tab(text: '인증 피드 (3)'),
                    Tab(text: '작성한 글 (2)'),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPhotoGrid(),
            _buildTextFeed(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.all(16.0).copyWith(top: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage('https://picsum.photos/seed/user1/200/200'),
          ),
          const SizedBox(height: 12),
          const Text('스포터', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('LV.25 동네 탐험가', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // --- 형님의 요청대로 용어를 수정했습니다 ---
              _ProfileStat(count: '125', label: '크루원'),
              _ProfileStat(count: '42', label: '나의 크루'),
              _ProfileStat(count: '850', label: '영향력'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('팔로우'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('메시지 보내기'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPhotoGrid() {
    final photos = ['laundry_feed', 'pasta_feed', 'cafe1'];
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network('https://picsum.photos/seed/${photos[index]}/300/300', fit: BoxFit.cover),
        );
      },
    );
  }

  Widget _buildTextFeed() {
    return const Center(child: Text("작성한 글 목록이 여기에 표시됩니다."));
  }
}

class _ProfileStat extends StatelessWidget {
  final String count;
  final String label;
  const _ProfileStat({required this.count, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate(this.tabBar);
  final TabBar tabBar;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).cardColor,
      child: tabBar,
    );
  }
  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return false;
  }
}