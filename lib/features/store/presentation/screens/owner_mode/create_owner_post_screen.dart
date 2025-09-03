import 'package:flutter/material.dart';

class CreateOwnerPostScreen extends StatefulWidget {
  // [아우] 🔥🔥🔥 여기가 핵심 수정 지점입니다! 🔥🔥🔥
  // 누가 글을 쓰는지 알아야 하므로, currentUser 정보를 받습니다.
  final Map<String, dynamic> currentUser;

  const CreateOwnerPostScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<CreateOwnerPostScreen> createState() => _CreateOwnerPostScreenState();
}

class _CreateOwnerPostScreenState extends State<CreateOwnerPostScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _content = '';

  void _submitPost() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // TODO: FirestoreService를 호출하여 게시물 생성 로직 구현
      // 예: _firestoreService.createOwnerPost(
      //      title: _title,
      //      content: _content,
      //      author: widget.currentUser,
      // );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사장님 광장 글쓰기'),
        actions: [
          TextButton(
            onPressed: _submitPost,
            child: const Text('게시', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: '제목'),
                validator: (value) => value!.isEmpty ? '제목을 입력하세요.' : null,
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: '내용',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  validator: (value) => value!.isEmpty ? '내용을 입력하세요.' : null,
                  onSaved: (value) => _content = value!,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}