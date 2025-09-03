import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/features/community_and_post/presentation/screens/create_community_post_screen.dart';
import 'package:spotter/features/feed/presentation/widgets/feed_card.dart';

class CommunityScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;

  const CommunityScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int _selectedTagIndex = 0;
  List<String> _tags = ['#전체', '🔥 주간 인기글'];
  bool _isLoadingTags = true;

  @override
  void initState() {
    super.initState();
    _fetchTrendingTags();
  }

  Future<void> _fetchTrendingTags() async {
    setState(() { _isLoadingTags = true; });
    try {
      final postsSnapshot = await FirebaseFirestore.instance
          .collection('community_posts')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      final tagCounts = <String, int>{};

      for (var doc in postsSnapshot.docs) {
        final tags = List<String>.from(doc.data()['tags'] ?? []);
        for (var tag in tags) {
          tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
        }
      }

      final sortedTags = tagCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final top3Tags = sortedTags.take(3).map((e) => '#${e.key}').toList();

      if (mounted) {
        setState(() {
          _tags = ['#전체', '🔥 주간 인기글', ...top3Tags];
        });
      }
    } catch (e) {
      print("트렌드 태그 로딩 실패: $e");
    } finally {
      if (mounted) {
        setState(() { _isLoadingTags = false; });
      }
    }
  }

  Query _buildQuery() {
    Query query = FirebaseFirestore.instance.collection('community_posts');

    if (_selectedTagIndex == 0) {
      return query.orderBy('createdAt', descending: true);
    }
    else if (_selectedTagIndex == 1) {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      return query
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
          .orderBy('createdAt', descending: true)
          .orderBy('likeCount', descending: true);
    }
    else {
      final selectedTag = _tags[_selectedTagIndex].replaceAll('#', '');
      return query
          .where('tags', arrayContains: selectedTag)
          .orderBy('createdAt', descending: true);
    }
  }

  Future<void> _deletePost(String postId) async {
    try {
      // [아우] CommunityScreen의 피드는 'community_posts' 컬렉션입니다.
      await FirebaseFirestore.instance.collection('community_posts').doc(postId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('게시물이 삭제되었습니다.')));
      }
    } catch(e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('삭제 중 오류 발생: $e')));
      }
    }
  }

  Future<void> _updatePost(String postId, String newCaption, List<String> newTags) async {
    try {
      // [아우] CommunityScreen의 피드는 'community_posts' 컬렉션입니다.
      await FirebaseFirestore.instance.collection('community_posts').doc(postId).update({
        'caption': newCaption,
        'tags': newTags,
      });
    } catch(e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('수정 중 오류 발생: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('스팟 커뮤니티', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.only(bottom: 8.0),
            child: SizedBox(
              height: 40,
              child: _isLoadingTags
                  ? const Center(child: LinearProgressIndicator())
                  : ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _tags.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(_tags[index]),
                      selected: _selectedTagIndex == index,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() { _selectedTagIndex = index; });
                        }
                      },
                      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200],
                      selectedColor: Colors.black,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: _selectedTagIndex == index ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildQuery().snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('오류가 발생했습니다. 파이어베이스 색인을 확인해주세요.\n${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('아직 게시물이 없습니다.'));
                }

                var docs = snapshot.data!.docs;

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final itemWithId = {...data, 'id': docs[index].id };
                    return FeedCard(
                      // [아우] 🔥🔥🔥 여기가 핵심 수정 지점입니다! 🔥🔥🔥
                      collectionPath: 'community_posts',
                      item: itemWithId,
                      onDelete: () => _deletePost(itemWithId['id']),
                      onUpdate: (caption, tags) => _updatePost(itemWithId['id'], caption, tags),
                      currentUser: widget.currentUser,
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CreateCommunityPostScreen(currentUser: widget.currentUser)));
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}