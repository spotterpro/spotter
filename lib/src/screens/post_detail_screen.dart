// 📁 lib/src/screens/post_detail_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spotter/models/user_model.dart';
import 'package:spotter/src/widgets/feed_card.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  Future<void> _deletePost() async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(widget.postId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('게시물이 삭제되었습니다.')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('삭제 중 오류: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시물'),
      ),
      body: currentUser == null
          ? const Center(child: Text('로그인이 필요합니다.'))
          : StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) return const Center(child: CircularProgressIndicator());
          final currentUserProfile = UserProfile.fromDocument(userSnapshot.data!);

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('posts').doc(widget.postId).snapshots(),
            builder: (context, postSnapshot) {
              if (postSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!postSnapshot.hasData || !postSnapshot.data!.exists) {
                return const Center(child: Text('게시물을 찾을 수 없거나 삭제되었습니다.'));
              }

              final postData = postSnapshot.data!.data() as Map<String, dynamic>;
              final itemWithId = {...postData, 'id': postSnapshot.data!.id};

              return SingleChildScrollView(
                child: FeedCard(
                  item: itemWithId,
                  currentUser: currentUserProfile.toMap(),
                  onDelete: _deletePost,
                  // onUpdate 기능이 필요하면 MyPageScreen처럼 구현합니다.
                ),
              );
            },
          );
        },
      ),
    );
  }
}