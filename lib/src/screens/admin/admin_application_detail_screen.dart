// 📁 lib/src/screens/admin/admin_application_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  DocumentReference<Map<String, dynamic>> get _appDoc =>
      FirebaseFirestore.instance.collection('store_applications').doc(widget.applicationId);

  // 🔥 추가된 부분: 'stores' 컬렉션에 실제 가게를 생성하는 로직
  Future<void> _approveApplication() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final now = FieldValue.serverTimestamp();
      final reviewerUid = FirebaseAuth.instance.currentUser?.uid;
      final applicationData = widget.applicationData;

      WriteBatch batch = FirebaseFirestore.instance.batch();

      // 1. stores 컬렉션에 새로운 가게 문서 생성
      final storeRef = FirebaseFirestore.instance.collection('stores').doc(widget.applicationId);
      batch.set(storeRef, {
        'ownerId': applicationData['userId'],
        'storeName': applicationData['storeName'],
        'category': applicationData['category'],
        'story': applicationData['story'],
        'address': applicationData['address'],
        'phone': applicationData['phone'],
        'hours': applicationData['hours'],
        'imageUrl': applicationData['imageUrl'],
        'createdAt': now,
        'nfcEnabled': false, // 초기 NFC 상태는 비활성화
      });

      // 2. store_applications 문서의 상태를 'approved'로 업데이트
      batch.update(_appDoc, {
        'status': 'approved',
        'reviewedAt': now,
        if (reviewerUid != null) 'reviewedBy': reviewerUid,
      });

      await batch.commit();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('승인 완료 및 가게가 활성화되었습니다.'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('승인 처리 중 오류 발생: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // 🔥 수정된 부분: '반려' 로직 분리
  Future<void> _rejectApplication() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      await _appDoc.update({
        'status': 'rejected',
        'reviewedAt': FieldValue.serverTimestamp(),
        if (FirebaseAuth.instance.currentUser != null) 'reviewedBy': FirebaseAuth.instance.currentUser!.uid,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('반려 처리되었습니다.'), backgroundColor: Colors.orange),
      );
    } catch (e) {
      // ... 오류 처리
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _deleteApplication() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final nfcCol = _appDoc.collection('nfc_tags');
      final nfcSnap = await nfcCol.get();
      final batch = FirebaseFirestore.instance.batch();
      for (final d in nfcSnap.docs) {
        batch.delete(d.reference);
      }
      batch.delete(_appDoc); // 신청서 삭제
      // 🔥 추가된 부분: stores 컬렉션의 문서도 함께 삭제
      batch.delete(FirebaseFirestore.instance.collection('stores').doc(widget.applicationId));
      await batch.commit();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('신청 기록 및 가게 정보가 영구 삭제되었습니다.'), backgroundColor: Colors.green));
      Navigator.of(context).pop();
    } catch (e) {
      // ... 오류 처리
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // 이하 UI 코드 생략... (기존과 동일)
  // ...
  // 기존 UI 코드는 그대로 두시면 됩니다. 아래는 기존 코드에서 버튼 부분만 수정한 내용입니다.
  // ...
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _appDoc.snapshots(),
      builder: (context, snap) {
        final initial = widget.applicationData;
        Map<String, dynamic> data = Map<String, dynamic>.from(initial);
        if (snap.hasData && snap.data!.data() != null) {
          data = {...data, ...snap.data!.data()!};
        }

        final status = (data['status'] as String?) ?? 'pending';
        final hasImage = (data['imageUrl'] is String) && (data['imageUrl'] as String).trim().isNotEmpty;

        return Scaffold(
          appBar: AppBar(
            title: Text('${data['storeName'] ?? '신청 상세'}'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasImage) ...[
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        data['imageUrl'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                        errorBuilder: (_, __, ___) => const SizedBox(
                          height: 200,
                          child: Center(child: Text('이미지를 불러오지 못했습니다.')),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                _buildInfoTile('가게 이름', data['storeName']),
                _buildInfoTile('카테고리', data['category']),
                _buildInfoTile('가게 이야기', data['story']),
                _buildInfoTile('가게 주소', data['address']),
                _buildInfoTile('전화번호', data['phone']),
                _buildInfoTile('영업 시간', data['hours']),
                _buildInfoTile('신청자 UID', data['userId']),
                _buildInfoTile('현재 상태', status),
                const SizedBox(height: 16),

                if (status == 'approved') _buildNfcManagementSection(),
                const SizedBox(height: 16),

                if (status == 'pending') ...[
                  if (_isProcessing)
                    const Center(child: CircularProgressIndicator())
                  else
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            // 🔥 수정된 부분: _approveApplication 호출
                            onPressed: _approveApplication,
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('승인'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              backgroundColor: Colors.green[700],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            // 🔥 수정된 부분: _rejectApplication 호출
                            onPressed: _rejectApplication,
                            icon: const Icon(Icons.cancel_outlined),
                            label: const Text('반려'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              backgroundColor: Colors.orange[700],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],

                if (status != 'pending') ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  if (_isProcessing)
                    const Center(child: CircularProgressIndicator())
                  else
                    ElevatedButton.icon(
                      onPressed: () { /* _showPermanentDeleteDialog() - 이 함수는 이미 존재 */ },
                      icon: const Icon(Icons.delete_forever_outlined),
                      label: const Text('이 신청 기록 영구 삭제'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNfcManagementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('NFC 관리', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _appDoc.collection('nfc_tags').snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snap.data?.docs ?? [];
            if (docs.isEmpty) {
              return const Text('등록된 NFC 태그가 없습니다.');
            }
            return Column(
              children: docs.map((d) {
                final tag = d.data();
                final tagId = d.id;
                final uid = tag['uid'] ?? '(UID 없음)';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('태그 UID: $uid'),
                  subtitle: Text('문서 ID: $tagId'),
                  trailing: IconButton(
                    onPressed: () { /* _showDeleteConfirmDialog(tagId) */ },
                    icon: const Icon(Icons.delete_outline),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoTile(String title, dynamic value) {
    final v = (value == null || (value is String && value.trim().isEmpty)) ? '—' : value.toString();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 96, child: Text(title, style: const TextStyle(color: Colors.grey))),
          const SizedBox(width: 12),
          Expanded(child: Text(v)),
        ],
      ),
    );
  }
}