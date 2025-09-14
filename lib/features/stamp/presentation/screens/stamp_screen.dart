import 'package:flutter/material.dart';
import 'package:spotter/features/stamp/presentation/screens/reward_detail_screen.dart';
import 'package:spotter/features/stamp/presentation/screens/tour_detail_screen.dart';
import 'package:spotter/features/store/presentation/screens/store_profile_screen.dart';

class StampScreen extends StatefulWidget {
  const StampScreen({super.key});

  @override
  State<StampScreen> createState() => _StampScreenState();
}

class _StampScreenState extends State<StampScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _couponTabIndex = 0;

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('스탬프'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          )
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverPersistentHeader(
              delegate: _StickyTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: '모으는 리워드 (2)'),
                    Tab(text: '진행중인 투어 (4)'),
                  ],
                  indicatorColor: isDarkMode ? Colors.white : Colors.black,
                  labelColor: isDarkMode ? Colors.white : Colors.black,
                  unselectedLabelColor: Colors.grey,
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildCollectingRewardsTab(),
            _buildOngoingToursTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectingRewardsTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildRewardProgressCard("알리오 올리오 1+1", "맛집 파스타", 2, 3),
        _buildRewardProgressCard("모든 음료 20% 할인", "카페 스프링", 4, 5),
        const SizedBox(height: 24),
        _buildCouponSection(),
        const SizedBox(height: 24),
        _buildStampCollectionSection(),
      ],
    );
  }

  Widget _buildOngoingToursTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const TourDetailScreen())),
            child: _buildTourProgressCard("동성로 핫플 정복", "동성로의 가장 핫한 가게들을 방문해보세요.", "기념 뱃지 세트", 2, 4)),
        GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const TourDetailScreen())),
            child: _buildTourProgressCard("맛집 파스타의 맛 기행", "파스타부터 디저트까지, 저희 가게의 모든 것을 즐겨보세요.", "피자 1판 무료", 1, 3)),
        GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const TourDetailScreen())),
            child: _buildTourProgressCard("동네체-강 투어", "파스타로 든든하게! 헬스장에서 활기차게!", "두 가게 10% 할인 쿠폰", 0, 2)),
      ],
    );
  }

  Widget _buildRewardProgressCard(String title, String store, int current, int total) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RewardDetailScreen()));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const StoreProfileScreen()));
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(width: 60, height: 60, color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(store, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: current / total,
                            backgroundColor: isDarkMode ? Colors.grey.shade700 : Colors.grey[200],
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text("스탬프 현황  $current / $total", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTourProgressCard(String title, String desc, String reward, int current, int total) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(8)),
                  child: Text("보상: $reward", style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold, fontSize: 12)),
                )
              ],
            ),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 16),
            Row(
              children: List.generate(total, (index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: index < current ? Colors.blue.shade100 : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
                    child: index < current ? const Icon(Icons.check, color: Colors.blue) : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: LinearProgressIndicator(value: current / total, backgroundColor: isDarkMode ? Colors.grey.shade700 : Colors.grey[200], color: Colors.orange)),
                const SizedBox(width: 8),
                Text("진행도  $current / $total", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // [수정] 쿠폰 목록을 _couponTabIndex 상태에 따라 다르게 보여주도록 수정
  Widget _buildCouponSection() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("🎟️ 내 쿠폰함", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () => setState(() => _couponTabIndex = 0),
                        style: FilledButton.styleFrom(
                          backgroundColor: _couponTabIndex == 0 ? (isDarkMode ? Colors.white : Colors.black87) : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
                          foregroundColor: _couponTabIndex == 0 ? (isDarkMode ? Colors.black : Colors.white) : (isDarkMode ? Colors.white70 : Colors.black87),
                        ),
                        child: const Text("사용 가능 (1)"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => setState(() => _couponTabIndex = 1),
                        style: FilledButton.styleFrom(
                          backgroundColor: _couponTabIndex == 1 ? (isDarkMode ? Colors.white : Colors.black87) : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
                          foregroundColor: _couponTabIndex == 1 ? (isDarkMode ? Colors.black : Colors.white) : (isDarkMode ? Colors.white70 : Colors.black87),
                        ),
                        child: const Text("사용 완료 (1)"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // _couponTabIndex 값에 따라 다른 쿠폰 카드를 보여줍니다.
                if (_couponTabIndex == 0)
                  _buildCouponCard("첫 방문 10% 할인", "맛집 파스타", "~2024-06-30", isUsed: false)
                else
                  _buildCouponCard("PT 1회 체험권", "헬스 클럽", "사용일: 2024-05-15", isUsed: true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // [수정] 쿠폰 카드가 isUsed 상태를 받아서 UI를 다르게 그리도록 수정
  Widget _buildCouponCard(String title, String store, String dateInfo, {required bool isUsed}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Opacity(
      opacity: isUsed ? 0.5 : 1.0, // 사용된 쿠폰은 반투명 처리
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(width: 60, height: 60, color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(store, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(dateInfo, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          if (isUsed)
            FilledButton(
              onPressed: null, // 비활성화
              style: FilledButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                foregroundColor: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade500,
              ),
              child: const Text("사용 완료"),
            )
          else
            Column(
              children: [
                FilledButton(onPressed: () {}, child: const Text("사용하기"), style: FilledButton.styleFrom(backgroundColor: Colors.orange)),
                const SizedBox(height: 4),
                FilledButton(onPressed: () {}, child: const Text("선물하기"), style: FilledButton.styleFrom(backgroundColor: isDarkMode ? const Color(0xFF5865F2) : Colors.indigo.shade400)),
              ],
            )
        ],
      ),
    );
  }

  Widget _buildStampCollectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("✨ 나의 스탬프 컬렉션 (5)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildStampCollectionItem("카페 스프링"),
                  _buildStampCollectionItem("맛집 파스타"),
                  _buildStampCollectionItem("클린 세탁소"),
                  _buildStampCollectionItem("편집샵 ABC"),
                  _buildStampCollectionItem("헬스 클럽"),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStampCollectionItem(String name) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          CircleAvatar(radius: 30, backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}