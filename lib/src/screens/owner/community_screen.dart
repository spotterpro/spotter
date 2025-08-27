// 📁 lib/src/screens/owner/community_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spotter/src/screens/owner/create_owner_post_screen.dart';
import 'package:spotter/src/screens/store_detail_screen.dart';

class OwnerCommunityScreen extends StatefulWidget {
  final String storeId;
  const OwnerCommunityScreen({super.key, required this.storeId});

  @override
  State<OwnerCommunityScreen> createState() => _OwnerCommunityScreenState();
}

class _OwnerCommunityScreenState extends State<OwnerCommunityScreen> {
  String _selectedFilter = 'all';
  String? _selectedCategory;
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  final List<Map<String, String>> _categories = const [
    {'value': 'marketing', 'label': '마케팅 팁'},
    {'value': 'collaboration', 'label': '콜라보 제안'},
    {'value': 'qna', 'label': '질문'},
    {'value': 'free', 'label': '자유게시판'},
  ];

  Query _buildQuery() {
    Query query = FirebaseFirestore.instance.collection('owner_posts');
    if (_selectedFilter == 'my_posts') {
      query = query.where('authorUid', isEqualTo: _currentUserId);
    }
    if (_selectedCategory != null) {
      query = query.where('category', isEqualTo: _selectedCategory);
    }
    return query.orderBy('createdAt', descending: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildQuery().snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('아직 게시물이 없습니다.'));
                }
                final posts = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index].data() as Map<String, dynamic>;
                    return _OwnerPostCard(postData: post);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateOwnerPostScreen()));
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('전체'),
            selected: _selectedFilter == 'all' && _selectedCategory == null,
            onSelected: (selected) {
              if (selected) setState(() { _selectedFilter = 'all'; _selectedCategory = null; });
            },
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('내 게시물'),
            selected: _selectedFilter == 'my_posts',
            onSelected: (selected) {
              if (selected) setState(() { _selectedFilter = 'my_posts'; _selectedCategory = null; });
            },
          ),
          const Spacer(),
          Material(
            color: Theme.of(context).chipTheme.backgroundColor,
            shape: const StadiumBorder(),
            child: PopupMenuButton<String>(
              onSelected: (String value) {
                setState(() {
                  _selectedFilter = 'all';
                  _selectedCategory = value == 'all_categories' ? null : value;
                });
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'all_categories',
                    child: Text('모든 카테고리'),
                  ),
                  ..._categories.map((category) {
                    return PopupMenuItem<String>(
                      value: category['value']!,
                      child: Text(category['label']!),
                    );
                  }),
                ];
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(
                  children: [
                    Text(
                      _selectedCategory == null
                          ? '카테고리'
                          : _categories.firstWhere((c) => c['value'] == _selectedCategory)['label']!,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OwnerPostCard extends StatelessWidget {
  final Map<String, dynamic> postData;

  const _OwnerPostCard({required this.postData});

  @override
  Widget build(BuildContext context) {
    final categoryLabel = postData['category'] == 'marketing' ? '마케팅 팁'
        : postData['category'] == 'collaboration' ? '콜라보 제안'
        : postData['category'] == 'qna' ? '질문'
        : '자유게시판';
    final categoryColor = postData['category'] == 'collaboration' ? Colors.purple : Colors.blue;
    final tags = (postData['tags'] as List<dynamic>?)?.cast<String>() ?? [];
    final authorImageUrl = postData['authorStoreImageUrl'] as String?;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    final authorUid = postData['authorUid'] as String?;
                    if (authorUid != null) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => StoreDetailScreen(storeId: authorUid)));
                    }
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: (authorImageUrl != null && authorImageUrl.isNotEmpty)
                        ? NetworkImage(authorImageUrl)
                        : null,
                    child: (authorImageUrl == null || authorImageUrl.isEmpty)
                        ? const Icon(Icons.store, color: Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(postData['storeName'] ?? '가게 이름', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                          '${(postData['createdAt'] as Timestamp?)?.toDate().toLocal().toString().substring(0, 16) ?? ''}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12)
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(categoryLabel, style: TextStyle(color: categoryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              postData['body'] ?? '',
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              // --- 🔥🔥🔥 수정된 부분: 고정 색상을 제거하여 테마에 맞는 색상이 적용되도록 합니다. ---
              style: const TextStyle(height: 1.5, fontSize: 16),
            ),
            if (tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: tags.map((tag) => Text('#$tag', style: const TextStyle(color: Colors.blueAccent))).toList(),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.favorite_border, color: Colors.grey[600], size: 20),
                const SizedBox(width: 4),
                Text('${postData['likeCount'] ?? 0}'),
                const SizedBox(width: 16),
                Icon(Icons.chat_bubble_outline, color: Colors.grey[600], size: 20),
                const SizedBox(width: 4),
                Text('${postData['commentCount'] ?? 0}'),
              ],
            )
          ],
        ),
      ),
    );
  }
}