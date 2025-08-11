// 📁 lib/src/screens/user_profile_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spotter/models/user_model.dart';
import 'package:spotter/src/widgets/feed_card.dart'; // FeedCard를 재사용하기 위해 임포트

class UserProfileScreen extends StatefulWidget {
  // --- 형님의 요청대로 수정된 부분 ---
  final String userId; // 특정 사용자의 ID를 받도록 변경

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

  // --- 삭제/수정 기능은 MyPageScreen과 동일하게 유지 ---
  Future<void> _deletePost(String postId) async {
    // ... (MyPageScreen의 _deletePost와 동일한 로직)
  }

  Future<void> _updatePost(String postId, String newCaption, List<String> newTags) async {
    // ... (MyPageScreen의 _updatePost와 동일한 로직)
  }


  @override
  Widget build(BuildContext context) {
    // --- 형님의 요청대로 수정된 부분 ---
    // 화면 전체를 StreamBuilder로 감싸서 userId에 해당하는 사용자 정보를 실시간으로 가져옵니다.
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(widget.userId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (!snapshot.data!.exists) {
            return const Scaffold(body: Center(child: Text('사용자 정보를 찾을 수 없습니다.')));
          }

          final userProfile = UserProfile.fromDocument(snapshot.data!);
          final primary = Theme.of(context).colorScheme.primary;

          return Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  // AppBar를 SliverAppBar로 변경하여 스크롤 시 자연스럽게 보이도록 개선
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
                  _buildUserFeeds(isCertified: false),
                ],
              ),
            ),
          );
        }
    );
  }

  // --- 기존 MyPageScreen의 헤더 UI를 재사용 ---
  Widget _buildProfileHeader(BuildContext context, UserProfile userProfile) {
    // ... (MyPageScreen의 _buildProfileHeader와 거의 동일, Settings 버튼만 제거)
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ProfileStat(count: '${userProfile.crewCount}', label: '크루원'),
                    _ProfileStat(count: '${userProfile.myCrewCount}', label: '나의 크루'),
                    _ProfileStat(count: '${userProfile.influence}', label: '영향력'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (userProfile.bio.isNotEmpty)
            Text(userProfile.bio, style: const TextStyle(fontSize: 15, height: 1.4)),
        ],
      ),
    );
  }

  // --- 기존 MyPageScreen의 피드 조회 로직을 재사용 및 통합 ---
  Widget _buildUserFeeds({required bool isCertified}) {
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
          // 인증 피드 (그리드 뷰)
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
          // 작성한 글 (리스트 뷰)
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
        }
      },
    );
  }
}

// --- 기존 MyPageScreen의 위젯들을 재사용 ---
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