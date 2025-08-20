// 📁 lib/src/screens/admin/admin_application_detail_screen.dart (반려 사유 기능 추가 최종본)

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

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
  late final TextEditingController _latController;
  late final TextEditingController _lngController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final GeoPoint currentLocation = widget.applicationData['location'] ?? const GeoPoint(0, 0);
    _latController = TextEditingController(text: currentLocation.latitude.toString());
    _lngController = TextEditingController(text: currentLocation.longitude.toString());
    _addressController = TextEditingController(text: widget.applicationData['address'] ?? '');
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  DocumentReference<Map<String, dynamic>> get _storeDoc =>
      FirebaseFirestore.instance.collection('stores').doc(widget.applicationId);

  Future<void> _searchCoordinates() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('주소를 입력해주세요.'), backgroundColor: Colors.orange),
      );
      return;
    }

    const kakaoRestApiKey = '2e8c74663cec574402127273f3597e1a';

    final url = Uri.parse('https://dapi.kakao.com/v2/local/search/address.json?query=${Uri.encodeComponent(address)}');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'KakaoAK $kakaoRestApiKey'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['documents'] != null && data['documents'].isNotEmpty) {
          final doc = data['documents'][0];
          final lng = doc['x'];
          final lat = doc['y'];
          setState(() {
            _latController.text = lat;
            _lngController.text = lng;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('좌표를 성공적으로 찾았습니다.'), backgroundColor: Colors.green),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('해당 주소의 좌표를 찾을 수 없습니다.'), backgroundColor: Colors.orange),
          );
        }
      } else {
        throw Exception('카카오 API 호출 실패: ${response.body}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('좌표 검색 중 오류 발생: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _approveApplication() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final double? lat = double.tryParse(_latController.text.trim());
      final double? lng = double.tryParse(_lngController.text.trim());

      if (lat == null || lng == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('유효한 숫자 형식의 위도와 경도를 입력해주세요.'), backgroundColor: Colors.red),
          );
        }
        setState(() => _isProcessing = false);
        return;
      }

      final newLocation = GeoPoint(lat, lng);

      await _storeDoc.update({
        'status': 'awaiting_nfc',
        'location': newLocation,
        'address': _addressController.text.trim(),
        'reviewedAt': FieldValue.serverTimestamp(),
        if (FirebaseAuth.instance.currentUser != null)
          'reviewedBy': FirebaseAuth.instance.currentUser!.uid,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('1차 승인 완료. 사용자의 NFC 등록을 대기합니다.'), backgroundColor: Colors.blue),
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

  Future<void> _rejectApplication() async {
    if (_isProcessing) return;

    final reason = await _showRejectReasonDialog(context);

    if (reason != null && reason.isNotEmpty) {
      setState(() => _isProcessing = true);
      try {
        await _storeDoc.update({
          'status': 'rejected',
          'rejectionReason': reason,
          'reviewedAt': FieldValue.serverTimestamp(),
          if (FirebaseAuth.instance.currentUser != null)
            'reviewedBy': FirebaseAuth.instance.currentUser!.uid,
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('반려 처리되었습니다.'), backgroundColor: Colors.orange),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('반려 처리 중 오류 발생: $e'), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isProcessing = false);
      }
    }
  }

  Future<String?> _showRejectReasonDialog(BuildContext context) {
    final reasonController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('심사 반려'),
          content: TextField(
            controller: reasonController,
            autofocus: true,
            decoration: const InputDecoration(hintText: '반려 사유를 입력하세요...'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              child: const Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('반려 확정'),
              onPressed: () {
                Navigator.of(context).pop(reasonController.text.trim());
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteApplication() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final nfcCol = _storeDoc.collection('nfc_tags');
      final nfcSnap = await nfcCol.get();
      final batch = FirebaseFirestore.instance.batch();
      for (final d in nfcSnap.docs) {
        batch.delete(d.reference);
      }
      batch.delete(_storeDoc);
      await batch.commit();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('가게 정보가 영구 삭제되었습니다.'), backgroundColor: Colors.green));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 중 오류 발생: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _storeDoc.snapshots(),
      builder: (context, snap) {
        final Map<String, dynamic> data = snap.hasData && snap.data!.exists
            ? snap.data!.data()!
            : widget.applicationData;

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
                if (hasImage)
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
                _buildInfoTile('가게 이름', data['storeName']),
                _buildInfoTile('카테고리', data['category']),
                _buildInfoTile('가게 이야기', data['story']),

                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _addressController,
                  labelText: '가게 주소',
                  keyboardType: TextInputType.streetAddress,
                ),

                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isProcessing ? null : _searchCoordinates,
                    icon: const Icon(Icons.search),
                    label: const Text('입력된 주소로 좌표 검색'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextFormField(
                        controller: _latController,
                        labelText: '위도 (Latitude)',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextFormField(
                        controller: _lngController,
                        labelText: '경도 (Longitude)',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24, thickness: 1),

                _buildInfoTile('전화번호', data['phone']),
                _buildInfoTile('영업 시간', data['hours']),
                _buildInfoTile('신청자 ID', data['ownerId']),
                _buildInfoTile('현재 상태', status),
                const SizedBox(height: 16),

                if (status == 'approved') _buildNfcManagementSection(),
                const SizedBox(height: 16),

                if (status == 'pending')
                  _isProcessing
                      ? const Center(child: CircularProgressIndicator())
                      : Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _approveApplication,
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('1차 승인'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
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
                if (status != 'pending') ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  _isProcessing
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                    onPressed: () => _showPermanentDeleteDialog(context),
                    icon: const Icon(Icons.delete_forever_outlined),
                    label: const Text('가게 정보 영구 삭제'),
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
          stream: _storeDoc.collection('nfc_tags').snapshots(),
          builder: (context, snap) {
            if (snap.hasError) {
              return Text('오류: ${snap.error}', style: const TextStyle(color: Colors.red));
            }
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
                    onPressed: () => _showDeleteConfirmDialog(context, tagId),
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

  void _showPermanentDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('영구 삭제 확인'),
          content: const Text('정말로 이 가게 정보를 모두 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              child: const Text('삭제', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(ctx).pop();
                _deleteApplication();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, String tagId) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('NFC 태그 삭제 확인'),
          content: Text('정말로 이 NFC 태그($tagId)를 삭제하시겠습니까?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('취소')),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await _storeDoc.collection('nfc_tags').doc(tagId).delete();
              },
              child: const Text('삭제', style: TextStyle(color: Colors.red)),
            )
          ],
        );
      },
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

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '값을 입력해주세요.';
          }
          if (keyboardType == const TextInputType.numberWithOptions(decimal: true, signed: true) && double.tryParse(value.trim()) == null) {
            return '유효한 숫자를 입력해주세요.';
          }
          return null;
        },
      ),
    );
  }
}