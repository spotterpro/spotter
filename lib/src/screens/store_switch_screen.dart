// 📁 lib/src/screens/store_switch_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:spotter/src/screens/application_status_screen.dart'; // 추가된 부분

class StoreSwitchScreen extends StatefulWidget {
  const StoreSwitchScreen({super.key});

  @override
  State<StoreSwitchScreen> createState() => _StoreSwitchScreenState();
}

class _StoreSwitchScreenState extends State<StoreSwitchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _storyController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _hoursController = TextEditingController();

  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _storyController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
    }
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('가게 대표 사진을 등록해주세요.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }
      final userId = user.uid;

      final ref = FirebaseStorage.instance.ref('store_application_photos').child('$userId.jpg');
      await ref.putFile(File(_image!.path));
      final imageUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('store_applications').doc(userId).set({
        'userId': userId,
        'storeName': _nameController.text.trim(),
        'category': _categoryController.text.trim(),
        'story': _storyController.text.trim(),
        'address': _addressController.text.trim(),
        'phone': _phoneController.text.trim(),
        'hours': _hoursController.text.trim(),
        'imageUrl': imageUrl,
        'status': 'pending', // 심사 상태: 대기중
        'submittedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        // --- 형님의 요청대로 수정된 부분 ---
        // 신청 완료 후, '신청 현황' 화면으로 바로 이동합니다.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ApplicationStatusScreen(status: 'pending'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('가게 심사 신청'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            _buildTextFormField(
              controller: _nameController,
              labelText: '가게 이름',
              hintText: '예: 스포터 카페',
            ),
            _buildTextFormField(
              controller: _categoryController,
              labelText: '카테고리',
              hintText: '예: 카페, 음식점, 여가...',
            ),
            const SizedBox(height: 16),
            const Text('가게 대표 사진', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickImage,
              child: DottedBorder(
                color: Colors.grey.shade400,
                strokeWidth: 1,
                dashPattern: const [6, 6],
                radius: const Radius.circular(12),
                borderType: BorderType.RRect,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  child: _image == null
                      ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('파일 업로드'),
                      Text('PNG, JPG, GIF up to 10MB', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.file(File(_image!.path), fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildTextFormField(
              controller: _storyController,
              labelText: '가게 이야기',
              hintText: '손님들에게 가게를 소개해 주세요.',
              maxLines: 5,
            ),
            _buildTextFormField(
              controller: _addressController,
              labelText: '가게 주소',
              hintText: '정확한 주소를 입력해주세요.',
            ),
            _buildTextFormField(
              controller: _phoneController,
              labelText: '가게 전화번호',
              hintText: '예: 053-123-4567',
              keyboardType: TextInputType.phone,
            ),
            _buildTextFormField(
              controller: _hoursController,
              labelText: '영업 시간',
              hintText: '예: 매일 09:00 - 22:00',
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitApplication,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('심사 신청하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          alignLabelWithHint: true,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$labelText 항목은 필수입니다.';
          }
          return null;
        },
      ),
    );
  }
}