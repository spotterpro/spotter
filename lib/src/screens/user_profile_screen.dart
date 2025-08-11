// 📁 lib/src/screens/user_profile_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:spotter/models/user_model.dart';
import 'package:spotter/src/widgets/feed_card.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({
    super.key,
    required this.userId,
  });

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

  Future<void> _deletePost(String postId) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시물이 삭제되었습니다.')),
        );
      }
    } catch (e) {
      // Handle error
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
      // Handle error
    }
  }


  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (currentUserId.isEmpty) {
      return const Scaffold(body: Center(child: Text('로그인이 필요합니다.')));
    }

    final profileUserStream = FirebaseFirestore.instance.collection('users').doc(widget.userId).snapshots();
    final currentUserStream = FirebaseFirestore.instance.collection('users').doc(currentUserId).snapshots();

    return StreamBuilder<List<DocumentSnapshot>>(
      stream: CombineLatestStream.list([profileUserStream, currentUserStream]),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.length < 2) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final profileUserDoc = snapshot.data![0];
        final currentUserDoc = snapshot.data![1];

        if (!profileUserDoc.exists) {
          return const Scaffold(body: Center(child: Text('사용자 정보를 찾을 수 없습니다.')));
        }
        if (!currentUserDoc.exists) {
          return const Scaffold(body: Center(child: Text('현재 사용자 정보를 불러올 수 없습니다.')));
        }

        final userProfile = UserProfile.fromDocument(profileUserDoc);
        final currentUserMap = UserProfile.fromDocument(currentUserDoc).toMap();
        final primary = Theme.of(context).colorScheme.primary;

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  pinned: false,
                  floating: true,
                  title: Text(userProfile.userName),
                ),
                SliverToBoxAdapter(child: _buildProfileHeader(context, userProfile)),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: UnderlineTabIndicator(borderSide: BorderSide(width: 3, color: primary)),
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
                _buildUserFeeds(isCertified: true),
                _buildUserFeeds(isCertified: false, currentUser: currentUserMap),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfile userProfile) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage('https://picsum.photos/seed/${userProfile.userImageSeed}/200/200'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userProfile.userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    // --- 형님의 요청대로 수정된 부분 ---
                    Text(
                      userProfile.levelTitle, // 레벨만 표시
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ProfileStat(count: '${userProfile.crewCount}', label: '크루원'),
              _ProfileStat(count: '${userProfile.myCrewCount}', label: '나의 크루'),
              // --- 형님의 요청대로 수정된 부분 ---
              _ProfileStat(count: userProfile.influenceTitle, label: '칭호'),
            ],
          ),
          const SizedBox(height: 16),
          if (userProfile.bio.isNotEmpty)
            Text(userProfile.bio, style: const TextStyle(fontSize: 15, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildUserFeeds({required bool isCertified, Map<String, dynamic>? currentUser}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('author.uid', isEqualTo: widget.userId)
          .where('isCertified', isEqualTo: isCertified)
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text(isCertified ? '작성한 인증 피드가 없습니다.' : '작성한 글이 없습니다.'));
        }
        final docs = snapshot.data!.docs;

        if (isCertified) {
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: data['postImageSeed'] != null ? Image.network(
                  'https://picsum.photos/seed/${data['postImageSeed']}/300/300',
                  fit: BoxFit.cover,
                ) : Container(color: Colors.grey[300]),
              );
            },
          );
        } else {
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
                currentUser: currentUser!,
              );
            },
          );
        }
      },
    );
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
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}