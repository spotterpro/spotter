import 'package:flutter/material.dart';

class WriteCommunityPostScreen extends StatefulWidget {
  const WriteCommunityPostScreen({super.key});

  @override
  State<WriteCommunityPostScreen> createState() => _WriteCommunityPostScreenState();
}

class _WriteCommunityPostScreenState extends State<WriteCommunityPostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

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
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          '커뮤니티 글쓰기',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              // TODO: 커뮤니티 게시물 Firestore에 저장
            },
            child: const Text(
              '게시',
              style: TextStyle(color: Color(0xFFFFA726), fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: '어떤 이야기를 공유하고 싶으신가요?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Color(0xFFFFA726)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('해시태그', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _tagsController,
                  decoration: InputDecoration(
                    hintText: '쉼표(,)로 태그를 구분해주세요.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Color(0xFFFFA726)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                // TODO: 투표 항목 추가 UI 로직 구현
              },
              icon: const Icon(Icons.timer_outlined, color: Colors.black54),
              label: const Text('투표 추가', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ],
        ),
      ),
    );
  }
}