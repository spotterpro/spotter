import 'package:flutter/material.dart';

class CommentSection extends StatefulWidget {
  final List<Map<String, dynamic>> initialComments;
  final Function(List<Map<String, dynamic>>) onCommentsUpdated;

  const CommentSection({
    super.key,
    required this.initialComments,
    required this.onCommentsUpdated,
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  late List<Map<String, dynamic>> _comments;
  Map<String, dynamic>? _replyingTo;
  int? _editingCommentId;
  final TextEditingController _editController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _comments = List<Map<String, dynamic>>.from(widget.initialComments.map((e) => Map<String, dynamic>.from(e)));
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    _scrollController.dispose();
    _editController.dispose();
    super.dispose();
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
      widget.onCommentsUpdated(_comments);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
        }
      });
    });
  }

  void _deleteComment(int commentId) {
    setState(() {
      _deleteCommentRecursive(_comments, commentId);
      widget.onCommentsUpdated(_comments);
    });
  }

  bool _addReplyRecursive(List<Map<String, dynamic>> comments, int parentId, Map<String, dynamic> newReply) {
    for (var comment in comments) {
      if (comment['id'] == parentId) {
        if (comment['replies'] == null) {
          comment['replies'] = <Map<String, dynamic>>[];
        }
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
        if (_deleteCommentRecursive(replies.cast<Map<String, dynamic>>(), commentId)) {
          return true;
        }
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

  int _getCommentCount(List<Map<String, dynamic>> comments) {
    int count = 0;
    for (var comment in comments) {
      count++;
      final replies = comment['replies'] as List? ?? [];
      if (replies.isNotEmpty) {
        count += _getCommentCount(replies.cast<Map<String, dynamic>>());
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Text('댓글 ${_getCommentCount(_comments)}개', style: Theme.of(context).textTheme.titleSmall),
        ),
        const Divider(height: 1),
        Expanded(
          child: _comments.isEmpty
              ? Center(child: Text('가장 먼저 댓글을 남겨보세요.', style: TextStyle(color: Colors.grey[600])))
              : ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            itemCount: _comments.length,
            itemBuilder: (context, index) {
              return _buildCommentTree(_comments[index]);
            },
          ),
        ),
        _buildCommentInput(),
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