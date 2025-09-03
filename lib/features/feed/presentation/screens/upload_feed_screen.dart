// 📁 lib/src/screens/upload_feed_screen.dart
// [아우] 2025-09-02 최종 작전 완료: Custom Metadata 방식으로 업로드 로직 수정

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:spotter/main.dart';
import 'package:spotter/core/services/firestore_service.dart';

class UploadFeedScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;

  const UploadFeedScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<UploadFeedScreen> createState() => _UploadFeedScreenState();
}

class _UploadFeedScreenState extends State<UploadFeedScreen> {
  final _formKey = GlobalKey<FormState>();
  final _captionController = TextEditingController();
  final _tagsController = TextEditingController();
  final _firestoreService = FirestoreService();

  XFile? _image;
  bool _isLoading = false;

  DocumentSnapshot? _selectedStampDoc;

  Future<List<Map<String, dynamic>>> _getValidStampsWithStores(List<QueryDocumentSnapshot> stampDocs) async {
    final List<Future<Map<String, dynamic>?>> futures = stampDocs.map((stampDoc) async {
      final stampData = stampDoc.data() as Map<String, dynamic>;
      final storeId = stampData['storeId'] as String?;
      if (storeId == null) return null;
      final storeDoc = await FirebaseFirestore.instance.collection('stores').doc(storeId).get();
      if (storeDoc.exists) {
        return {'stampDoc': stampDoc, 'storeData': storeDoc.data()};
      }
      return null;
    }).toList();
    final results = await Future.wait(futures);
    return results.where((result) => result != null).cast<Map<String, dynamic>>().toList();
  }

