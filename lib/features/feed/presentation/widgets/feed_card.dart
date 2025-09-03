// [아우] 이 파일은 형님의 최종 코드를 기반으로, CommentBottomSheet 호출부만 수정했습니다.
// 다른 모든 로직은 형님의 것을 100% 유지합니다.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spotter/core/services/firestore_service.dart';
import 'package:spotter/features/profile_and_mypage/presentation/screens/user_profile_screen.dart';
import 'package:spotter/features/community_and_post/presentation/widgets/comment_bottom_sheet.dart';

class FeedCard extends StatefulWidget {
  final String collectionPath;
  final Map<String, dynamic> item;
  final VoidCallback onDelete;
  final Function(String caption, List<String> tags)? onUpdate;
  final Map<String, dynamic> currentUser;

  const FeedCard({
    super.key,
    required this.collectionPath,
    required this.item,
    required this.onDelete,
    this.onUpdate,
    required this.currentUser,
  });

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  final FirestoreService _firestoreService = FirestoreService();
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final TextEditingController _captionEditController = TextEditingController();
  final TextEditingController _tagsEditController = TextEditingController();

  @override
  void dispose() {
    _captionEditController.dispose();
    _tagsEditController.dispose();
    super.dispose();
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '방금 전';
    final now = DateTime.now();
    final postTime = timestamp.toDate();
    final difference = now.difference(postTime);
    if (difference.inSeconds < 60) return '방금 전';
    if (difference.inMinutes < 60) return '${difference.inMinutes}분 전';
    if (difference.inHours < 24) return '${difference.inHours}시간 전';
    return DateFormat('yyyy.MM.dd').format(postTime);
  }

