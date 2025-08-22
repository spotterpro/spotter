// 📁 lib/src/screens/stamp_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spotter/src/screens/coupon_redemption_screen.dart';
import 'package:spotter/src/screens/find_stamps_screen.dart';
import 'package:spotter/src/screens/ongoing_stamps_screen.dart'; // 🔥🔥🔥 상세 페이지 임포트
import 'package:spotter/src/screens/ongoing_tours_screen.dart';

class StampScreen extends StatefulWidget {
  const StampScreen({super.key});

  @override
  State<StampScreen> createState() => _StampScreenState();
}

class _StampScreenState extends State<StampScreen> with TickerProviderStateMixin {
  late final TabController _journeyTabController;
  late final TabController _couponTabController;
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _journeyTabController = TabController(length: 2, vsync: this);
    _couponTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _journeyTabController.dispose();
    _couponTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('스탬프', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FindStampsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStampJourneyCard(context),
            _buildMyCouponsSection(context),
            _buildMyStampCollectionSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStampJourneyCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: Colors.orange[400],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              "스포터님의 스탬프 여정",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          TabBar(
            controller: _journeyTabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(width: 3, color: Colors.white),
              insets: EdgeInsets.symmetric(horizontal: 16.0),
            ),
            tabs: const [
              Tab(text: '진행중인 스탬프'),
              Tab(text: '진행중인 투어'),
            ],
          ),
          SizedBox(
            height: 100,
            child: TabBarView(
              controller: _journeyTabController,
              children: [
                StreamBuilder<QuerySnapshot>(
                  // --- 🔥🔥🔥 수정된 부분: '횟수형' 리워드만 필터링합니다. ---
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(_currentUserId)
                        .collection('ongoing_rewards')
                        .where('rewardData.conditionType', isEqualTo: 'visitCount')
                        .snapshots(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.size ?? 0;
                      return _buildJourneyStat(
                          context,
                          count.toString(),
                          '진행중인 스탬프',
                          // --- 🔥🔥🔥 수정된 부분: 상세 페이지로 이동시킵니다. ---
                              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OngoingStampsScreen()))
                      );
                    }
                ),
                _buildJourneyStat(context, '0', '진행중인 투어', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OngoingToursScreen()))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyStat(BuildContext context, String count, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(count, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildMyCouponsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text("🎟️ 내 쿠폰함", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            child: AppBar(
              elevation: 0,
              toolbarHeight: 48,
              backgroundColor: Theme.of(context).cardColor,
              flexibleSpace: TabBar(
                controller: _couponTabController,
                labelColor: Colors.orange[600],
                unselectedLabelColor: Colors.grey[600],
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 3, color: Colors.orange[600]!),
                ),
                tabs: const [
                  Tab(text: '사용 가능'),
                  Tab(text: '사용 완료'),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 220,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(_currentUserId)
                  .collection('coupons')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('쿠폰을 불러오는 중 오류가 발생했습니다: ${snapshot.error}'));
                }

                final docs = snapshot.data?.docs ?? [];
                final available = docs.where((d) {
                  final m = d.data() as Map<String, dynamic>;
                  return m['usedAt'] == null;
                }).toList();

                final used = docs.where((d) {
                  final m = d.data() as Map<String, dynamic>;
                  return m['usedAt'] != null;
                }).toList();

                return TabBarView(
                  controller: _couponTabController,
                  children: [
                    _buildCouponListFromDocs(available, isAvailable: true),
                    _buildCouponListFromDocs(used, isAvailable: false),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponListFromDocs(List<QueryDocumentSnapshot> coupons, {required bool isAvailable}) {
    if (coupons.isEmpty) {
      return Center(child: Text(isAvailable ? '사용 가능한 쿠폰이 없습니다.' : '사용한 쿠폰이 없습니다.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: coupons.length,
      itemBuilder: (context, index) {
        final doc = coupons[index];
        final data = doc.data() as Map<String, dynamic>;
        final rewardData = data['rewardData'] as Map<String, dynamic>? ?? {};
        final expiryDate = (data['createdAt'] as Timestamp?)
            ?.toDate()
            .add(Duration(days: rewardData['expiryDays'] ?? 30));

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    rewardData['imageUrl'] ?? 'https://picsum.photos/seed/${data['storeId']}/100/100',
                    width: 60, height: 60, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: Colors.grey[200]),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rewardData['title'] ?? '리워드', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(rewardData['storeName'] ?? '가게', style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 4),
                      if (isAvailable && expiryDate != null)
                        Text('유효기간: ~${expiryDate.toLocal().toString().substring(0, 10)}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                if (isAvailable)
                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CouponRedemptionScreen(
                            couponId: doc.id,
                            storeId: data['storeId'],
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[400],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('사용하기'),
                  )
                else
                  Text("사용완료", style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMyStampCollectionSection(BuildContext context) {
    return const SizedBox.shrink();
  }
}