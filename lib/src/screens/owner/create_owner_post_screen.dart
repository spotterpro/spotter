// 📁 lib/src/screens/owner/create_owner_post_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateOwnerPostScreen extends StatefulWidget {
  const CreateOwnerPostScreen({super.key});

  @override
  State<CreateOwnerPostScreen> createState() => _CreateOwnerPostScreenState();
}

class _CreateOwnerPostScreenState extends State<CreateOwnerPostScreen> {
  final _formKey = GlobalKey<FormState>();
  // --- 🔥🔥🔥 수정된 부분: 제목 컨트롤러 제거 ---
  final _bodyController = TextEditingController();
  final _tagsController = TextEditingController();
  String? _selectedCategory;
  bool _isLoading = false;

  final List<Map<String, String>> _categories = [
    {'value': 'marketing', 'label': '마케팅 팁'},
    {'value': 'collaboration', 'label': '콜라보 제안'},
    {'value': 'qna', 'label': '질문'},
    {'value': 'free', 'label': '자유게시판'},
  ];

  @override
  void dispose() {
    _bodyController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카테고리를 선택해주세요.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final storeDoc = await FirebaseFirestore.instance.collection('stores').doc(user.uid).get();
      final storeData = storeDoc.data();
      final storeName = storeData?['storeName'] ?? '가게 정보 없음';
      final authorImageUrl = storeData?['imageUrl'];
      final userName = storeDoc.data()?['ownerName'] ?? '사장님';

      final tags = _tagsController.text.trim().split(' ').where((tag) => tag.startsWith('#') && tag.length > 1).map((tag) => tag.substring(1)).toList();

      await FirebaseFirestore.instance.collection('owner_posts').add({
        // --- 🔥🔥🔥 수정된 부분: title 필드 제거 ---
        'body': _bodyController.text.trim(),
        'tags': tags,
        'category': _selectedCategory,
        'authorUid': user.uid,
        'authorName': userName,
        'authorStoreImageUrl': authorImageUrl,
        'storeName': storeName,
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 0,
        'commentCount': 0,
      });

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시글 작성 중 오류 발생: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 글 작성'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: _isLoading ? null : _submitPost,
              child: const Text('게시', style: TextStyle(fontSize: 16)),
            ),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text('카테고리', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category['value'];
                return ChoiceChip(
                  label: Text(category['label']!),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = category['value'];
                      });
                    }
                  },
                  selectedColor: Colors.orange,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color),
                  backgroundColor: Theme.of(context).dividerColor.withOpacity(0.1),
                  shape: StadiumBorder(side: BorderSide(color: isSelected ? Colors.orange : Colors.grey.shade300)),
                  showCheckmark: false,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // --- 🔥🔥🔥 수정된 부분: 제목 입력란 제거 ---
            TextFormField(
              controller: _bodyController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '내용',
                alignLabelWithHint: true,
              ),
              maxLines: 15,
              validator: (value) => (value == null || value.isEmpty) ? '내용을 입력해주세요.' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '해시태그',
                hintText: '#태그1 #태그2 형식으로 입력',
              ),
            ),
          ],
        ),
      ),
    );
  }
}