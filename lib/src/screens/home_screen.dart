import 'package:flutter/material.dart';
import 'dart:async';
import 'package:spotter/src/screens/message_screen.dart';
import 'package:spotter/src/screens/store_detail_screen.dart';
import 'package:spotter/src/screens/tour_detail_screen.dart';
import 'package:spotter/src/widgets/feed_card.dart';

class HomeScreen extends StatefulWidget {
  final List<Map<String, dynamic>> feedItems;
  final Function(String) onDelete;
  final Map<String, dynamic> currentUser; // 추가된 부분

  const HomeScreen({
    Key? key,
    required this.feedItems,
    required this.onDelete,
    required this.currentUser, // 추가된 부분
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedSort = '거리순';
  final List<String> _sortOptions = ['거리순', '인기순', '신규오픈순', '혜택많은순'];
  int _selectedTagIndex = 0;
  final List<String> _tags = ['#전체', '#동성로', '#율하', '#수성못', '#앞산', '#세탁', '#파스타맛집'];

  @override
  Widget build(BuildContext context) {
    final displayedItems = _getDisplayedItems();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            elevation: 1,
            toolbarHeight: 60,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Spotter', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.message_outlined), onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const MessageScreen()));
                    }),
                    IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
          SliverPersistentHeader(
            delegate: _FilterHeaderDelegate(
              selectedSort: _selectedSort, sortOptions: _sortOptions,
              onSortChanged: (newValue) { setState(() { _selectedSort = newValue!; }); },
              tags: _tags, selectedTagIndex: _selectedTagIndex,
              onTagSelected: (index) { setState(() { _selectedTagIndex = index; }); },
            ),
            pinned: true,
          ),
          SliverToBoxAdapter(child: Container(height: 250, color: Colors.grey[800], child: const Center(child: Text('지도 API 연동 예정 구역', style: TextStyle(color: Colors.white, fontSize: 20))))),
          _buildSectionHeader("🔥 지금 뜨는 스팟 추천"),
          SliverToBoxAdapter(child: _buildTrendingSpotsList(context)),
          SliverToBoxAdapter(child: _BannerCarousel()),
          _buildSectionHeader("실시간 스팟 피드"),
          _buildRealtimeFeedList(displayedItems),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getDisplayedItems() {
    if (_selectedTagIndex == 0) {
      return widget.feedItems;
    } else {
      final selectedTag = _tags[_selectedTagIndex];
      return widget.feedItems.where((item) {
        final tags = item['tags'] as List<String>? ?? [];
        return tags.contains(selectedTag);
      }).toList();
    }
  }

  Widget _buildRealtimeFeedList(List<Map<String, dynamic>> items) {
    return SliverList.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return FeedCard(
          key: ValueKey(item['id']),
          item: item,
          onDelete: () => widget.onDelete(item['id'] as String),
          currentUser: widget.currentUser, // 수정된 부분
        );
      },
    );
  }

  Widget _buildTrendingSpotsList(BuildContext context) {
    final trendingSpots = [
      {
        'type': '리워드', 'title': '첫 방문 10% 할인',
        'storeData': {
          'storeName': '맛집 파스타', 'regulars': 125, 'seed': 'pasta',
          'category': '음식점', 'description': '매일 아침 직접 뽑는 생면으로 만드는 인생 파스타.', 'address': '대구시 중구 서문시장'
        }
      },
      {
        'type': '투어', 'title': '동네 카페 정복하기',
        'storeName': '카페 스프링 외 4곳', 'regulars': 88, 'seed': 'cafe_tour',
        'tourData': { 'title': '동네 카페 정복하기', 'description': '우리 동네 숨은 카페 5곳을 방문해보세요!', 'reward': '커피콩 원두 증정', 'stamps': [ {'completed': true, 'name': '카페 스프링', 'date': '2024-05-20', 'seed': 'cafe1'}, {'completed': false, 'name': '커피나무', 'date': null, 'seed': 'cafe2'}, ], }
      },
    ];
    return SizedBox(
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: trendingSpots.length,
        itemBuilder: (context, index) {
          final spot = trendingSpots[index];
          return _buildSpotCard(context, spot);
        },
      ),
    );
  }

  Widget _buildSpotCard(BuildContext context, Map<String, dynamic> spot) {
    final bool isTour = spot['type'] == '투어';
    final Color chipColor = isTour ? Colors.purple[400]! : Colors.orange[400]!;
    final storeData = spot['storeData'] as Map<String, dynamic>?;

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12.0),
      child: InkWell(
        onTap: () {
          if (isTour) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => TourDetailScreen(tourData: spot['tourData'])));
          } else if (storeData != null) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => StoreDetailScreen(storeData: storeData)));
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network('https://picsum.photos/seed/${spot['seed'] ?? storeData?['seed']}/200/200', height: 140, width: 160, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: chipColor, borderRadius: BorderRadius.circular(8)),
                    child: Text(spot['type'], style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
              child: Text(spot['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 8,
                    backgroundImage: NetworkImage('https://picsum.photos/seed/${spot['seed'] ?? storeData?['seed']}/50/50'),
                  ),
                  const SizedBox(width: 4),
                  Expanded(child: Text(spot['storeName'] ?? storeData?['storeName'] ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 2, 4, 0),
              child: Row(
                children: [
                  Icon(Icons.favorite, color: Colors.red[400], size: 14),
                  const SizedBox(width: 4),
                  Text('단골 ${spot['regulars'] ?? storeData?['regulars'] ?? 0}', style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSectionHeader(String title) { return SliverToBoxAdapter( child: Padding( padding: const EdgeInsets.fromLTRB(16, 24, 16, 8), child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), if (title.contains("스팟 추천")) const Text('전체보기', style: TextStyle(color: Colors.grey, fontSize: 14)), ], ), ), ); }
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String selectedSort;
  final List<String> sortOptions;
  final ValueChanged<String?> onSortChanged;
  final List<String> tags;
  final int selectedTagIndex;
  final ValueChanged<int> onTagSelected;
  _FilterHeaderDelegate({ required this.selectedSort, required this.sortOptions, required this.onSortChanged, required this.tags, required this.selectedTagIndex, required this.onTagSelected, });
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container( color: Theme.of(context).cardColor, height: 50.0, child: Row( children: [ Padding( padding: const EdgeInsets.only(left: 8.0), child: IconButton( icon: const Icon(Icons.search), onPressed: () {}, ), ), Expanded( child: ListView( scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(top: 8, bottom: 8, right: 16), children: [ Container( padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration( border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(20), ), child: DropdownButton<String>( value: selectedSort, items: sortOptions.map((String value) { return DropdownMenuItem<String>( value: value, child: Text(value, style: const TextStyle(fontSize: 14)), ); }).toList(), onChanged: onSortChanged, underline: Container(), icon: const Icon(Icons.keyboard_arrow_down, size: 20), ), ), const SizedBox(width: 8), ...List.generate(tags.length, (index) { return Padding( padding: const EdgeInsets.symmetric(horizontal: 4.0), child: ChoiceChip( padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0), label: Text(tags[index]), selected: selectedTagIndex == index, onSelected: (selected) { if (selected) { onTagSelected(index); } }, backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200], selectedColor: Colors.black, labelStyle: TextStyle( fontSize: 14, fontWeight: FontWeight.w500, color: selectedTagIndex == index ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color, ), shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade300), ), ), ); }), ], ), ), ], ), );
  }
  @override double get maxExtent => 50.0;
  @override double get minExtent => 50.0;
  @override bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) { return true; }
}

