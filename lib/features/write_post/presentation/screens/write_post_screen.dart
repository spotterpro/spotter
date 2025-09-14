import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class WritePostScreen extends StatefulWidget {
  const WritePostScreen({super.key});

  @override
  State<WritePostScreen> createState() => _WritePostScreenState();
}

class _WritePostScreenState extends State<WritePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  final List<Map<String, String>> _stampedStores = [
    {'name': '카페 스프링', 'category': '카페'},
    {'name': '맛집 파스타', 'category': '음식점'},
    {'name': '클린 세탁소', 'category': '생활'},
  ];

  String? _selectedStore;
  final int _maxPhotos = 5;
  final List<XFile> _photos = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final remainingSlots = _maxPhotos - _photos.length;
    if (remainingSlots <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사진은 최대 5장까지 첨부할 수 있습니다.')),
      );
      return;
    }

    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();

      if (pickedFiles.isNotEmpty) {
        setState(() {
          if (pickedFiles.length > remainingSlots) {
            _photos.addAll(pickedFiles.sublist(0, remainingSlots));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('최대 5장까지 선택되어 일부 사진만 추가되었습니다.')),
            );
          } else {
            _photos.addAll(pickedFiles);
          }
        });
      }
    } catch (e) {
      print("이미지 선택 중 오류 발생: $e");
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: const Text(
          '새 게시물 작성',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Firestore에 게시물 공유 로직 구현
            },
            child: const Text(
              '공유',
              style: TextStyle(color: Color(0xFFFFA726), fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStampVerificationSection(),
            const SizedBox(height: 16),
            _buildPhotoAttachmentSection(),
            const SizedBox(height: 16),
            _buildContentSection(),
            const SizedBox(height: 16),
            _buildTagSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStampVerificationSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('스탬프 기록으로 인증하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('방문했던 장소에 대한 글을 작성하여 인증 뱃지를 획득하세요.', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _stampedStores.length,
                itemBuilder: (context, index) {
                  final store = _stampedStores[index];
                  final isSelected = _selectedStore == store['name'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedStore = null;
                        } else {
                          _selectedStore = store['name'];
                        }
                      });
                    },
                    child: Container(
                      width: 150,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.orange.shade50 : Colors.white,
                        border: Border.all(color: isSelected ? Colors.orange : Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 8),
                          ClipRRect(borderRadius: BorderRadius.circular(8), child: Container(width: 40, height: 40, color: Colors.grey.shade300)),
                          const SizedBox(width: 8),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(store['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(store['category']!, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoAttachmentSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('사진', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _photos.length < _maxPhotos ? _photos.length + 1 : _maxPhotos,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                if (index == _photos.length && _photos.length < _maxPhotos) {
                  return GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, color: Colors.grey),
                          SizedBox(height: 4),
                          Text('사진 추가', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                }
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.file(
                    File(_photos[index].path),
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('내용', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              maxLines: 6,
              decoration: const InputDecoration.collapsed(
                hintText: '어떤 이야기를 공유하고 싶으신가요?',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('태그', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration.collapsed(
                hintText: '쉼표(,)로 태그를 구분해주세요. (예: 동성로, 맛집)',
              ),
            ),
          ],
        ),
      ),
    );
  }
}