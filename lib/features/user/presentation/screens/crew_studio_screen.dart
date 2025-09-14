import 'package:flutter/material.dart';
import 'package:spotter/features/store/presentation/screens/store_profile_screen.dart';

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
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('크루 스튜디오', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: '대시보드'),
              Tab(text: '찜한 가게'),
            ],
            indicatorColor: Colors.orange,
            labelColor: Colors.orange,
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: TabBarView(
          children: [
            _buildDashboardTab(context),
            _buildBookmarkedStoresTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionTitle('핵심 지표'),
        const SizedBox(height: 12),
        _buildCoreMetricsGrid(context),
        const SizedBox(height: 24),
        _buildSectionTitle('명예의 전당'),
        const SizedBox(height: 12),
        _buildHallOfFameSection(context),
      ],
    );
  }

  Widget _buildBookmarkedStoresTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildBookmarkedStoreTile(context, '카페 스프링', '카페'),
        _buildBookmarkedStoreTile(context, '클린 세탁소', '서비스'),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildCoreMetricsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(context, '나의 레벨', 'LV.25', Icons.arrow_upward),
        _buildMetricCard(context, '경험치 (XP)', '1530', Icons.flash_on),
        _buildMetricCard(context, '나의 칭호', '동네 탐험가', Icons.verified),
        _buildMetricCard(context, '총 태깅 발생', '1,284', Icons.touch_app),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
      ),
    );
  }

  Widget _buildHallOfFameSection(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _hallOfFameTabController,
          tabs: const [
            Tab(text: '이달의 스탬프왕'),
            Tab(text: '인기 가게'),
          ],
          indicatorColor: Colors.orange,
          labelColor: Colors.orange,
          unselectedLabelColor: Colors.grey,
        ),
        SizedBox(
          height: 350,
          child: TabBarView(
            controller: _hallOfFameTabController,
            children: [
              _buildUserRankingList(context),
              _buildStoreRankingList(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserRankingList(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8),
      children: [
        _buildRankingTile(context, 1, '스포터', '스탬프 123개', true),
        _buildRankingTile(context, 2, '먹깨비', '스탬프 123개', true),
        _buildRankingTile(context, 3, '헬창', '스탬프 123개', true),
      ],
    );
  }

  Widget _buildStoreRankingList(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8),
      children: [
        _buildRankingTile(context, 1, '헬스 클럽', '여가', false),
        _buildRankingTile(context, 2, '편집샵 ABC', '쇼핑', false),
        _buildRankingTile(context, 3, '카페 스프링', '카페', false),
        _buildRankingTile(context, 4, '맛집 파스타', '음식점', false),
        _buildRankingTile(context, 5, '요가 스튜디오', '여가', false),
      ],
    );
  }

  Widget _buildRankingTile(BuildContext context, int rank, String title, String subtitle, bool isUser) {
    return ListTile(
      leading: Text('$rank', style: TextStyle(fontSize: 18, color: Colors.orange.shade700, fontWeight: FontWeight.bold)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }

  Widget _buildBookmarkedStoreTile(BuildContext context, String name, String category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Container(width: 50, height: 50, color: Colors.grey.shade300)),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(category, style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const StoreProfileScreen()),
          );
        },
      ),
    );
  }
}