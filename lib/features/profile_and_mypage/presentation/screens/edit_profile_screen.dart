// 📁 lib/src/screens/edit_profile_screen.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentNickname;
  final String currentBio;
  final List<String> currentInterests; // ✅ 전달 받으면 초기 선택에 반영
  const EditProfileScreen({
    super.key,
    required this.currentNickname,
    required this.currentBio,
    this.currentInterests = const [],
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nicknameController;
  late TextEditingController _bioController;

  final List<String> _allInterests = const [
    '#맛집탐방', '#카페투어', '#산책', '#운동', '#사진찍기', '#여행', '#쇼핑', '#독서', '#영화감상'
  ];
  late final Set<String> _selectedInterests;

  bool _checking = false;
  bool _nickOk = true; // 기본값: 기존 닉네임이면 true
  String _nickMsg = '';
  Color _nickMsgColor = Colors.green;

  File? _pickedImage;
  String? _newPhotoUrl; // 업로드 후 미리보기 갱신용

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.currentNickname);
    _bioController = TextEditingController(text: widget.currentBio);
    _selectedInterests = {...widget.currentInterests};

    _nicknameController.addListener(() {
      // 닉네임이 원래와 다르면 다시 체크 필요
      final changed = _nicknameController.text.trim() != widget.currentNickname;
      if (changed && _nickOk) {
        setState(() {
          _nickOk = false;
          _nickMsg = '';
        });
      }
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x != null) {
      setState(() => _pickedImage = File(x.path));
    }
  }

  Future<void> _checkNickname() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.length < 2) {
      setState(() {
        _nickOk = false;
        _nickMsg = '닉네임은 2글자 이상이어야 합니다.';
        _nickMsgColor = Colors.red;
      });
      return;
    }
    setState(() => _checking = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final qs = await FirebaseFirestore.instance
          .collection('users')
          .where('userName', isEqualTo: nickname)
          .limit(1)
          .get();
      final duplicated = qs.docs.isNotEmpty && qs.docs.first.id != uid;

      setState(() {
        if (duplicated) {
          _nickOk = false;
          _nickMsg = '이미 사용 중인 닉네임입니다.';
          _nickMsgColor = Colors.red;
        } else {
          _nickOk = true;
          _nickMsg = '사용 가능한 닉네임입니다.';
          _nickMsgColor = Colors.green;
        }
      });
    } catch (e) {
      setState(() {
        _nickOk = false;
        _nickMsg = '중복 확인 실패: $e';
        _nickMsgColor = Colors.red;
      });
    } finally {
      setState(() => _checking = false);
    }
  }

  Future<String?> _uploadAvatarIfNeeded(String uid) async {
    if (_pickedImage == null) return null;
    final ref = FirebaseStorage.instance.ref().child('avatars/$uid.jpg');
    await ref.putFile(_pickedImage!);
    return await ref.getDownloadURL();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final newNick = _nicknameController.text.trim();

    // 새 닉네임이면 체크 필수
    if (newNick != widget.currentNickname && !_nickOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임 중복 확인을 해주세요.'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      setState(() => _checking = true);
      final url = await _uploadAvatarIfNeeded(uid);
      if (url != null) _newPhotoUrl = url;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'userName': newNick,
        'bio': _bioController.text.trim(),
        'interests': _selectedInterests.toList(),
        if (url != null) 'photoUrl': url,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      Navigator.pop(context); // 스트림으로 마이페이지 자동 갱신
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSave = (_nicknameController.text.trim() == widget.currentNickname) || _nickOk;

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 편집'),
        actions: [
          TextButton(
            onPressed: canSave && !_checking ? _save : null,
            child: Text(
              '완료',
              style: TextStyle(
                fontSize: 16,
                color: canSave && !_checking ? Colors.orange : Colors.grey,
              ),
            ),
          ),
        ],
      ),
      body: AbsorbPointer(
        absorbing: _checking,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _pickedImage != null
                        ? FileImage(_pickedImage!)
                        : (_newPhotoUrl != null
                        ? NetworkImage(_newPhotoUrl!)
                        : null) as ImageProvider<Object>?,
                    child: (_pickedImage == null && _newPhotoUrl == null)
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Theme.of(context).colorScheme.onSurface,
                        child: Icon(Icons.camera_alt,
                            color: Theme.of(context).colorScheme.surface, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nicknameController,
                          decoration: const InputDecoration(
                            labelText: '닉네임',
                            border: OutlineInputBorder(),
                          ),
                          maxLength: 20,
                          validator: (v) =>
                          (v == null || v.trim().length < 2) ? '닉네임은 2글자 이상' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _checking ? null : _checkNickname,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        child: _checking
                            ? const SizedBox(
                            width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('중복 확인'),
                      ),
                    ],
                  ),
                  if (_nickMsg.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                      child: Text(_nickMsg, style: TextStyle(color: _nickMsgColor, fontSize: 12)),
                    ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bioController,
                    decoration: const InputDecoration(labelText: '자기소개', border: OutlineInputBorder()),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('관심사', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8, runSpacing: 4,
              children: _allInterests.map((interest) {
                final selected = _selectedInterests.contains(interest);
                return ChoiceChip(
                  label: Text(interest),
                  selected: selected,
                  onSelected: (on) {
                    setState(() {
                      if (on) { _selectedInterests.add(interest); }
                      else { _selectedInterests.remove(interest); }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
