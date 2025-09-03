// 📁 lib/src/screens/create_certified_post_screen.dart
// [아우] 2025-09-01 스탬프 인증 게시물 작성 기능 전체 구현 완료

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spotter/core/services/firestore_service.dart';

class CreateCertifiedPostScreen extends StatefulWidget {
  final DocumentSnapshot stampDoc;
  final Map<String, dynamic> currentUser;

  const CreateCertifiedPostScreen({
    super.key,
    required this.stampDoc,
    required this.currentUser,
  });

  @override
  State<CreateCertifiedPostScreen> createState() =>
      _CreateCertifiedPostScreenState();
}

class _CreateCertifiedPostScreenState extends State<CreateCertifiedPostScreen> {
  final _captionController = TextEditingController();
  final _tagsController = TextEditingController();
  final _firestoreService = FirestoreService();

  File? _pickedImageFile;
  bool _isLoading = false;

  late final Map<String, dynamic> _stampData;
  Map<String, dynamic>? _storeData;

  @override
  void initState() {
    super.initState();
    _stampData = widget.stampDoc.data() as Map<String, dynamic>;
    _fetchStoreData();
  }

  Future<void> _fetchStoreData() async {
    final storeId = _stampData['storeId'];
    if (storeId == null) return;
    final storeDoc = await FirebaseFirestore.instance.collection('stores').doc(storeId).get();
    if (storeDoc.exists && mounted) {
      setState(() {
        _storeData = storeDoc.data();
      });
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (pickedImage == null) return;
    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });
  }

  Future<void> _sharePost() async {
    if (_pickedImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('인증을 위한 사진을 추가해주세요.'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_captionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내용을 입력해주세요.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
      setState(() => _isLoading = false);
      return;
    }

    try {
      // 1. 껍데기 문서 생성
      final postRef = FirebaseFirestore.instance.collection('posts').doc();
      await postRef.set({
        'authorUid': user.uid,
        'author': { 'uid': user.uid },
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. 이미지 업로드
      final storageRef = FirebaseStorage.instance.ref('post_photos').child('${postRef.id}.jpg');
      await storageRef.putFile(_pickedImageFile!);
      final imageUrl = await storageRef.getDownloadURL();

      // 3. 최종 데이터 구성 및 원자적 쓰기
      final tags = _tagsController.text.trim().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      final finalPostData = {
        'id': postRef.id,
        'caption': _captionController.text.trim(),
        'tags': tags,
        'imageUrl': imageUrl,
        'author': {
          'uid': user.uid,
          'name': widget.currentUser['userName'],
          'imageSeed': widget.currentUser['userImageSeed'],
          'levelTitle': widget.currentUser['levelTitle'],
        },
        'authorUid': user.uid,
        'isCertified': true,
        'storeId': _stampData['storeId'],
        'storeName': _storeData?['storeName'] ?? '알 수 없는 가게',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 0,
        'commentCount': 0,
      };

      WriteBatch batch = FirebaseFirestore.instance.batch();
      batch.set(postRef, finalPostData);
      batch.update(widget.stampDoc.reference, {'postCreated': true});
      await batch.commit();

      // 4. XP 지급 (인증 게시물은 20점)
      await _firestoreService.incrementUserXp(user.uid, 20);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('인증 게시물이 공유되었습니다!')));
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시 중 오류 발생: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('인증 피드 작성'),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _sharePost,
              child: const Text('공유'),
            )
          else
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_storeData != null)
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: _storeData!['imageUrl'] != null
                      ? NetworkImage(_storeData!['imageUrl'])
                      : null,
                  child: _storeData!['imageUrl'] == null ? const Icon(Icons.store) : null,
                ),
                title: Text('${_storeData!['storeName']} 방문 인증'),
                subtitle: const Text('이 장소에 대한 경험을 공유해주세요.'),
                contentPadding: EdgeInsets.zero,
              ),
            const Divider(height: 24),
            const Text('사진', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: _pickedImageFile != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _pickedImageFile!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
                  : Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.add_a_photo_outlined, size: 48, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('내용', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _captionController,
              decoration: InputDecoration(
                hintText: '${_storeData?['storeName'] ?? '이곳'}에서의 경험을 기록해보세요...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 24),
            const Text('태그', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _tagsController,
              decoration: InputDecoration(
                hintText: '쉼표(,)로 태그를 구분해주세요. (예: #동성로맛집)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}