  void _showCommentSheet() {
    final postId = widget.item['id'] as String? ?? '';
    if (postId.isEmpty) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CommentBottomSheet(
          // [아우] 🔥🔥🔥 여기가 핵심 수정 지점입니다! 🔥🔥🔥
          collectionPath: widget.collectionPath,
          postId: postId,
          currentUser: widget.currentUser,
        );
      },
    );
  }

  // ... (이하 모든 _show... 및 _navigateToUserProfile 함수는 변경 없음) ...
  void _showPostMenuSheet(Map<String, dynamic> author) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    bool isMyPost = (author['uid'] != null && author['uid'] == currentUid);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Wrap(
            children: <Widget>[
              if (isMyPost) ...[
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('수정하기'),
                  onTap: () {
                    Navigator.pop(context);
                    if (widget.onUpdate != null) {
                      _showEditPostDialog();
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('삭제하기', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmDialog();
                  },
                ),
              ] else ...[
                ListTile(
                  leading: const Icon(Icons.flag_outlined, color: Colors.red),
                  title: const Text('신고하기', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('피드가 신고되었습니다.')));
                  },
                ),
              ],
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                title: const Center(child: Text('취소')),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditPostDialog() {
    _captionEditController.text = (widget.item['caption'] ?? '').toString();
    final currentTags = List<String>.from(widget.item['tags'] ?? []);
    _tagsEditController.text = currentTags.join(', ');

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('게시물 수정'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _captionEditController,
                  decoration: const InputDecoration(labelText: '내용', border: OutlineInputBorder()),
                  maxLines: 5,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _tagsEditController,
                  decoration: const InputDecoration(labelText: '태그 (쉼표로 구분)', hintText: '예: 맛집, 수다, 질문', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('취소'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            FilledButton(
              child: const Text('저장'),
              onPressed: () {
                final newCaption = _captionEditController.text.trim();
                final newTags = _tagsEditController.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();
                widget.onUpdate?.call(newCaption, newTags);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('피드 삭제'),
          content: const Text('정말로 이 피드를 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('삭제', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDelete();
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToUserProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserProfileScreen(userId: userId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final author = widget.item['author'] as Map<String, dynamic>? ?? {};
    final authorName = author['name'] ?? '알 수 없음';
    final authorImageSeed = author['imageSeed'] ?? 'default';
    final authorLevel = author['levelTitle'] ?? 'LV.1';
    final authorUid = author['uid'] as String?;
    final imageUrl = widget.item['imageUrl'] as String?;
    final tags = List<String>.from(widget.item['tags'] ?? []);
    final pollData = widget.item['poll'] as Map<String, dynamic>?;
    final isCertified = widget.item['isCertified'] as bool? ?? false;
    final storeName = widget.item['storeName'] as String?;
    final postId = widget.item['id'] as String? ?? '';

    return Card(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (authorUid != null) {
                      _navigateToUserProfile(authorUid);
                    }
                  },
                  child: CircleAvatar(
                      backgroundImage: NetworkImage('https://picsum.photos/seed/$authorImageSeed/100/100')),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (authorUid != null) {
                        _navigateToUserProfile(authorUid);
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                authorLevel,
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                                _formatTimestamp(widget.item['createdAt'] as Timestamp?),
                                style: const TextStyle(color: Colors.grey, fontSize: 12)
                            ),
                            if (isCertified && storeName != null) ...[
                              const Text(' · ', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Icon(Icons.check_circle, color: Colors.green[600], size: 14),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  '$storeName 인증',
                                  style: TextStyle(color: Colors.green[700], fontSize: 12, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ]
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () => _showPostMenuSheet(author)),
              ],
            ),
          ),
          if (imageUrl != null && imageUrl.isNotEmpty)
            Image.network(
                imageUrl,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.item['caption'] ?? ''),
                if (pollData != null)
                  _buildPollSection(pollData),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8.0,
                  children: tags
                      .map((tag) => Text('#$tag', style: TextStyle(color: Colors.blue[600])))
                      .toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    StreamBuilder<bool>(
                        stream: _firestoreService.isPostLikedByUser(
                            collectionPath: widget.collectionPath,
                            postId: postId,
                            userId: _currentUserId
                        ),
                        builder: (context, snapshot) {
                          final isLiked = snapshot.data ?? false;
                          return InkWell(
                            onTap: () => _firestoreService.togglePostLike(
                                collectionPath: widget.collectionPath,
                                postId: postId,
                                userId: _currentUserId
                            ),
                            child: Row(
                              children: [
                                Icon(
                                    isLiked ? Icons.favorite : Icons.favorite_border,
                                    size: 20,
                                    color: isLiked ? Colors.red : Colors.grey[700]),
                                const SizedBox(width: 4),
                                StreamBuilder<int>(
                                  stream: _firestoreService.getPostLikeCount(
                                      collectionPath: widget.collectionPath,
                                      postId: postId
                                  ),
                                  builder: (context, snapshot) {
                                    return Text('좋아요 ${snapshot.data ?? 0}',
                                      style: TextStyle(
                                        color: isLiked ? Colors.red : Theme.of(context).textTheme.bodyLarge?.color,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        }
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: _showCommentSheet,
                      child: Row(
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey[700]),
                          const SizedBox(width: 4),
                          StreamBuilder<int>(
                              stream: _firestoreService.getCommentsAndRepliesCount(
                                  collectionPath: widget.collectionPath,
                                  postId: postId
                              ),
                              builder: (context, snapshot) {
                                return Text('댓글 ${snapshot.data ?? 0}',
                                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                                );
                              }
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPollSection(Map<String, dynamic> pollData) {
    final options = List<Map<String, dynamic>>.from(pollData['options'] ?? []);
    final totalVotes = options.fold<int>(0, (sum, option) => sum + (option['votes'] as List? ?? []).length);
    final postId = widget.item['id'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ...List.generate(options.length, (index) {
            final option = options[index];
            final text = option['text'] as String? ?? '';
            final votes = (option['votes'] as List? ?? []);
            final voteCount = votes.length;
            final double percentage = totalVotes > 0 ? voteCount / totalVotes : 0;
            final bool isVotedByUser = votes.contains(_currentUserId);
            final String percentageText = '${(percentage * 100).toStringAsFixed(0)}%';

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: InkWell(
                onTap: () {
                  _firestoreService.voteOnPoll(
                    collectionPath: widget.collectionPath,
                    postId: postId,
                    optionIndex: index,
                    userId: _currentUserId,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isVotedByUser ? Colors.orange : Colors.grey.shade300, width: isVotedByUser ? 2 : 1),
                  ),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      FractionallySizedBox(
                        widthFactor: percentage,
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Expanded(child: Text(text, style: TextStyle(fontWeight: isVotedByUser ? FontWeight.bold : FontWeight.normal))),
                            Text('$percentageText (${voteCount}표)', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text('총 ${totalVotes}명 참여', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          )
        ],
      ),
    );
  }
}