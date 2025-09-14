import 'package:flutter/material.dart';

class CrewStudioScreen extends StatefulWidget {
  const CrewStudioScreen({super.key});

  @override
  State<CrewStudioScreen> createState() => _CrewStudioScreenState();
}

class _CrewStudioScreenState extends State<CrewStudioScreen> with TickerProviderStateMixin {
  late TabController _hallOfFameTabController;

  @override
  void initState() {
    super.initState();
    _hallOfFameTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _hallOfFameTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('크루 스튜디오', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: '대시보드'),
              Tab(text: '찜한 가게'),
            ],
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
          ),
        ),
        body: TabBarView(
          children: [
            _buildDashboardTab(),
            _buildBookmarkedStoresTab(),
          ],
        ),
      ),
    );
  }

  // '대시보드' 탭 UI
  Widget _buildDashboardTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionTitle('핵심 지표'),
        const SizedBox(height: 12),
        _buildCoreMetricsGrid(),
        const SizedBox(height: 24),
        _buildSectionTitle('명예의 전당'),
        const SizedBox(height: 12),
        _buildHallOfFameSection(),
      ],
    );
  }

  // '찜한 가게' 탭 UI
  Widget _buildBookmarkedStoresTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildBookmarkedStoreTile('카페 스프링', '카페'),
        _buildBookmarkedStoreTile('클린 세탁소', '서비스'),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  // 핵심 지표 그리드
  Widget _buildCoreMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard('나의 레벨', 'LV.25', Icons.arrow_upward),
        _buildMetricCard('경험치 (XP)', '1530', Icons.flash_on),
        _buildMetricCard('나의 칭호', '동네 탐험가', Icons.verified),
        _buildMetricCard('총 태깅 발생', '1,284', Icons.touch_app),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey, size: 18),
              const SizedBox(width: 4),
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // 명예의 전당 섹션 (중첩된 TabBar 포함)
  Widget _buildHallOfFameSection() {
    return Column(
      children: [
        TabBar(
          controller: _hallOfFameTabController,
          tabs: const [
            Tab(text: '이달의 스탬프왕'),
            Tab(text: '인기 가게'),
          ],
          labelColor: Colors.orange,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.orange,
        ),
        SizedBox(
          height: 350, // 랭킹 목록의 높이를 고정
          child: TabBarView(
            controller: _hallOfFameTabController,
            children: [
              _buildUserRankingList(),
              _buildStoreRankingList(),
            ],
          ),
        ),
      ],
    );
  }

  // 유저 랭킹 목록
  Widget _buildUserRankingList() {
    return ListView(
      children: [
        _buildRankingTile(1, '스포터', '스탬프 123개'),
        _buildRankingTile(2, '먹깨비', '스탬프 123개'),
        _buildRankingTile(3, '헬창', '스탬프 123개'),
      ],
    );
  }

  // 가게 랭킹 목록
  Widget _buildStoreRankingList() {
    return ListView(
      children: [
        _buildRankingTile(1, '헬스 클럽', '여가'),
        _buildRankingTile(2, '편집샵 ABC', '쇼핑'),
        _buildRankingTile(3, '카페 스프링', '카페'),
        _buildRankingTile(4, '맛집 파스타', '음식점'),
        _buildRankingTile(5, '요가 스튜디오', '여가'),
      ],
    );
  }

  Widget _buildRankingTile(int rank, String title, String subtitle) {
    return ListTile(
      leading: Text('$rank', style: TextStyle(fontSize: 18, color: Colors.orange.shade700, fontWeight: FontWeight.bold)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }

  // 찜한 가게 목록 타일
  Widget _buildBookmarkedStoreTile(String name, String category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Container(width: 50, height: 50, color: Colors.grey.shade300)),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(category, style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () { /* TODO: 가게 상세 페이지로 이동 */ },
      ),
    );
  }
}