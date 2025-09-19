// admin_dashboard_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// 형님께서 보내주신 상세 화면 파일을 import 합니다.
import 'application_detail_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('가게 심사 대시보드'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.pending_actions), text: '심사 대기'),
              Tab(icon: Icon(Icons.check_circle_outline), text: '승인 완료'),
              Tab(icon: Icon(Icons.cancel_outlined), text: '반려'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ApplicationList(status: 'pending'),
            ApplicationList(status: 'approved'),
            ApplicationList(status: 'rejected'),
          ],
        ),
      ),
    );
  }
}

class ApplicationList extends StatelessWidget {
  final String status;
  const ApplicationList({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    // 'status' 필드를 기준으로 Firestore에서 데이터를 실시간으로 가져옵니다.
    final query = FirebaseFirestore.instance
        .collection('store_applications')
        .where('status', isEqualTo: status)
        .orderBy('submittedAt', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // 보안 규칙 오류 등 에러 발생 시
          return Center(child: Text('오류가 발생했습니다: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text('해당 상태의 신청 건이 없습니다.', style: TextStyle(color: Colors.grey[600])));
        }

        // 데이터를 리스트뷰로 표시
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final storeName = data['storeName'] ?? '이름 없음';
            final address = data['address'] ?? '주소 없음';
            final submittedAt = (data['submittedAt'] as Timestamp?)?.toDate().toString().substring(0, 16) ?? '날짜 없음';

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(data['imageUrl'] ?? ''),
                onBackgroundImageError: (_, __) {}, // 이미지 로드 에러 시 기본 아이콘 표시
                child: data['imageUrl'] == null ? const Icon(Icons.store) : null,
              ),
              title: Text(storeName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('$address\n신청일: $submittedAt'),
              isThreeLine: true,
              onTap: () {
                // ListTile을 누르면 상세 페이지로 이동
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ApplicationDetailScreen(applicationId: doc.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}