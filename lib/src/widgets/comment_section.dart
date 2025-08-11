// 📁 lib/src/widgets/comment_section.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spotter/services/firestore_service.dart';
import 'package:spotter/src/screens/user_profile_screen.dart'; // 추가된 부분

class CommentSection extends StatefulWidget {
  final String postId;
  final Map<String, dynamic> currentUser;

  const CommentSection({
    super.key,
    required this.postId,
    required this.currentUser,
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  Map<String, dynamic>? _replyingTo;
  DocumentReference? _editingDocRef;
  final Map<String, bool> _expandedReplies = {};

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    _scrollController.dispose();
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

  void _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final currentUserInfo = {
      'name': widget.currentUser['userName'],
      'imageSeed': widget.currentUser['userImageSeed'],
      'levelTitle': widget.currentUser['levelTitle'],
      'uid': user.uid,
    };

    if (_editingDocRef != null) {
      await _firestoreService.updateComment(_editingDocRef!, _commentController.text.trim());
      setState(() { _editingDocRef = null; });
    } else if (_replyingTo != null) {
      final commentId = _replyingTo!['id'];
      await _firestoreService.addReply(
          widget.postId, commentId, _commentController.text.trim(), currentUserInfo);
      await _firestoreService.incrementUserXp(user.uid, 2);
      setState(() {
        _expandedReplies[commentId] = true;
        _replyingTo = null;
      });
    } else {
      await _firestoreService.addComment(widget.postId, _commentController.text.trim(), currentUserInfo);
      await _firestoreService.incrementUserXp(user.uid, 2);
    }

    _commentController.clear();
    _commentFocusNode.unfocus();
  }

  void _startEdit(DocumentReference docRef, String currentText) {
    setState(() {
      _editingDocRef = docRef;
      _replyingTo = null;
      _commentController.text = currentText;
      _commentFocusNode.requestFocus();
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingDocRef = null;
      _commentController.clear();
      _commentFocusNode.unfocus();
    });
  }

  // --- 형님의 요청대로 추가된 부분 ---
  void _navigateToUserProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserProfileScreen(userId: userId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.getComments(widget.postId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('가장 먼저 댓글을 남겨보세요.', style: TextStyle(color: Colors.grey[600])));
              }

              final comments = snapshot.data!.docs;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: StreamBuilder<int>(
                        stream: _firestoreService.getCommentsAndRepliesCount(widget.postId),
                        builder: (context, snapshot) {
                          return Text('댓글 ${snapshot.data ?? 0}개', style: Theme.of(context).textTheme.titleSmall);
                        }
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.zero,
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final commentDoc = comments[index];
                        return _buildCommentTree(commentDoc);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        _buildCommentInput(),
      ],
    );
  }

  Widget _buildCommentTree(DocumentSnapshot commentDoc) {
    final commentId = commentDoc.id;
    final isExpanded = _expandedReplies.putIfAbsent(commentId, () => false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: _firestoreService.getReplies(widget.postId, commentId),
          builder: (context, snapshot) {
            final replies = snapshot.data?.docs ?? [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCommentItem(
                  commentDoc.reference,
                  commentDoc.data() as Map<String, dynamic>,
                  replyCount: replies.length,
                  isExpanded: isExpanded,
                  onToggleReplies: () {
                    setState(() {
                      _expandedReplies[commentId] = !isExpanded;
                    });
                  },
                ),
                if (isExpanded)
                  Padding(
                    padding: const EdgeInsets.only(left: 58.0),
                    child: Column(
                      children: replies.map((replyDoc) {
                        return _buildCommentItem(
                          replyDoc.reference,
                          replyDoc.data() as Map<String, dynamic>,
                          isReply: true,
                        );
                      }).toList(),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildCommentItem(
      DocumentReference docRef,
      Map<String, dynamic> data, {
        bool isReply = false,
        int replyCount = 0,
        bool isExpanded = false,
        VoidCallback? onToggleReplies,
      }) {
    final author = data['author'] as Map<String, dynamic>? ?? {};
    final authorName = author['name'] ?? '알 수 없음';
    final authorImageSeed = author['imageSeed'] ?? 'default';
    final authorLevel = author['levelTitle'] ?? 'LV.1';
    final authorUid = author['uid'] as String?; // uid를 String? 타입으로 받습니다.

    bool isMyComment = authorUid != null && authorUid == FirebaseAuth.instance.currentUser?.uid;

    return Padding(
      padding: isReply
          ? const EdgeInsets.only(top: 12.0)
          : const EdgeInsets.fromLTRB(16, 12, 8, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 형님의 요청대로 수정된 부분 ---
          GestureDetector(
            onTap: () {
              if (authorUid != null) {
                _navigateToUserProfile(authorUid);
              }
            },
            child: CircleAvatar(radius: 18, backgroundImage: NetworkImage('https://picsum.photos/seed/$authorImageSeed/100/100')),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 형님의 요청대로 수정된 부분 ---
                GestureDetector(
                  onTap: () {
                    if (authorUid != null) {
                      _navigateToUserProfile(authorUid);
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Row가 최소한의 공간만 차지하도록 설정
                    children: [
                      Text(authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(4)),
                        child: Text(authorLevel, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(data['text'] ?? ''),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(_formatTimestamp(data['createdAt'] as Timestamp?), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    if (!isReply) ...[
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _replyingTo = {'id': docRef.id, 'name': authorName};
                            _editingDocRef = null;
                            _commentController.clear();
                          });
                          _commentFocusNode.requestFocus();
                        },
                        child: const Text('답글 달기', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ],
                ),
                if (!isReply && replyCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: InkWell(
                      onTap: onToggleReplies,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isExpanded ? '답글 숨기기' : '답글 $replyCount개 보기',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isMyComment)
            IconButton(
              icon: const Icon(Icons.more_horiz, size: 20, color: Colors.grey),
              onPressed: () => _showEditDeleteMenu(context, docRef, data['text']),
            )
        ],
      ),
    );
  }

  void _showEditDeleteMenu(BuildContext context, DocumentReference docRef, String currentText) {
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
                  _startEdit(docRef, currentText);
                },
              ),
              ListTile(leading: const Icon(Icons.delete_outline, color: Colors.red), title: const Text('삭제하기', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _firestoreService.deleteComment(docRef);
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

  Widget _buildCommentInput() {
    final isEditing = _editingDocRef != null;
    final isReplying = _replyingTo != null;
    String hintText = '댓글 달기...';
    if (isEditing) hintText = '댓글 수정...';
    if (isReplying) hintText = '${_replyingTo!['name']}님에게 답글 보내기';

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
            if (isReplying || isEditing)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Text(isReplying ? '${_replyingTo!['name']}님에게 답글 남기는 중...' : '댓글 수정 중...', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _replyingTo = null;
                          _cancelEdit();
                        });
                      },
                    )
                  ],
                ),
              ),
            Row(
              children: [
                CircleAvatar(radius: 18, backgroundImage: NetworkImage('https://picsum.photos/seed/${widget.currentUser['userImageSeed']}/100/100')),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    focusNode: _commentFocusNode,
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: hintText,
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Theme.of(context).dividerColor)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.orange, width: 2)),
                    ),
                    onSubmitted: (_) => _submitComment(),
                  ),
                ),
                TextButton(
                  onPressed: _submitComment,
                  child: Text(isEditing ? '수정' : '게시', style: const TextStyle(color: Colors.orange)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}