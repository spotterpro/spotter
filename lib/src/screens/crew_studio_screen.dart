// 📁 lib/src/screens/crew_studio_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spotter/models/user_model.dart';
import 'package:spotter/src/screens/store_detail_screen.dart';

class CrewStudioScreen extends StatefulWidget {
  final UserProfile userProfile;

  const CrewStudioScreen({
    super.key,
    required this.userProfile,
  });

  @override
  State<CrewStudioScreen> createState() => _CrewStudioScreenState();
}

class _CrewStudioScreenState extends State<CrewStudioScreen> with TickerProviderStateMixin {
  late final TabController _tabController;
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

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
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(_currentUserId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          final userProfile = UserProfile.fromDocument(snapshot.data!);

          return Scaffold(
            appBar: AppBar(
              title: const Text('크루 스튜디오'),
              bottom: TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).textTheme.bodyLarge?.color,
                unselectedLabelColor: Colors.grey,
                tabs: const <Widget>[
                  Tab(text: '대시보드'),
                  Tab(text: '찜한 가게'),
                  Tab(text: '스폰서쉽'),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: <Widget>[
                _buildDashboardTab(context, userProfile),
                _buildRegularStoresTab(),
                _buildSponsorshipTab(),
              ],
            ),
          );
        }
    );
  }

  Widget _buildDashboardTab(BuildContext context, UserProfile userProfile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('핵심 지표', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _InfoCard(icon: Icons.arrow_upward, title: '나의 레벨', value: userProfile.levelTitle, color: Colors.green),
              _InfoCard(icon: Icons.flash_on, title: '경험치(XP)', value: '${userProfile.xp}', color: Colors.orange),
              _InfoCard(icon: Icons.business_center_outlined, title: '진행중인 스폰서쉽', value: '0', color: Colors.blue),
              _InfoCard(icon: Icons.check_circle_outline, title: '총 태깅 발생', value: '0', color: Colors.purple),
            ],
          ),
          const SizedBox(height: 24),
          const Text('명예의 전당', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          _buildRankingSection(context),
        ],
      ),
    );
  }

  Widget _buildRegularStoresTab() {
    final regularStores = [
      { 'name': '카페 스프링', 'category': '카페', 'seed': 'cafe', 'storeData': { 'id': 'temp_cafe_id_01', 'storeName': '카페 스프링', 'regulars': 98, 'seed': 'cafe', 'category': '카페', 'description': '신선한 원두와 함께하는 여유', 'address': '대구시 수성구' } },
      { 'name': '클린 세탁소', 'category': '서비스', 'seed': 'laundry', 'storeData': { 'id': 'temp_laundry_id_01', 'storeName': '클린 세탁소', 'regulars': 75, 'seed': 'laundry', 'category': '서비스', 'description': '깨끗함의 차이를 느껴보세요.', 'address': '대구시 동구' } }
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: regularStores.length,
      itemBuilder: (context, index) {
        final store = regularStores[index];
        final storeData = store['storeData'] as Map<String, dynamic>;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 1,
          shadowColor: Colors.black12,
          child: InkWell(
            onTap: () {
              // --- 🔥🔥🔥 수정된 부분 ---
              final storeId = storeData['id'] as String?;
              if (storeId != null) {
                Navigator.push( context, MaterialPageRoute( builder: (context) => StoreDetailScreen( storeId: storeId ), ), );
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network( 'https://picsum.photos/seed/${store['seed']}/100/100', width: 60, height: 60, fit: BoxFit.cover, ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(store['name'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(store['category'] as String, style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSponsorshipTab() {
    return const Center(child: Text("스폰서쉽 제안 목록이 여기에 표시됩니다."));
  }

  Widget _buildRankingSection(BuildContext context) {
    final on = Theme.of(context).textTheme.bodyLarge?.color;
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            isScrollable: false, indicatorSize: TabBarIndicatorSize.tab, labelColor: on, unselectedLabelColor: Colors.grey,
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            tabs: const [
              Tab(child: FittedBox(fit: BoxFit.scaleDown, child: Text('이달의 스탬프왕'))),
              Tab(child: FittedBox(fit: BoxFit.scaleDown, child: Text('인기 상승 크루'))),
              Tab(child: FittedBox(fit: BoxFit.scaleDown, child: Text('이달의 가게'))),
            ],
          ),
          SizedBox(
            height: 250,
            child: TabBarView(
              children: [
                _buildRankingList(context, '스탬프왕'),
                _buildRankingList(context, '크루'),
                _buildStoreRankingList(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingList(BuildContext context, String type) {
    final rankings = type == '스탬프왕'
        ? [ { 'name': '스포터', 'metric': '스탬프 123개', 'seed': 'user1' }, { 'name': '먹깨비', 'metric': '스탬프 115개', 'seed': 'user2' }, { 'name': '헬창', 'metric': '스탬프 98개', 'seed': 'user3' }, ]
        : [ { 'name': '동성로 탐험대', 'metric': '크루원 25명', 'seed': 'crew1' }, { 'name': '앞산 등산모임', 'metric': '크루원 18명', 'seed': 'crew2' }, { 'name': '수성못 야경단', 'metric': '크루원 12명', 'seed': 'crew3' }, ];
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: rankings.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return ListTile(
          leading: Text('${index + 1}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
          title: Text(rankings[index]['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(rankings[index]['metric'] as String),
          trailing: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network('https://picsum.photos/seed/${rankings[index]['seed']}/100/100', width: 40, height: 40, fit: BoxFit.cover),
          ),
        );
      },
    );
  }

  Widget _buildStoreRankingList(BuildContext context) {
    final rankings = [
      { 'name': '맛집 파스타', 'metric': '단골 127명', 'seed': 'pasta', 'storeData': {'id': '6PdcdJAiNqVpZ9DDvtY0itRGYBP2', 'storeName': '맛집 파스타', 'regulars': 127, 'seed': 'pasta'}},
      { 'name': '카페 스프링', 'metric': '단골 98명', 'seed': 'cafe', 'storeData': {'id': 'temp_cafe_id_02', 'storeName': '카페 스프링', 'regulars': 98, 'seed': 'cafe'}},
      { 'name': '클린 세탁소', 'metric': '단골 75명', 'seed': 'laundry', 'storeData': {'id': 'temp_laundry_id_02', 'storeName': '클린 세탁소', 'regulars': 75, 'seed': 'laundry'}},
    ];
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: rankings.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final storeData = rankings[index]['storeData'] as Map<String, dynamic>;
        return ListTile(
          // --- 🔥🔥🔥 수정된 부분 ---
          onTap: () {
            final storeId = storeData['id'] as String?;
            if (storeId != null) {
              Navigator.push( context, MaterialPageRoute( builder: (context) => StoreDetailScreen( storeId: storeId ), ), );
            }
          },
          leading: Text('${index + 1}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
          title: Text(rankings[index]['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(rankings[index]['metric'] as String),
          trailing: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network('https://picsum.photos/seed/${rankings[index]['seed']}/100/100', width: 40, height: 40, fit: BoxFit.cover),
          ),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _InfoCard({required this.icon, required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              foregroundColor: color,
              child: Icon(icon),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), maxLines: 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}