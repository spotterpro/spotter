import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spotter/src/screens/find_stamps_screen.dart';
import 'package:spotter/src/screens/ongoing_stamps_screen.dart';
import 'package:spotter/src/screens/ongoing_tours_screen.dart';

class StampScreen extends StatefulWidget {
  const StampScreen({super.key});

  @override
  State<StampScreen> createState() => _StampScreenState();
}

class _StampScreenState extends State<StampScreen> with TickerProviderStateMixin {
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
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: Colors.orange[400],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "스포터님의 스탬프 여정",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildJourneyStat(context, '2', '진행중인 스탬프', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const OngoingStampsScreen()));
              }),
              _buildJourneyStat(context, '2', '진행중인 투어', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const OngoingToursScreen()));
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyStat(BuildContext context, String count, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
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
                controller: _tabController,
                labelColor: Colors.orange[600],
                unselectedLabelColor: Colors.grey[600],
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 3, color: Colors.orange[600]!),
                ),
                tabs: const [
                  Tab(text: '사용 가능 (2)'),
                  Tab(text: '사용 완료 (1)'),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCouponList(true),
                _buildCouponList(false),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCouponList(bool isAvailable) {
    final availableCoupons = [
      {'store': '카페 스프링', 'reward': '아메리카노 1잔 무료', 'expiry': '2025-12-31', 'seed': 'cafe'},
      {'store': '맛집 파스타', 'reward': '고르곤졸라 피자', 'expiry': '2025-11-30', 'seed': 'pasta'},
    ];
    final usedCoupons = [
      {'store': '헬스 클럽', 'reward': '프로틴 쉐이크 증정', 'expiry': '2025-07-15', 'seed': 'gym'},
    ];
    final coupons = isAvailable ? availableCoupons : usedCoupons;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: coupons.length,
      itemBuilder: (context, index) {
        final coupon = coupons[index];
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
                  child: Image.network('https://picsum.photos/seed/${coupon['seed']}/100/100', width: 60, height: 60, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(coupon['reward']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(coupon['store']!, style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 4),
                      Text('유효기간: ~${coupon['expiry']}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                if (isAvailable)
                  ElevatedButton(
                    onPressed: () {},
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
    final collections = [
      {'name': '카페 스프링', 'date': '2024-05-20', 'seed': 'cafe1'},
      {'name': '헬스 클럽', 'date': '2024-05-19', 'seed': 'gym'},
      {'name': '맛집 파스타', 'date': '2024-05-18', 'seed': 'pasta'},
      {'name': '요가 스튜디오', 'date': '2024-05-17', 'seed': 'yoga'},
      {'name': '헬스 클럽', 'date': '2024-05-15', 'seed': 'gym2'},
    ];
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("📚 나의 스탬프 컬렉션 (5)", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: collections.length + 1,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              if (index == collections.length) {
                return _buildAddStampCard();
              }
              final item = collections[index];
              return _buildStampCollectionCard(item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStampCollectionCard(Map<String, String> item) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: NetworkImage('https://picsum.photos/seed/${item['seed']}/150/150'),
        ),
        const SizedBox(height: 8),
        Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center),
        const SizedBox(height: 2),
        Text(item['date']!, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _buildAddStampCard() {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey[200],
          child: Icon(Icons.add, size: 30, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Text('스탬프 추가', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
      ],
    );
  }
}