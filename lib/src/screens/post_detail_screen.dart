import 'package:flutter/material.dart';

class PostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  const PostDetailScreen({super.key, required this.item});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  // Post-related state
  late Map<String, dynamic> _postItem;
  late bool _isLiked;
  late int _likeCount;

  // Comment-related state
  late List<Map<String, dynamic>> _comments;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  Map<String, dynamic>? _replyingTo;
  int? _editingCommentId;
  final TextEditingController _editController = TextEditingController();

  // ✅ 게시물 수정 다이얼로그용 컨트롤러
  final TextEditingController _captionEditController = TextEditingController();
  final TextEditingController _tagsEditController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _postItem = Map<String, dynamic>.from(widget.item);
    // ✅ comments 타입 안전 캐스팅
    _comments = List<Map<String, dynamic>>.from(_postItem['commentsList'] ?? []);
    // ✅ tags를 List<String>으로 보정 (null/타입 혼합 대비)
    final rawTags = _postItem['tags'];
    final safeTags = (rawTags is List)
        ? rawTags.map((e) => e.toString()).toList()
        : <String>[];
    _postItem['tags'] = safeTags;

    _isLiked = false;
    _likeCount = (_postItem['likes'] as int?) ?? 0;
  }

  @override
  void dispose() {
    _commentController.dispose();
    _editController.dispose();
    _commentFocusNode.dispose();
    _scrollController.dispose();
    _captionEditController.dispose();
    _tagsEditController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _isLiked ? _likeCount++ : _likeCount--;
    });
  }

  // =========================
  // 게시물 더보기: 수정/삭제
  // =========================
  void _showPostMenuSheet() {
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
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('게시물 수정'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditPostDialog(); // ✅ 수정 다이얼로그 호출
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('게시물 삭제', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeletePostConfirmDialog();
                },
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                title: const Center(child: Text('취소')),
                onTap: () { Navigator.pop(context); },
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ 게시물 수정 다이얼로그
  void _showEditPostDialog() {
    // 현재 값 세팅
    _captionEditController.text = (_postItem['caption'] ?? '').toString();
    _tagsEditController.text = (_postItem['tags'] as List<String>).join(', ');

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
                    labelText: '내용(캡션)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _tagsEditController,
                  decoration: const InputDecoration(
                    labelText: '태그 (쉼표로 구분: 예) 맛집, 파스타)',
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
                // 입력값 적용
                final newCaption = _captionEditController.text.trim();
                final newTags = _tagsEditController.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();

                setState(() {
                  _postItem['caption'] = newCaption;
                  _postItem['tags'] = newTags;
                });

                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeletePostConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('피드 삭제'),
          content: const Text('정말로 이 피드를 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('삭제', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  // =========================
  // 댓글 추가/삭제/수정
  // =========================
  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;
    final newComment = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'name': '형님',
      'seed': 'myprofile',
      'time': '방금 전',
      'comment': _commentController.text.trim(),
      'replies': <Map<String, dynamic>>[],
    };
    setState(() {
      if (_replyingTo == null) {
        _comments.add(newComment);
      } else {
        _addReplyRecursive(_comments, _replyingTo!['id'] as int, newComment);
        _replyingTo = null;
      }
      _commentController.clear();
      _commentFocusNode.unfocus();
    });
  }

  void _deleteComment(int commentId) {
    setState(() {
      _deleteCommentRecursive(_comments, commentId);
    });
  }

  bool _addReplyRecursive(List<Map<String, dynamic>> comments, int parentId, Map<String, dynamic> newReply) {
    for (var comment in comments) {
      if ((comment['id'] as int) == parentId) {
        (comment['replies'] as List).add(newReply);
        return true;
      }
      final replies = (comment['replies'] as List?) ?? [];
      if (replies.isNotEmpty) {
        if (_addReplyRecursive(replies.cast<Map<String, dynamic>>(), parentId, newReply)) return true;
      }
    }
    return false;
  }

  bool _deleteCommentRecursive(List<Map<String, dynamic>> comments, int commentId) {
    for (int i = 0; i < comments.length; i++) {
      if ((comments[i]['id'] as int) == commentId) {
        comments.removeAt(i);
        return true;
      }
      final replies = (comments[i]['replies'] as List?) ?? [];
      if (replies.isNotEmpty) {
        if (_deleteCommentRecursive(replies.cast<Map<String, dynamic>>(), commentId)) return true;
      }
    }
    return false;
  }

  bool _updateCommentRecursive(List<Map<String, dynamic>> comments, int commentId, String newText) {
    for (var comment in comments) {
      if ((comment['id'] as int) == commentId) {
        comment['comment'] = newText;
        return true;
      }
      final replies = (comment['replies'] as List?) ?? [];
      if (replies.isNotEmpty) {
        if (_updateCommentRecursive(replies.cast<Map<String, dynamic>>(), commentId, newText)) return true;
      }
    }
    return false;
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_postItem['userName']}님의 게시물'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: 1 + _comments.length,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildPostContent();
                }
                final comment = _comments[index - 1];
                return _buildCommentTree(comment);
              },
            ),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildPostContent() {
    final isMyPost = _postItem['userName'] == '형님';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              CircleAvatar(backgroundImage: NetworkImage('https://picsum.photos/seed/${_postItem['userImageSeed']}/100/100')),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_postItem['userName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (_postItem['storeName'] != null && (_postItem['storeName'] as String).isNotEmpty)
                    const SizedBox(height: 2),
                  if (_postItem['storeName'] != null && (_postItem['storeName'] as String).isNotEmpty)
                    Text(_postItem['storeName'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const Spacer(),
              if (isMyPost)
                IconButton(icon: const Icon(Icons.more_horiz), onPressed: _showPostMenuSheet),
            ],
          ),
        ),
        if (_postItem['postImageSeed'] != null)
          Image.network(
            'https://picsum.photos/seed/${_postItem['postImageSeed']}/600/400',
            width: double.infinity, fit: BoxFit.cover,
          ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_postItem['caption']),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: (_postItem['tags'] as List<String>)
                    .map((tag) => Text('#$tag', style: TextStyle(color: Colors.blue[600])))
                    .toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  InkWell(
                    onTap: _toggleLike,
                    child: Row(
                      children: [
                        Icon(_isLiked ? Icons.favorite : Icons.favorite_border, size: 20, color: _isLiked ? Colors.red : Colors.grey[700]),
                        const SizedBox(width: 4),
                        Text('좋아요 $_likeCount', style: TextStyle(color: _isLiked ? Colors.red : Theme.of(context).textTheme.bodyLarge?.color)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey[700]),
                      const SizedBox(width: 4),
                      Text('댓글 ${_comments.length}', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(thickness: 8),
      ],
    );
  }

  Widget _buildCommentTree(Map<String, dynamic> data, {double paddingLeft = 0}) {
    final replies = (data['replies'] as List?) ?? [];
    final isEditing = _editingCommentId == data['id'];
    return Padding(
      padding: EdgeInsets.only(left: paddingLeft),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isEditing ? _buildEditCommentView(data) : _buildCommentItem(data),
          if (replies.isNotEmpty)
            Column(
              children: replies.map((reply) => _buildCommentTree(reply as Map<String, dynamic>, paddingLeft: 30)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> data) {
    final isMyComment = data['name'] == '형님';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 18, backgroundImage: NetworkImage('https://picsum.photos/seed/${data['seed']}/100/100')),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '${data['name']}  ', style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: data['comment']),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(data['time'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () {
                        setState(() { _replyingTo = data; });
                        _commentFocusNode.requestFocus();
                      },
                      child: const Text('답글 달기', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isMyComment)
            IconButton(
              icon: const Icon(Icons.more_horiz, size: 20, color: Colors.grey),
              onPressed: () => _showEditDeleteMenu(context, data),
            )
        ],
      ),
    );
  }

  Widget _buildEditCommentView(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          TextField(
            controller: _editController,
            autofocus: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(12),
            ),
            maxLines: null,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(child: const Text('취소'), onPressed: () => setState(() => _editingCommentId = null)),
              TextButton(
                child: const Text('저장'),
                onPressed: () {
                  setState(() {
                    _updateCommentRecursive(_comments, _editingCommentId!, _editController.text);
                    _editingCommentId = null;
                  });
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  void _showEditDeleteMenu(BuildContext context, Map<String, dynamic> comment) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('수정하기'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _editingCommentId = comment['id'] as int;
                    _editController.text = (comment['comment'] ?? '').toString();
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('삭제하기', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteCommentConfirmDialog(comment['id'] as int);
                },
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(title: const Center(child: Text('취소')), onTap: () => Navigator.pop(context)),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteCommentConfirmDialog(int commentId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('댓글 삭제'),
          content: const Text('정말로 이 댓글을 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(child: const Text('취소'), onPressed: () => Navigator.of(dialogContext).pop()),
            TextButton(
              child: const Text('삭제', style: TextStyle(color: Colors.red)),
              onPressed: () {
                _deleteComment(commentId);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_replyingTo != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Text('${_replyingTo!['name']}님에게 답글 남기는 중...', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                      onPressed: () { setState(() { _replyingTo = null; }); },
                    )
                  ],
                ),
              ),
            Row(
              children: [
                const CircleAvatar(radius: 18, backgroundImage: NetworkImage('https://picsum.photos/seed/myprofile/100/100')),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    focusNode: _commentFocusNode,
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: _replyingTo == null ? '댓글 달기...' : '${_replyingTo!['name']}에게 답글 보내기',
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Theme.of(context).dividerColor)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.orange, width: 2)),
                    ),
                    onSubmitted: (_) => _addComment(),
                  ),
                ),
                TextButton(
                  onPressed: _addComment,
                  child: const Text('게시', style: TextStyle(color: Colors.orange)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
