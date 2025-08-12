// 📁 lib/src/screens/admin/admin_application_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminApplicationDetailScreen extends StatefulWidget {
  final String applicationId;
  final Map<String, dynamic> applicationData;

  const AdminApplicationDetailScreen({
    super.key,
    required this.applicationId,
    required this.applicationData,
  });

  @override
  State<AdminApplicationDetailScreen> createState() => _AdminApplicationDetailScreenState();
}

class _AdminApplicationDetailScreenState extends State<AdminApplicationDetailScreen> {
  bool _isProcessing = false;

  Future<void> _updateStatus(String newStatus) async {
    setState(() { _isProcessing = true; });
    try {
      final docRef = FirebaseFirestore.instance
          .collection('store_applications')
          .doc(widget.applicationId);

      await docRef.update({'status': newStatus});

      if (newStatus == 'approved') {
        final storeData = {
          'storeName': widget.applicationData['storeName'],
          'category': widget.applicationData['category'],
          'story': widget.applicationData['story'],
          'address': widget.applicationData['address'],
          'phone': widget.applicationData['phone'],
          'hours': widget.applicationData['hours'],
          'imageUrl': widget.applicationData['imageUrl'],
          'ownerId': widget.applicationData['userId'],
          'createdAt': FieldValue.serverTimestamp(),
          'regulars': 0,
        };
        await FirebaseFirestore.instance.collection('stores').doc(widget.applicationId).set(storeData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('상태가 "$newStatus"(으)로 변경되었습니다.'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류 발생: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isProcessing = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.applicationData;
    return Scaffold(
      appBar: AppBar(
        title: Text('${data['storeName'] ?? '신청 상세'}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data['imageUrl'] != null)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    data['imageUrl'],
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 250,
                      color: Colors.grey[200],
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red),
                          SizedBox(height: 8),
                          Text('이미지를 불러올 수 없습니다.\n보안 규칙 또는 CORS 설정을 확인하십시오.'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            _buildInfoTile('가게 이름', data['storeName']),
            _buildInfoTile('카테고리', data['category']),
            _buildInfoTile('가게 이야기', data['story']),
            _buildInfoTile('가게 주소', data['address']),
            _buildInfoTile('전화번호', data['phone']),
            _buildInfoTile('영업 시간', data['hours']),
            _buildInfoTile('신청자 UID', data['userId']),
            const SizedBox(height: 32),
            if (_isProcessing)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus('approved'),
                      icon: const Icon(Icons.check),
                      label: const Text('승인'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus('rejected'),
                      icon: const Icon(Icons.close),
                      label: const Text('반려'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // --- 형님의 요청대로 수정된 부분 ---
  Widget _buildInfoTile(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          // Text를 SelectableText로 변경하여 복사 기능을 활성화합니다.
          SelectableText(
            value?.toString() ?? '정보 없음',
            style: const TextStyle(fontSize: 16),
          ),
          const Divider(height: 16),
        ],
      ),
    );
  }
}