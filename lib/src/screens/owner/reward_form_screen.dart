// 📁 lib/src/screens/owner/reward_form_screen.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum RewardCondition { visitCount, firstVisit, roulette }
enum UsageLimit { none, daily, weekly }

class RewardFormScreen extends StatefulWidget {
  final String storeId;
  const RewardFormScreen({super.key, required this.storeId});

  @override
  State<RewardFormScreen> createState() => _RewardFormScreenState();
}

class _RewardFormScreenState extends State<RewardFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _visitCountController = TextEditingController(text: '1');
  final _expiryController = TextEditingController(text: '30');

  XFile? _image;
  RewardCondition _selectedCondition = RewardCondition.visitCount;
  UsageLimit _selectedLimit = UsageLimit.none;
  bool _giftingEnabled = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _visitCountController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
    }
  }

  Future<void> _saveReward() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      String? rewardImageUrl;
      final storeRef = FirebaseFirestore.instance.collection('stores').doc(widget.storeId);
      final rewardId = storeRef.collection('rewards').doc().id;

      if (_image != null) {
        final ref = FirebaseStorage.instance.ref('reward_photos').child(widget.storeId).child('$rewardId.jpg');
        await ref.putFile(File(_image!.path));
        rewardImageUrl = await ref.getDownloadURL();
      }

      final storeSnapshot = await storeRef.get();
      final storeData = storeSnapshot.data();
      final storeName = storeData?['storeName'] ?? '알 수 없는 가게';
      final storeImageUrl = storeData?['imageUrl'];

      final rewardData = {
        'title': _nameController.text.trim(),
        'imageUrl': rewardImageUrl,
        'conditionType': _selectedCondition.name,
        'requiredStamps': _selectedCondition == RewardCondition.visitCount ? int.tryParse(_visitCountController.text) ?? 1 : 1,
        'expiryDays': int.tryParse(_expiryController.text) ?? 30,
        'usageLimit': _selectedLimit.name,
        'giftingEnabled': _giftingEnabled,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'storeId': widget.storeId,
        'storeName': storeName,
        'storeImageUrl': storeImageUrl,
      };

      final rewardRef = storeRef.collection('rewards').doc(rewardId);
      WriteBatch batch = FirebaseFirestore.instance.batch();
      batch.set(rewardRef, rewardData);
      batch.update(storeRef, {'hasRewards': true});
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('새로운 리워드가 저장되었습니다.'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 중 오류 발생: $e'), backgroundColor: Colors.red),
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
        title: const Text('새 리워드 만들기'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionTitle('리워드 이름'),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: '예: 아메리카노 1잔 무료'),
              validator: (v) => (v == null || v.isEmpty) ? '리워드 이름을 입력해주세요.' : null,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('리워드 사진 (선택)'),
            _buildImagePicker(),
            const SizedBox(height: 24),
            _buildSectionTitle('달성 조건'),
            _buildConditionChips(),
            if (_selectedCondition == RewardCondition.visitCount)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextFormField(
                  controller: _visitCountController,
                  decoration: const InputDecoration(labelText: '방문 횟수', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (v) => (v == null || v.isEmpty || int.tryParse(v) == null) ? '필요한 방문 횟수를 입력해주세요.' : null,
                ),
              ),
            const SizedBox(height: 24),
            _buildSectionTitle('사용 기한 (지급일로부터)'),
            TextFormField(
              controller: _expiryController,
              decoration: const InputDecoration(hintText: '예: 30', suffixText: '일'),
              keyboardType: TextInputType.number,
              validator: (v) => (v == null || v.isEmpty || int.tryParse(v) == null) ? '사용 기한을 입력해주세요.' : null,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('사용 제한'),
            _buildLimitChips(),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('쿠폰 선물하기 기능'),
              subtitle: const Text('사용자가 이 리워드를 다른 사람에게 1회 선물할 수 있습니다.'),
              value: _giftingEnabled,
              onChanged: (val) => setState(() => _giftingEnabled = val),
              activeColor: Colors.orange,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveReward,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('리워드 저장하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
    child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  );

  Widget _buildImagePicker() {
    return InkWell(
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
              Text('사진을 추가하여 리워드를 돋보이게 하세요'),
            ],
          )
              : ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Image.file(File(_image!.path), fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  Widget _buildConditionChips() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        _buildChoiceChip<RewardCondition>(context, '방문 횟수', RewardCondition.visitCount, _selectedCondition, (val) => setState(() => _selectedCondition = val)),
        _buildChoiceChip<RewardCondition>(context, '첫 방문', RewardCondition.firstVisit, _selectedCondition, (val) => setState(() => _selectedCondition = val)),
        _buildChoiceChip<RewardCondition>(context, 'NFC 태깅 (돌림판)', RewardCondition.roulette, _selectedCondition, (val) => setState(() => _selectedCondition = val)),
      ],
    );
  }

  Widget _buildLimitChips() {
    return Wrap(
      spacing: 8.0,
      children: [
        _buildChoiceChip<UsageLimit>(context, '없음', UsageLimit.none, _selectedLimit, (val) => setState(() => _selectedLimit = val)),
        _buildChoiceChip<UsageLimit>(context, '1일 1회', UsageLimit.daily, _selectedLimit, (val) => setState(() => _selectedLimit = val)),
        _buildChoiceChip<UsageLimit>(context, '주 1회', UsageLimit.weekly, _selectedLimit, (val) => setState(() => _selectedLimit = val)),
      ],
    );
  }

  Widget _buildChoiceChip<T>(BuildContext context, String label, T value, T groupValue, Function(T) onSelected) {
    final isSelected = value == groupValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(value),
      selectedColor: Colors.orange,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      backgroundColor: Colors.grey[200],
      shape: StadiumBorder(side: BorderSide(color: isSelected ? Colors.orange : Colors.grey[300]!)),
      showCheckmark: false,
    );
  }
}