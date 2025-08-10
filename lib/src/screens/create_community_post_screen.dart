import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateCommunityPostScreen extends StatefulWidget {
  const CreateCommunityPostScreen({super.key});

  @override
  State<CreateCommunityPostScreen> createState() => _CreateCommunityPostScreenState();
}

class _CreateCommunityPostScreenState extends State<CreateCommunityPostScreen> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sharePost() async {
    if (_captionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내용을 입력해주세요.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final user = FirebaseAuth.instance.currentUser;
      // 쉼표로 태그를 분리하고, 각 태그 앞에 '#'를 붙입니다.
      final tags = _tagsController.text.split(',').map((tag) => '#${tag.trim()}').where((tag) => tag.length > 1).toList();

      await FirebaseFirestore.instance.collection('posts').add({
        'userName': '형님', // TODO: 실제 유저 이름으로 변경
        'userImageSeed': 'myprofile',
        'levelTitle': 'LV.25',
        'time': Timestamp.now(),
        'caption': _captionController.text.trim(),
        'tags': tags,
        'likes': 0,
        'comments': 0,
        'isCertified': false,
        'isHot': false,
        'commentsList': [],
      });

      if (mounted) {
        Navigator.of(context).pop();
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('커뮤니티 글 작성'),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _sharePost,
              child: const Text('공유'),
            )
          else
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('내용', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _captionController,
              decoration: InputDecoration(
                hintText: '동네 사람들과 나누고 싶은 이야기를 적어보세요.',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 10,
            ),
            const SizedBox(height: 24),
            const Text('태그', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _tagsController,
              decoration: InputDecoration(
                hintText: '쉼표(,)로 태그를 구분해주세요. (예: 동네질문,수다)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            const Text('사진 (선택)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Center(
                child: Icon(Icons.add_a_photo_outlined, size: 32, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}