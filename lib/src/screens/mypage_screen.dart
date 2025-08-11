// 📁 lib/src/screens/mypage_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/src/screens/settings_screen.dart';
import 'package:spotter/src/widgets/feed_card.dart';

class MyPageScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  final Function(Map<String, String>) onProfileUpdated;

  const MyPageScreen({
    super.key,
    required this.currentUser,
    required this.onProfileUpdated,
  });

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> with TickerProviderStateMixin {
  late final TabController _tabController;
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

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

  Future<void> _deletePost(String postId) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시물이 삭제되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 중 오류가 발생했습니다: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _updatePost(String postId, String newCaption, List<String> newTags) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'caption': newCaption,
        'tags': newTags,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시물이 수정되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('수정 중 오류가 발생했습니다: $e'), backgroundColor: Colors.red),
        );
      }
    }
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
                  isScrollable: false,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(width: 3, color: primary),
                  ),
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                  tabs: const [
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
                    // --- 형님의 요청대로 수정된 부분 ---
                    Text(widget.currentUser['levelTitle'], // "LV.25" 만 표시됨
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('author.uid', isEqualTo: _currentUserId)
          .where('isCertified', isEqualTo: true)
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('작성한 인증 피드가 없습니다.'));
        }
        final docs = snapshot.data!.docs;
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final itemWithId = {...data, 'id': docs[index].id};
            return InkWell(
              onTap: () {
                // TODO: 인증피드 상세 화면으로 이동
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'https://picsum.photos/seed/${itemWithId['postImageSeed']}/300/300',
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWrittenPosts() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('author.uid', isEqualTo: _currentUserId)
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
              onDelete: () => _deletePost(itemWithId['id']),
              onUpdate: (caption, tags) => _updatePost(itemWithId['id'], caption, tags),
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