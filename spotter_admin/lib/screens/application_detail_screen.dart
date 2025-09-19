import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// 데이터 모델을 확장하여 영업시간 관련 필드를 추가합니다.
class StoreApplication {
  final String id;
  final String imageUrl;
  final String storeName;
  final String category;
  final String address;
  final String detailAddress;
  final String story;
  final String ownerId;
  final String status;
  final List<String> operatingDays;
  final String operatingHours;
  final String breakTime;
  final double? latitude;
  final double? longitude;
  final String? geocodeError;

  StoreApplication.fromSnapshot(DocumentSnapshot snapshot)
      : id = snapshot.id,
  // as Map<String, dynamic>? ?? {} 구문을 사용하여 데이터가 null일 경우에도 앱이 중단되지 않도록 안정성을 높입니다.
        imageUrl = (snapshot.data() as Map<String, dynamic>? ?? {})['imageUrl'] ?? '',
        storeName = (snapshot.data() as Map<String, dynamic>? ?? {})['storeName'] ?? '정보 없음',
        category = (snapshot.data() as Map<String, dynamic>? ?? {})['category'] ?? '정보 없음',
        address = (snapshot.data() as Map<String, dynamic>? ?? {})['address'] ?? '정보 없음',
        detailAddress = (snapshot.data() as Map<String, dynamic>? ?? {})['addressDetail'] ?? '',
        story = (snapshot.data() as Map<String, dynamic>? ?? {})['story'] ?? '정보 없음',
        ownerId = (snapshot.data() as Map<String, dynamic>? ?? {})['ownerId'] ?? '정보 없음',
        status = (snapshot.data() as Map<String, dynamic>? ?? {})['status'] ?? '정보 없음',
        operatingDays = List<String>.from((snapshot.data() as Map<String, dynamic>? ?? {})['operatingDays'] ?? []),
        operatingHours = (snapshot.data() as Map<String, dynamic>? ?? {})['operatingHours'] ?? '정보 없음',
        breakTime = (snapshot.data() as Map<String, dynamic>? ?? {})['breakTime'] ?? '없음',
        latitude = (snapshot.data() as Map<String, dynamic>? ?? {})['latitude'],
        longitude = (snapshot.data() as Map<String, dynamic>? ?? {})['longitude'],
        geocodeError = (snapshot.data() as Map<String, dynamic>? ?? {})['geocodeError'];
}

class ApplicationDetailScreen extends StatefulWidget {
  final String applicationId;
  const ApplicationDetailScreen({super.key, required this.applicationId});

  @override
  State<ApplicationDetailScreen> createState() => _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  bool _isGeocoding = false;
  String? _errorMessage;
  final String kakaoRestApiKey = "2e8c74663cec574402127273f3597e1a"; // 형님의 REST API 키
  final _rejectionReasonController = TextEditingController();

