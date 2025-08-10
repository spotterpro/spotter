import 'package:flutter/material.dart';
import 'package:spotter/src/screens/user_profile_screen.dart';
import 'package:spotter/src/widgets/comment_bottom_sheet.dart';
import 'package:spotter/src/screens/post_detail_screen.dart';

class FeedCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onDelete;
  final Function(List<Map<String, dynamic>>) onCommentsUpdated;

  const FeedCard({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onCommentsUpdated,
  });

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  late bool _isLiked;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _isLiked = false;
    _likeCount = widget.item['likes'] ?? 0;
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _isLiked ? _likeCount++ : _likeCount--;
    });
  }

  void _showCommentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CommentBottomSheet(
          initialComments:
          List<Map<String, dynamic>>.from(widget.item['commentsList'] ?? []),
          onCommentsUpdated: (newComments) {
            widget.onCommentsUpdated(newComments);
          },
        );
      },
    );
  }

  void _showPostMenuSheet() {
    bool isMyPost = widget.item['userName'] == '형님';
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
                  },
                ),
                ListTile(
                  leading:
                  const Icon(Icons.delete_outline, color: Colors.red),
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

  @override
  Widget build(BuildContext context) {
    final int commentCount =
        (widget.item['commentsList'] as List? ?? []).length;
    bool isMyPost = widget.item['userName'] == '형님';

    // --- 형님의 요청대로 수정된 부분 ---
    // Firestore에서 오는 List<dynamic>을 List<String>으로 안전하게 변환합니다.
    final tags = List<String>.from(widget.item['tags'] ?? []);

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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UserProfileScreen()));
                  },
                  child: CircleAvatar(
                      backgroundImage: NetworkImage(
                          'https://picsum.photos/seed/${widget.item['userImageSeed']}/100/100')),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              const UserProfileScreen()));
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.item['userName'],
                            style:
                            const TextStyle(fontWeight: FontWeight.bold)),
                        if (widget.item['storeName'] != null &&
                            (widget.item['storeName'] as String).isNotEmpty)
                          Text(widget.item['storeName'],
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                if (isMyPost)
                  IconButton(
                      icon: const Icon(Icons.more_horiz),
                      onPressed: _showPostMenuSheet),
              ],
            ),
          ),
          if (widget.item['postImageSeed'] != null)
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PostDetailScreen(item: widget.item)),
                );
                if (result == true) {
                  widget.onDelete();
                }
              },
              child: Image.network(
                  'https://picsum.photos/seed/${widget.item['postImageSeed']}/600/400',
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.item['caption']),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8.0,
                  children: tags
                      .map((tag) =>
                      Text(tag, style: TextStyle(color: Colors.blue[600])))
                      .toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    InkWell(
                      onTap: _toggleLike,
                      child: Row(
                        children: [
                          Icon(
                              _isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 20,
                              color: _isLiked
                                  ? Colors.red
                                  : Colors.grey[700]),
                          const SizedBox(width: 4),
                          Text('좋아요 $_likeCount',
                            style: TextStyle(
                              color: _isLiked
                                  ? Colors.red
                                  : Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: _showCommentSheet,
                      child: Row(
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              size: 20, color: Colors.grey[700]),
                          const SizedBox(width: 4),
                          Text('댓글 $commentCount',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
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
}