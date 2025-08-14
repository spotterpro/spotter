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

  // ------------------------------
  // Firestore helpers
  // ------------------------------
  CollectionReference<Map<String, dynamic>> get _appsCol =>
      FirebaseFirestore.instance.collection('store_applications');

  DocumentReference<Map<String, dynamic>> get _appDoc =>
      _appsCol.doc(widget.applicationId);

  // 승인/반려 공통 업데이트
  Future<void> _updateStatus(String newStatus) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final now = FieldValue.serverTimestamp();
      final reviewerUid = FirebaseAuth.instance.currentUser?.uid;

      await _appDoc.update({
        'status': newStatus, // 'pending' | 'approved' | 'rejected'
        'reviewedAt': now,
        if (reviewerUid != null) 'reviewedBy': reviewerUid,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newStatus == 'approved' ? '승인 완료되었습니다.' : '반려 처리되었습니다.'),
          backgroundColor: newStatus == 'approved' ? Colors.green : Colors.orange,
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('업데이트 실패: ${e.message ?? e.code}'), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('업데이트 실패: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // 👑 --- 형님 요청: 영구 삭제 ---
  Future<void> _deleteApplication() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      // nfc_tags 서브컬렉션까지 정리 (있으면)
      final nfcCol = _appDoc.collection('nfc_tags');
      final nfcSnap = await nfcCol.get();
      if (nfcSnap.docs.isNotEmpty) {
        final batch = FirebaseFirestore.instance.batch();
        for (final d in nfcSnap.docs) {
          batch.delete(d.reference);
        }
        await batch.commit();
      }

      // 본문서 삭제
      await _appDoc.delete();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('신청 기록이 영구적으로 삭제되었습니다.'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(); // 목록으로 복귀
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 실패: ${e.message ?? e.code}'), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 실패: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showPermanentDeleteDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('신청 기록 영구 삭제'),
        content: const Text('정말 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteApplication();
            },
            child: const Text('영구 삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // NFC 태그 삭제 예시 (필요 시)
  Future<void> _deleteNfcTag(String tagId) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      await _appDoc.collection('nfc_tags').doc(tagId).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NFC 태그가 삭제되었습니다.'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('NFC 태그 삭제 실패: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showDeleteConfirmDialog(String tagId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('NFC 태그 삭제'),
        content: const Text('정말 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteNfcTag(tagId);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ------------------------------
  // UI
  // ------------------------------
  @override
  Widget build(BuildContext context) {
    // 최신 상태를 받기 위해 해당 문서를 스트림으로 구독
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _appDoc.snapshots(),
      builder: (context, snap) {
        // 초기엔 넘어온 데이터를 먼저 쓰고, 이후 스트림 갱신 반영
        final initial = widget.applicationData;
        Map<String, dynamic> data = Map<String, dynamic>.from(initial);
        if (snap.hasData && snap.data!.data() != null) {
          data = {...data, ...snap.data!.data()!}; // 최신 서버 데이터로 머지
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
                // 상단 이미지 (안전 조건부 표시)
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

                // 승인 완료 시 NFC 관리 섹션 표시
                if (status == 'approved') _buildNfcManagementSection(),

                const SizedBox(height: 16),

                // ✅ 버튼은 'pending'일 때만 노출 (심사대기 탭 전용)
                if (status == 'pending') ...[
                  if (_isProcessing)
                    const Center(child: CircularProgressIndicator())
                  else
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _updateStatus('approved'),
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
                            onPressed: () => _updateStatus('rejected'),
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

                // 👑 형님 지시: pending 이 아닐 때만 영구 삭제 노출
                if (status != 'pending') ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  if (_isProcessing)
                    const Center(child: CircularProgressIndicator())
                  else
                    ElevatedButton.icon(
                      onPressed: _showPermanentDeleteDialog,
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
    // 필요한 경우 실제 리스트업/추가/삭제 UI 구성
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
                    onPressed: () => _showDeleteConfirmDialog(tagId),
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
