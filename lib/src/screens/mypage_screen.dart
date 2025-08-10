import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/src/screens/crew_studio_screen.dart';
import 'package:spotter/src/screens/edit_profile_screen.dart';
import 'package:spotter/src/screens/my_growth_log_screen.dart';
import 'package:spotter/src/screens/post_detail_screen.dart';
import 'package:spotter/src/screens/settings_screen.dart';
import 'package:spotter/src/widgets/feed_card.dart';

class MyPageScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  final List<Map<String, dynamic>> certifiedFeeds;
  final List<Map<String, dynamic>> communityFeeds;
  final Function(String) onDelete;
  final Function(String, List<Map<String, dynamic>>) onCommentsUpdated;
  final Function(Map<String, String>) onProfileUpdated;
  final Function(String, String) onPostUpdated;

  const MyPageScreen({
    super.key,
    required this.currentUser,
    required this.certifiedFeeds,
    required this.communityFeeds,
    required this.onDelete,
    required this.onCommentsUpdated,
    required this.onProfileUpdated,
    required this.onPostUpdated,
  });

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> with TickerProviderStateMixin {
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
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverToBoxAdapter(child: _buildProfileHeader(context)),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  controller: _tabController,
                  // ✅ 반반 정확히: 탭이 화면을 균등 분할
                  isScrollable: false,
                  // ✅ 인디케이터가 탭 전체 폭(=화면의 1/2)로 표시
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(width: 3, color: primary),
                  ),
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                  tabs: const [
                    // ✅ 숫자 제거
                    Tab(text: '인증 피드'),
                    Tab(text: '작성한 글'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildCertifiedFeed(),
            _buildWrittenPosts(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.all(16.0).copyWith(top: 50, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                  'https://picsum.photos/seed/${widget.currentUser['userImageSeed']}/200/200',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.currentUser['userName'],
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(widget.currentUser['levelTitle'],
                        style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsScreen(
                        currentUser: widget.currentUser,
                        onProfileUpdated: widget.onProfileUpdated,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.currentUser['bio'] != null && widget.currentUser['bio'].isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                widget.currentUser['bio'],
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCertifiedFeed() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8,
      ),
      itemCount: widget.certifiedFeeds.length,
      itemBuilder: (context, index) {
        final item = widget.certifiedFeeds[index];
        return InkWell(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PostDetailScreen(item: item)),
            );
            if (result == 'deleted') {
              widget.onDelete(item['id']);
            } else if (result is Map) {
              widget.onPostUpdated(item['id'], result['caption']);
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              'https://picsum.photos/seed/${item['postImageSeed']}/300/300',
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  Widget _buildWrittenPosts() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('userName', isEqualTo: widget.currentUser['userName'])
          .where('isCertified', isEqualTo: false)
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('작성한 글이 없습니다.'));
        }
        final docs = snapshot.data!.docs;
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final itemWithId = {...data, 'id': docs[index].id};
            return FeedCard(
              key: ValueKey(itemWithId['id']),
              item: itemWithId,
              onDelete: () => widget.onDelete(itemWithId['id']),
              onCommentsUpdated: (newComments) =>
                  widget.onCommentsUpdated(itemWithId['id'], newComments),
            );
          },
        );
      },
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
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}
