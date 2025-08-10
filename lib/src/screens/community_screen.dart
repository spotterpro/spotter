import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:spotter/src/screens/create_community_post_screen.dart';
import 'package:spotter/src/widgets/feed_card.dart';

class CommunityScreen extends StatefulWidget {
  final List<Map<String, dynamic>> feedItems;
  final Function(String) onDelete;
  final Function(String, List<Map<String, dynamic>>) onCommentsUpdated;

  const CommunityScreen({
    super.key,
    required this.feedItems,
    required this.onDelete,
    required this.onCommentsUpdated,
  });

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int _selectedTagIndex = 0;
  final List<String> _tags = ['#전체', '🔥 주간 인기글', '#맛집탐방', '#일상', '#궁금해요'];

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
              child: ListView.builder(
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
              stream: FirebaseFirestore.instance.collection('posts').where('isCertified', isEqualTo: false).orderBy('time', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('아직 게시물이 없습니다.'));
                }

                var docs = snapshot.data!.docs;

                if (_selectedTagIndex > 0) {
                  final selectedTag = _tags[_selectedTagIndex];
                  docs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final tags = List<String>.from(data['tags'] ?? []);
                    if (_selectedTagIndex == 1) {
                      return data['isHot'] == true;
                    }
                    return tags.contains(selectedTag);
                  }).toList();
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final itemWithId = {...data, 'id': docs[index].id };
                    return FeedCard(
                      item: itemWithId,
                      onDelete: () => widget.onDelete(itemWithId['id']),
                      onCommentsUpdated: (newComments) => widget.onCommentsUpdated(itemWithId['id'], newComments),
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateCommunityPostScreen()));
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}