  // 주소를 위경도로 변환하는 함수
  Future<void> _geocodeAddress(String address) async {
    if (address.isEmpty) {
      if (mounted) setState(() => _errorMessage = "주소가 비어있습니다.");
      return;
    }
    if (mounted) setState(() { _isGeocoding = true; _errorMessage = null; });

    final url = Uri.parse('https://dapi.kakao.com/v2/local/search/address.json?query=${Uri.encodeComponent(address)}');

    try {
      final response = await http.get(url, headers: {'Authorization': 'KakaoAK $kakaoRestApiKey'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['documents'].isNotEmpty) {
          final doc = data['documents'][0];
          final latitude = double.parse(doc['y']);
          final longitude = double.parse(doc['x']);
          await FirebaseFirestore.instance.collection('store_applications').doc(widget.applicationId).update({
            'latitude': latitude, 'longitude': longitude, 'geocodeError': FieldValue.delete(),
          });
        } else {
          await FirebaseFirestore.instance.collection('store_applications').doc(widget.applicationId).update({'geocodeError': 'ADDRESS_NOT_FOUND'});
          if (mounted) setState(() => _errorMessage = "해당 주소를 찾을 수 없습니다.");
        }
      } else {
        throw Exception('Failed to load coordinates. Status: ${response.statusCode}');
      }
    } catch (e) {
      await FirebaseFirestore.instance.collection('store_applications').doc(widget.applicationId).update({'geocodeError': 'API_CALL_FAILED'});
      if (mounted) setState(() => _errorMessage = "카카오 API 호출 실패: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isGeocoding = false);
    }
  }

  // 신청을 승인하는 함수
  Future<void> _approveApplication() async {
    // TODO: 승인 시 store_applications -> stores 컬렉션으로 데이터 이동 로직 추가 필요
    await FirebaseFirestore.instance.collection('store_applications').doc(widget.applicationId).update({'status': 'approved'});
    if (mounted) Navigator.of(context).pop();
  }

  // 반려 사유 입력 다이얼로그를 띄우는 함수
  Future<void> _showRejectionDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('반려 사유 입력'),
          content: TextField(
            controller: _rejectionReasonController,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(hintText: '반려 사유를 입력하세요...'),
          ),
          actions: [
            TextButton(
              child: const Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('반려 확정'),
              onPressed: () {
                if (_rejectionReasonController.text.isNotEmpty) {
                  _finalizeRejection(_rejectionReasonController.text);
                }
              },
            ),
          ],
        );
      },
    );
  }

  // 반려를 최종 처리하는 함수
  Future<void> _finalizeRejection(String reason) async {
    await FirebaseFirestore.instance.collection('store_applications').doc(widget.applicationId).update({
      'status': 'rejected',
      'rejectionReason': reason,
    });
    if (mounted) {
      Navigator.of(context).pop(); // 다이얼로그 닫기
      Navigator.of(context).pop(); // 상세 페이지 닫기
    }
  }

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('심사 신청 상세 정보'),
        elevation: 1,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('store_applications').doc(widget.applicationId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) { return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('데이터 로딩 에러: ${snapshot.error}', style: const TextStyle(color: Colors.red)))); }
          if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final application = StoreApplication.fromSnapshot(snapshot.data!);

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 이미지
                      if (application.imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            application.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200,
                            loadingBuilder: (context, child, progress) => progress == null ? child : const Center(heightFactor: 4, child: CircularProgressIndicator()),
                            errorBuilder: (context, error, stackTrace) => Container(height: 200, color: Colors.grey[200], child: const Center(child: Icon(Icons.error, color: Colors.red))),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // 좌표 정보
                      const Text('가게 좌표 정보', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (application.latitude != null && application.longitude != null)
                        Text('위도: ${application.latitude}\n경도: ${application.longitude}')
                      else if (application.geocodeError != null)
                        Text('좌표 변환 실패 (${application.geocodeError})', style: const TextStyle(color: Colors.red))
                      else
                        const Text('좌표 정보가 없습니다.', style: TextStyle(color: Colors.grey)),
                      if (_errorMessage != null)
                        Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(_errorMessage!, style: const TextStyle(color: Colors.red))),
                      const SizedBox(height: 16),
                      _isGeocoding
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton.icon(
                        icon: const Icon(Icons.map),
                        label: const Text('이 주소로 좌표 수동 변환'),
                        onPressed: () => _geocodeAddress(application.address),
                        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 44)),
                      ),
                      const Divider(height: 32),

                      // 신청 상세 정보
                      const Text('신청된 상세 정보', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildInfoRow('가게 이름', application.storeName),
                      _buildInfoRow('카테고리', application.category),
                      _buildInfoRow('신청된 주소', application.address),
                      // [추가] 상세주소 (값이 있을 때만 표시)
                      if (application.detailAddress.isNotEmpty)
                        _buildInfoRow('신청된 상세주소', application.detailAddress),
                      // [추가] 영업시간 관련 정보
                      if(application.operatingDays.isNotEmpty)
                        _buildInfoRow('영업 요일', application.operatingDays.join(', ')),
                      _buildInfoRow('영업 시간', application.operatingHours),
                      _buildInfoRow('브레이크 타임', application.breakTime),
                      // ---
                      _buildInfoRow('가게 이야기', application.story),
                      _buildInfoRow('신청자 ID', application.ownerId),
                      _buildInfoRow('상태', application.status),
                    ],
                  ),
                ),
              ),
              // 승인/반려 버튼
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _approveApplication,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, minimumSize: const Size(0, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        child: const Text('승인'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _showRejectionDialog,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, minimumSize: const Size(0, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        child: const Text('반려'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // 정보 행을 만드는 공통 위젯
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}