  @override
  void dispose() {
    _captionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedImage != null) setState(() => _image = pickedImage);
  }

  // --- 🔥🔥🔥 [아우] 최종 작전: 이름표(Metadata)를 사용하는 업로드 로직! 🔥🔥🔥 ---
  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate() || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('사진과 내용을 모두 입력해주세요.'), backgroundColor: Colors.red));
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
      final postRef = FirebaseFirestore.instance.collection('posts').doc();

      // 1. Storage에 업로드할 파일과 '이름표(메타데이터)' 준비
      final imageFile = File(_image!.path);
      final metadata = SettableMetadata(customMetadata: {'authorUid': user.uid});
      final storageRef = FirebaseStorage.instance.ref('posts').child(postRef.id).child('main.jpg');

      // 2. 이름표와 함께 파일 업로드
      final uploadTask = await storageRef.putFile(imageFile, metadata);
      final imageUrl = await uploadTask.ref.getDownloadURL();

      // 3. Firestore 문서에 최종 데이터 기록
      final tags = _tagsController.text.trim().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      Map<String, dynamic> postData = {
        'id': postRef.id,
        'caption': _captionController.text.trim(),
        'tags': tags,
        'imageUrl': imageUrl,
        'author': { 'uid': user.uid, 'name': widget.currentUser['userName'], 'imageSeed': widget.currentUser['userImageSeed'], 'levelTitle': widget.currentUser['levelTitle'], },
        'authorUid': user.uid,
        'isCertified': _selectedStampDoc != null,
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 0, 'commentCount': 0,
      };

      WriteBatch batch = FirebaseFirestore.instance.batch();

      if (_selectedStampDoc != null) {
        final stampData = _selectedStampDoc!.data() as Map<String, dynamic>;
        final storeDoc = await FirebaseFirestore.instance.collection('stores').doc(stampData['storeId']).get();
        postData['storeId'] = stampData['storeId'];
        postData['storeName'] = storeDoc.data()?['storeName'];
        batch.update(_selectedStampDoc!.reference, {'postCreated': true});
      }

      batch.set(postRef, postData);
      await batch.commit();

      await _firestoreService.incrementUserXp(user.uid, 15 + (_selectedStampDoc != null ? 5 : 0));

      if (mounted) { mainScreenNavigator.value = 0; Navigator.of(context).popUntil((route) => route.isFirst); }
    } catch (e) {
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('게시 중 오류 발생: $e'), backgroundColor: Colors.red)); }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // (이하 build 메소드 및 다른 위젯들은 이전과 동일하게 유지됩니다)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( title: const Text('새 게시물 작성'), actions: [ TextButton( onPressed: _isLoading ? null : _submitPost, child: const Text('공유', style: TextStyle(fontSize: 16)), ), ], ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildCertificationSection(), const SizedBox(height: 24),
            _buildSection(title: '사진', child: _buildImagePicker()), const SizedBox(height: 24),
            _buildSection(title: '내용', child: TextFormField( controller: _captionController, decoration: const InputDecoration(hintText: '어떤 이야기를 공유하고 싶으신가요?', border: InputBorder.none), maxLines: 5, validator: (v) => (v == null || v.trim().isEmpty) ? '내용을 입력해주세요.' : null, )),
            const SizedBox(height: 24),
            _buildSection(title: '태그', child: TextFormField( controller: _tagsController, decoration: const InputDecoration(hintText: '쉼표(,)로 태그를 구분해주세요. (예: 등산,카페)', border: InputBorder.none), )),
          ],
        ),
      ),
    );
  }
  Widget _buildCertificationSection() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return const SizedBox.shrink();
    final query = FirebaseFirestore.instance.collection('users').doc(userId).collection('stamps').where('postCreated', isEqualTo: false).orderBy('timestamp', descending: true).limit(5);
    return Card( elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Theme.of(context).dividerColor)), child: Padding( padding: const EdgeInsets.all(16.0), child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ const Text('스탬프 기록으로 인증하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text('방문했던 장소에 대한 글을 작성하여 인증 뱃지를 획득하세요.', style: TextStyle(fontSize: 13, color: Colors.grey[600])), const Divider(height: 24), StreamBuilder<QuerySnapshot>( stream: query.snapshots(), builder: (context, snapshot) { if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator()); if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Text('인증할 수 있는 최근 스탬프 기록이 없습니다.'); final stampDocs = snapshot.data!.docs; return FutureBuilder<List<Map<String, dynamic>>>( future: _getValidStampsWithStores(stampDocs), builder: (context, validStampsSnapshot) { if (validStampsSnapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator()); if (!validStampsSnapshot.hasData || validStampsSnapshot.data!.isEmpty) return const Text('인증할 수 있는 유효한 스탬프 기록이 없습니다.'); final validStamps = validStampsSnapshot.data!; return SizedBox( height: 150, child: ListView.builder( itemCount: validStamps.length, itemBuilder: (context, index) { final stampDoc = validStamps[index]['stampDoc'] as DocumentSnapshot; final storeData = validStamps[index]['storeData'] as Map<String, dynamic>; final rewardData = (stampDoc.data() as Map<String, dynamic>)['rewardData'] as Map<String, dynamic>? ?? {}; final storeImageUrl = storeData['imageUrl'] as String?; final isSelected = _selectedStampDoc?.id == stampDoc.id; return Card( color: isSelected ? Colors.orange.withOpacity(0.2) : null, child: ListTile( leading: CircleAvatar( backgroundImage: storeImageUrl != null && storeImageUrl.isNotEmpty ? NetworkImage(storeImageUrl) : null, child: (storeImageUrl == null || storeImageUrl.isEmpty) ? const Icon(Icons.store) : null, ), title: Text(storeData['storeName'] ?? '이름 없는 가게'), subtitle: Text(rewardData['title'] ?? '리워드'), onTap: () => setState(() { _selectedStampDoc = isSelected ? null : stampDoc; }), ), ); }, ), ); }, ); }, ), ], ), ), );
  }
  Widget _buildSection({required String title, required Widget child}) { return Card(elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Theme.of(context).dividerColor)), child: Padding(padding: const EdgeInsets.all(16.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const Divider(height: 24), child]))); }
  Widget _buildImagePicker() { return InkWell(onTap: _pickImage, child: DottedBorder(color: Colors.grey.shade400, strokeWidth: 1.5, dashPattern: const [8, 6], radius: const Radius.circular(12), borderType: BorderType.RRect, child: SizedBox(height: 200, width: double.infinity, child: _image == null ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.photo_library_outlined, size: 48, color: Colors.grey), SizedBox(height: 8), Text('사진을 추가해주세요')]) : ClipRRect(borderRadius: BorderRadius.circular(11), child: Image.file(File(_image!.path), fit: BoxFit.cover))))); }
}