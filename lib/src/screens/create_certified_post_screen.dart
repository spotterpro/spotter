import 'package:flutter/material.dart';

class CreateCertifiedPostScreen extends StatefulWidget {
  const CreateCertifiedPostScreen({super.key});

  @override
  State<CreateCertifiedPostScreen> createState() => _CreateCertifiedPostScreenState();
}

class _CreateCertifiedPostScreenState extends State<CreateCertifiedPostScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('인증 피드 작성'),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: 게시물 공유 로직
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // 선택 화면까지 닫기
            },
            child: const Text('공유'),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('사진', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
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
            const SizedBox(height: 24),
            const Text('내용', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: '맛집 파스타에서의 경험을 기록해보세요...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 24),
            const Text('태그', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
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