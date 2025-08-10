import 'package:flutter/material.dart';
import 'package:spotter/src/screens/store_detail_screen.dart';

class StoreNewsDetailScreen extends StatefulWidget {
  const StoreNewsDetailScreen({super.key});

  @override
  State<StoreNewsDetailScreen> createState() => _StoreNewsDetailScreenState();
}

class _StoreNewsDetailScreenState extends State<StoreNewsDetailScreen> {
  bool _isLiked = false;
  int _likeCount = 28;

  late List<Map<String, dynamic>> _comments;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  Map<String, dynamic>? _replyingTo;
  int? _editingCommentId;
  final TextEditingController _editController = TextEditingController();

  final Map<String, dynamic> _storeData = {
    'storeName': '맛집 파스타', 'regulars': 125, 'seed': 'pasta',
    'category': '음식점', 'description': '매일 아침 직접 뽑는 생면으로 만드는 인생 파스타.', 'address': '대구시 중구 서문시장'
  };

  // --- 형님의 요청대로 수정된 부분 ---
  // 현재 사용자의 이름을 임시로 지정합니다.
  final String _currentUserName = '형님';

  @override
  void initState() {
    super.initState();
    _comments = [
      {
        'id': 1001, 'name': '단골손님', 'comment': '오! 신메뉴 기대됩니다!!', 'seed': 'user4', 'time': '1일 전',
        'replies': [
          {'id': 10011, 'name': '맛집 파스타', 'comment': '감사합니다! 곧 출시되니 많은 관심 부탁드려요. 🍝', 'seed': 'pasta', 'time': '1일 전', 'replies': []},
        ]
      },
      {'id': 1002, 'name': '스포터', 'comment': '이번 주말에 바로 달려가겠습니다 🔥', 'seed': 'user1', 'time': '20시간 전', 'replies': []},
    ];
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    _editController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _isLiked ? _likeCount++ : _likeCount--;
    });
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;
    final newComment = {
      'id': DateTime.now().millisecondsSinceEpoch, 'name': '형님', 'seed': 'myprofile', 'time': '방금 전',
      'comment': _commentController.text.trim(), 'replies': []
    };
    setState(() {
      if (_replyingTo == null) {
        _comments.add(newComment);
      } else {
        _addReplyRecursive(_comments, _replyingTo!['id'], newComment);
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
      if (comment['id'] == parentId) {
        (comment['replies'] as List).add(newReply);
        return true;
      }
      final replies = comment['replies'] as List? ?? [];
      if (replies.isNotEmpty) {
        if (_addReplyRecursive(replies.cast<Map<String, dynamic>>(), parentId, newReply)) return true;
      }
    }
    return false;
  }

  bool _deleteCommentRecursive(List<Map<String, dynamic>> comments, int commentId) {
    for (int i = 0; i < comments.length; i++) {
      if (comments[i]['id'] == commentId) {
        comments.removeAt(i);
        return true;
      }
      final replies = comments[i]['replies'] as List? ?? [];
      if (replies.isNotEmpty) {
        if (_deleteCommentRecursive(replies.cast<Map<String, dynamic>>(), commentId)) return true;
      }
    }
    return false;
  }

  bool _updateCommentRecursive(List<Map<String, dynamic>> comments, int commentId, String newText) {
    for (var comment in comments) {
      if (comment['id'] == commentId) {
        comment['comment'] = newText;
        return true;
      }
      final replies = comment['replies'] as List? ?? [];
      if (replies.isNotEmpty) {
        if (_updateCommentRecursive(replies.cast<Map<String, dynamic>>(), commentId, newText)) return true;
      }
    }
    return false;
  }

  void _showNewsMenuSheet() {
    // 임시로 지정된 현재 사용자 이름과 가게 이름을 비교합니다.
    bool isOwner = _currentUserName == '맛집 파스타';

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
              if (isOwner) ...[
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('수정하기'),
                  onTap: () { Navigator.pop(context); /* TODO */ },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('삭제하기', style: TextStyle(color: Colors.red)),
                  onTap: () { Navigator.pop(context); /* TODO */ },
                ),
              ] else ...[
                ListTile(
                  leading: const Icon(Icons.flag_outlined, color: Colors.red),
                  title: const Text('신고하기', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('가게 소식이 신고되었습니다.')));
                  },
                ),
              ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('가게 소식'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => StoreDetailScreen(storeData: _storeData)));
          },
          child: Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage('https://picsum.photos/seed/pasta/100/100'),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('맛집 파스타', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('1일 전', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              const Spacer(),
              IconButton(onPressed: _showNewsMenuSheet, icon: const Icon(Icons.more_horiz))
            ],
          ),
        ),
        const SizedBox(height: 24),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            'https://picsum.photos/seed/pasta_news/800/600',
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '🍝 이번 주 신메뉴 출시! 바질 페스토 파스타를 만나보세요. 신선한 바질과 고소한 잣의 환상적인 조화! #신메뉴 #파스타맛집 #동성로맛집',
          style: TextStyle(fontSize: 16, height: 1.6),
        ),
        const SizedBox(height: 24),
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
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildCommentTree(Map<String, dynamic> data, {double paddingLeft = 0}) {
    final replies = data['replies'] as List? ?? [];
    bool isEditing = _editingCommentId == data['id'];
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
    bool isMyComment = data['name'] == '형님';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
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
                    TextSpan(children: [
                      TextSpan(text: '${data['name']}  ', style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: data['comment']),
                    ])
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
      padding: const EdgeInsets.symmetric(vertical: 8),
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
              ListTile(leading: const Icon(Icons.edit_outlined), title: const Text('수정하기'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _editingCommentId = comment['id'];
                    _editController.text = comment['comment'];
                  });
                },
              ),
              ListTile(leading: const Icon(Icons.delete_outline, color: Colors.red), title: const Text('삭제하기', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmDialog(comment['id']);
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

  void _showDeleteConfirmDialog(int commentId) {
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