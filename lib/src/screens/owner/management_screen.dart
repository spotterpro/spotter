// 📁 lib/src/screens/owner/management_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManagementScreen extends StatefulWidget {
  final String storeId;
  const ManagementScreen({super.key, required this.storeId});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- 🔥🔥🔥 수정된 부분: Scaffold와 AppBar를 제거하고 내용물만 남깁니다. ---
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('stores').doc(widget.storeId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('가게 정보를 불러올 수 없습니다.'));
        }
        final storeData = snapshot.data!.data()!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildStoreInfoCard(context, storeData),
              const SizedBox(height: 24),
              TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: Colors.black,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: '가게 소식 관리'),
                  Tab(text: '고객 인증샷 모아보기'),
                ],
              ),
              SizedBox(
                height: 400,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildNewsManagementTab(context),
                    _buildCustomerPhotosTab(context),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStoreInfoCard(BuildContext context, Map<String, dynamic> storeData) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    storeData['imageUrl'] ?? 'https://picsum.photos/seed/placeholder/200/200',
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_,__,___) => Container(width: 70, height: 70, color: Colors.grey[200]),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(storeData['category'] ?? '카테고리 미지정', style: TextStyle(color: Colors.grey[600])),
                      Text(storeData['storeName'] ?? '가게 이름 없음', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text(storeData['address'] ?? '주소 정보 없음', style: TextStyle(color: Colors.grey[700])),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () { /* TODO: 가게 정보 수정 화면으로 이동 */ },
                  icon: Icon(Icons.settings_outlined, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatBox(
                    context,
                    label: '우리 가게 단골',
                    stream: FirebaseFirestore.instance.collection('stores').doc(widget.storeId).collection('regulars').snapshots(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatBox(
                    context,
                    label: '고객 인증샷',
                    stream: null, // TODO: 인증샷 개수 쿼리 필요
                    initialValue: '0', // 임시 값
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Text(storeData['story'] ?? '설명이 없습니다. 가게의 매력을 어필해보세요.'),
            const SizedBox(height: 8),
            Text('운영시간: ${storeData['hours'] ?? '정보 없음'}', style: TextStyle(color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(BuildContext context, {required String label, Stream<QuerySnapshot>? stream, String? initialValue}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: Colors.grey[800])),
          const SizedBox(height: 8),
          if (stream != null)
            StreamBuilder<QuerySnapshot>(
                stream: stream,
                builder: (context, snapshot) {
                  final count = snapshot.data?.size ?? 0;
                  return Text(count.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold));
                }
            )
          else
            Text(initialValue ?? '0', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildNewsManagementTab(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () { /* TODO: 새 가게 소식 작성 화면으로 이동 */ },
          icon: const Icon(Icons.add),
          label: const Text('새로운 가게 소식 작성하기'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        const Expanded(
          child: Center(child: Text('가게 소식 목록이 여기에 표시됩니다.')),
        ),
      ],
    );
  }

  Widget _buildCustomerPhotosTab(BuildContext context) {
    return const Center(child: Text('고객 인증샷 목록이 여기에 표시됩니다.'));
  }
}