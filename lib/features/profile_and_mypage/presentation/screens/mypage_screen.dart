import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spotter/core/models/user_model.dart';
import 'package:spotter/core/services/firestore_service.dart';
import 'package:spotter/features/store/presentation/screens/crew_mode/crew_studio_screen.dart';
import 'package:spotter/features/feed/presentation/widgets/feed_card.dart';
import 'package:spotter/features/profile_and_mypage/presentation/screens/my_growth_log_screen.dart';
import 'package:spotter/features/profile_and_mypage/presentation/screens/settings_screen.dart';
import 'package:spotter/features/community_and_post/presentation/widgets/post_grid_item.dart';

class MyPageScreen extends StatefulWidget {
  final UserProfile currentUserProfile;
  const MyPageScreen({super.key, required this.currentUserProfile});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> with TickerProviderStateMixin {
  late final TabController _tabController;
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final FirestoreService _firestoreService = FirestoreService();

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

  Future<void> _deletePost(String postId, String collection) async {
    try {
      await _firestoreService.deletePost(collection, postId);
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

  Future<void> _updatePost(String postId, String newCaption, List<String> newTags, String collection) async {
    try {
      await _firestoreService.updatePost(collection, postId, newCaption, newTags);
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
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(_currentUserId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final userProfile = UserProfile.fromDocument(snapshot.data!);

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverToBoxAdapter(child: _buildProfileHeader(context, userProfile)),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      tabs: const [Tab(text: '피드'), Tab(text: '작성한 글')],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildAllPostsFeed(userProfile.toMap()),
                _buildCommunityPostsFeed(userProfile),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfile userProfile) {
    final avatarProvider = (userProfile.photoUrl.isNotEmpty)
        ? NetworkImage(userProfile.photoUrl)
        : NetworkImage('https://picsum.photos/seed/${userProfile.userImageSeed}/200/200');

    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.all(16.0).copyWith(top: 50, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 40, backgroundImage: avatarProvider),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userProfile.userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(userProfile.levelTitle, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SettingsScreen(
                        currentUser: userProfile.toMap(),
                        onProfileUpdated: (updatedData) {
                          debugPrint('SettingsScreen으로부터 프로필 업데이트 보고 받음: $updatedData');
                        },
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          if (userProfile.bio.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(userProfile.bio, style: const TextStyle(fontSize: 15, height: 1.4)),
            ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => MyGrowthLogScreen(userProfile: userProfile))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('XP: ${userProfile.xp}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('다음 레벨까지 ${userProfile.nextLevelXp - userProfile.xp} XP',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ]),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: userProfile.levelProgress,
                  backgroundColor: Theme.of(context).dividerColor,
                  color: Colors.orange,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ProfileStat(count: '${userProfile.crewCount}', label: '크루원'),
              _ProfileStat(count: '${userProfile.myCrewCount}', label: '나의 크루'),
              _ProfileStat(count: userProfile.influenceTitle, label: '칭호'),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => CrewStudioScreen(userProfile: userProfile))),
            icon: const FaIcon(FontAwesomeIcons.users, size: 16),
            label: const Text('크루 스튜디오'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200],
              foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllPostsFeed(Map<String, dynamic> currentUserMap) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('posts').where('author.uid', isEqualTo: _currentUserId).orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) { return const Center(child: CircularProgressIndicator()); }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) { return const Center(child: Text('작성한 피드가 없습니다.')); }
        final docs = snapshot.data!.docs;
        return GridView.builder(
          padding: const EdgeInsets.all(2.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount( crossAxisCount: 3, crossAxisSpacing: 2.0, mainAxisSpacing: 2.0, ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final itemWithId = {...data, 'id': docs[index].id};
            return PostGridItem(
              collectionPath: 'posts',
              post: itemWithId,
              currentUser: currentUserMap,
            );
          },
        );
      },
    );
  }

  Widget _buildCommunityPostsFeed(UserProfile userProfile) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('community_posts').where('author.uid', isEqualTo: _currentUserId).orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) { return const Center(child: CircularProgressIndicator()); }
        if (snapshot.hasError) { return const Center(child: Text('커뮤니티 글을 불러오는 중 오류가 발생했습니다.')); }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) { return const Center(child: Text('작성한 커뮤니티 글이 없습니다.')); }
        final docs = snapshot.data!.docs;
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final itemWithId = {...data, 'id': docs[index].id};
            return FeedCard(
              collectionPath: 'community_posts',
              key: ValueKey(itemWithId['id']),
              item: itemWithId,
              onDelete: () => _deletePost(itemWithId['id'], 'community_posts'),
              onUpdate: (caption, tags) => _updatePost(itemWithId['id'], caption, tags, 'community_posts'),
              currentUser: userProfile.toMap(),
            );
          },
        );
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
    return Column( children: [ Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)), ], );
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
    return Container(color: Theme.of(context).cardColor, child: tabBar);
  }
  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}