// 📁 lib/src/screens/admin/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotter/features/admin/presentation/screens/admin_application_detail_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('가게 심사 대시보드'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '새로고침',
            onPressed: () {
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: '로그아웃',
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '전체 목록 (실험)'), // 탭 이름을 '전체 목록'으로 변경
            Tab(text: '승인 완료'),
            Tab(text: '반려된 요청'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // --- 🔥🔥🔥 이 부분의 쿼리를 수정했습니다! ---
          _buildApplicationList(status: 'all'), // 모든 문서를 가져오도록 'all'이라는 특별 상태를 사용
          _buildApplicationList(status: 'approved'),
          _buildApplicationList(status: 'rejected'),
        ],
      ),
    );
  }

  Widget _buildApplicationList({required String status}) {
    String emptyMessage = '해당 상태의 요청이 없습니다.';
    if (status == 'all') emptyMessage = 'stores 컬렉션에 문서가 없습니다.';
    if (status == 'approved') emptyMessage = '승인 완료된 요청이 없습니다.';
    if (status == 'rejected') emptyMessage = '반려된 요청이 없습니다.';

    // status 값에 따라 쿼리를 동적으로 변경합니다.
    Query query = FirebaseFirestore.instance.collection('stores');
    if (status != 'all') {
      query = query.where('status', isEqualTo: status);
    }
    // 정렬은 일단 제거합니다.
    // query = query.orderBy('createdAt', descending: true);

    print("Firestore 쿼리 실행: collection=stores, status=$status");

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print("Firestore 스트림 에러: ${snapshot.error}");
          return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          print("데이터 없음: $emptyMessage");
          return Center(
            child: Text(emptyMessage, style: const TextStyle(fontSize: 18, color: Colors.grey)),
          );
        }

        final applications = snapshot.data!.docs;
        print("데이터 조회 성공: ${applications.length}개 문서 발견");

        return ListView.builder(
          itemCount: applications.length,
          itemBuilder: (context, index) {
            final doc = applications[index];
            final data = doc.data() as Map<String, dynamic>;

            // 문서의 모든 내용을 콘솔에 출력하여 데이터를 확인합니다.
            print("문서[${index}] 내용: $data");

            final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
            final currentStatus = data['status'] ?? '상태 불명';

            return ListTile(
              leading: Icon(_getIconForStatus(currentStatus)),
              title: Text(data['storeName'] ?? '이름 없음'),
              subtitle: Text('상태: $currentStatus | 신청일: ${createdAt?.toLocal().toString().substring(0, 16) ?? '알 수 없음'}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminApplicationDetailScreen(
                      applicationId: doc.id,
                      applicationData: data,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  IconData _getIconForStatus(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty_rounded;
      case 'approved':
        return Icons.check_circle_outline_rounded;
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.storefront;
    }
  }
}