class _BannerCarousel extends StatefulWidget {
  @override
  State<_BannerCarousel> createState() => __BannerCarouselState();
}

class __BannerCarouselState extends State<_BannerCarousel> {
  int _current = 0;
  final PageController _pageController = PageController(viewportFraction: 0.9);
  Timer? _timer;
  final List<Map<String, String>> bannerItems = [
    {'title': '혹시 사장님이신가요?', 'subtitle': 'Spotter에서 가게를 등록하고, 더 많은 고객과 소통하며 특별한 혜택을 만들어보세요.', 'button': '가게 등록하고 혜택 받기'},
    {'title': '이번 주 핫 플레이스!', 'subtitle': '동성로 \'맛집 파스타\'에서 신메뉴 출시 기념 20% 할인 이벤트를 진행합니다.', 'button': '자세히 보기'},
  ];
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (!mounted) return;
      if (_current < bannerItems.length - 1) { _current++; } else { _current = 0; }
      if (_pageController.hasClients) {
        _pageController.animateToPage( _current, duration: const Duration(milliseconds: 400), curve: Curves.easeOut, );
      }
    });
  }
  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: PageView.builder(
              controller: _pageController,
              itemCount: bannerItems.length,
              itemBuilder: (context, index) {
                return Padding( padding: const EdgeInsets.symmetric(horizontal: 8.0), child: _buildBannerCard(bannerItems[index]), );
              },
              onPageChanged: (value) { setState(() { _current = value; }); },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: bannerItems.asMap().entries.map((entry) {
              return Container(
                width: 8.0, height: 8.0,
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(_current == entry.key ? 0.9 : 0.4),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  Widget _buildBannerCard(Map<String, String> item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      decoration: BoxDecoration( color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(16), ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(item['title']!, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(item['subtitle']!, style: TextStyle(color: Colors.grey[400], fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom( backgroundColor: Colors.orange[400], foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 12), ),
              child: Text(item['button']!),
            ),
          ),
        ],
      ),
    );
  }
}