// 📁 lib/src/screens/create_community_post_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateCommunityPostScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;

  const CreateCommunityPostScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<CreateCommunityPostScreen> createState() => _CreateCommunityPostScreenState();
}

class _CreateCommunityPostScreenState extends State<CreateCommunityPostScreen> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  bool _isLoading = false;

  bool _isCreatingPoll = false;
  final List<TextEditingController> _pollOptionControllers = [];

  @override
  void initState() {
    super.initState();
    _pollOptionControllers.add(TextEditingController());
    _pollOptionControllers.add(TextEditingController());
  }

  @override
  void dispose() {
    _captionController.dispose();
    _tagsController.dispose();
    for (var controller in _pollOptionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addPollOption() {
    setState(() {
      _pollOptionControllers.add(TextEditingController());
    });
  }

  void _removePollOption(int index) {
    setState(() {
      _pollOptionControllers[index].dispose();
      _pollOptionControllers.removeAt(index);
    });
  }

  Future<void> _sharePost() async {
    final caption = _captionController.text.trim();
    if (caption.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내용을 입력해주세요.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("로그인이 필요합니다.");

      final tags = _tagsController.text.split(',').map((tag) => '#${tag.trim()}').where((tag) => tag.length > 1).toList();

      final postData = <String, dynamic>{
        'author': {
          'name': widget.currentUser['userName'],
          'imageSeed': widget.currentUser['userImageSeed'],
          'levelTitle': widget.currentUser['levelTitle'],
          'uid': user.uid,
        },
        'time': Timestamp.now(),
        'caption': caption,
        'tags': tags,
        'isCertified': false,
        'isHot': false,
      };

      if (_isCreatingPoll) {
        final options = _pollOptionControllers
            .map((controller) => controller.text.trim())
            .where((text) => text.isNotEmpty)
            .map((text) => {'text': text, 'votes': []})
            .toList();

        if (options.length < 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('투표 항목은 2개 이상이어야 합니다.'), backgroundColor: Colors.red),
          );
          setState(() { _isLoading = false; });
          return;
        }
        postData['poll'] = {'options': options};
      }

      await FirebaseFirestore.instance.collection('posts').add(postData);

      if (mounted) Navigator.of(context).pop();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
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
            if (!_isCreatingPoll)
              OutlinedButton.icon(
                icon: const Icon(Icons.poll_outlined),
                label: const Text('투표 추가'),
                onPressed: () => setState(() => _isCreatingPoll = true),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )
            else
              _buildPollCreator(),
          ],
        ),
      ),
    );
  }

  Widget _buildPollCreator() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('투표 만들기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => setState(() => _isCreatingPoll = false),
              )
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(_pollOptionControllers.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _pollOptionControllers[index],
                      decoration: InputDecoration(
                        hintText: '항목 ${index + 1}',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                  if (_pollOptionControllers.length > 2)
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => _removePollOption(index),
                    )
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('항목 추가'),
            onPressed: _addPollOption,
          ),
        ],
      ),
    );
  }
}