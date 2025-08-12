// 📁 lib/src/screens/admin/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotter/src/screens/admin/admin_application_detail_screen.dart';

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
          // 👑 --- 형님의 요청대로 새로고침 버튼 추가 --- 👑
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '새로고침',
            onPressed: () {
              // setState를 호출하여 위젯을 다시 그리게 함으로써
              // StreamBuilder가 스트림을 새로 구독하도록 강제합니다.
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
            Tab(text: '심사 대기 중'),
            Tab(text: '승인 완료'),
            Tab(text: '반려된 요청'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildApplicationList(status: 'pending'),
          _buildApplicationList(status: 'approved'),
          _buildApplicationList(status: 'rejected'),
        ],
      ),
    );
  }

  Widget _buildApplicationList({required String status}) {
    String emptyMessage = '해당 상태의 요청이 없습니다.';
    if (status == 'pending') emptyMessage = '대기 중인 심사 요청이 없습니다.';
    if (status == 'approved') emptyMessage = '승인 완료된 요청이 없습니다.';
    if (status == 'rejected') emptyMessage = '반려된 요청이 없습니다.';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('store_applications')
          .where('status', isEqualTo: status)
          .orderBy('submittedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(emptyMessage, style: const TextStyle(fontSize: 18, color: Colors.grey)),
          );
        }

        final applications = snapshot.data!.docs;

        return ListView.builder(
          itemCount: applications.length,
          itemBuilder: (context, index) {
            final doc = applications[index];
            final data = doc.data() as Map<String, dynamic>;
            final submittedAt = (data['submittedAt'] as Timestamp?)?.toDate();

            return ListTile(
              leading: Icon(_getIconForStatus(status)),
              title: Text(data['storeName'] ?? '이름 없음'),
              subtitle: Text('신청일: ${submittedAt?.toLocal().toString().substring(0, 16) ?? '알 수 없음'}'),
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