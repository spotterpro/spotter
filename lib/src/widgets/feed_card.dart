import 'package:flutter/material.dart';
import 'package:spotter/src/screens/user_profile_screen.dart';
import 'package:spotter/src/widgets/comment_bottom_sheet.dart';
import 'package:spotter/src/screens/post_detail_screen.dart';

class FeedCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onDelete;
  // --- 형님의 요청대로 수정된 부분 ---
  final Function(String caption, List<String> tags)? onUpdate;
  final Function(List<Map<String, dynamic>>) onCommentsUpdated;

  const FeedCard({
    super.key,
    required this.item,
    required this.onDelete,
    this.onUpdate, // onUpdate는 선택적으로 받도록 변경
    required this.onCommentsUpdated,
  });

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  late bool _isLiked;
  late int _likeCount;
  // --- 형님의 요청대로 추가된 부분 ---
  final TextEditingController _captionEditController = TextEditingController();
  final TextEditingController _tagsEditController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isLiked = false;
    _likeCount = widget.item['likes'] ?? 0;
  }

  @override
  void dispose() {
    _captionEditController.dispose();
    _tagsEditController.dispose();
    super.dispose();
  }
  // --- 여기까지 추가/수정되었습니다 ---

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
                    // --- 형님의 요청대로 수정된 부분 ---
                    if (widget.onUpdate != null) {
                      _showEditPostDialog();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('이 피드는 수정할 수 없습니다.')),
                      );
                    }
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

  // --- 형님의 요청대로 추가된 부분 ---
  // 게시물 수정 다이얼로그
  void _showEditPostDialog() {
    // 현재 게시물의 내용을 컨트롤러에 설정합니다.
    _captionEditController.text = (widget.item['caption'] ?? '').toString();
    final currentTags = List<String>.from(widget.item['tags'] ?? []);
    // '#' 기호를 제거하고 쉼표로 연결하여 보여줍니다.
    _tagsEditController.text = currentTags.map((t) => t.startsWith('#') ? t.substring(1) : t).join(', ');

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
                  decoration: const InputDecoration(
                    labelText: '내용',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _tagsEditController,
                  decoration: const InputDecoration(
                    labelText: '태그 (쉼표로 구분)',
                    hintText: '예: 맛집, 수다, 질문',
                    border: OutlineInputBorder(),
                  ),
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
                // 입력된 태그를 쉼표 기준으로 나누고, 공백 제거, # 추가
                final newTags = _tagsEditController.text
                    .split(',')
                    .map((e) => '#${e.trim()}')
                    .where((e) => e.length > 1)
                    .toList();

                // onUpdate 콜백이 있으면 실행
                widget.onUpdate?.call(newCaption, newTags);

                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
  // --- 여기까지 추가되었습니다 ---

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