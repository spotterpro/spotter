// 📁 lib/src/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/src/screens/message_screen.dart';
import 'package:spotter/src/screens/store_detail_screen.dart';
import 'package:spotter/src/screens/tour_detail_screen.dart';
import 'package:spotter/src/widgets/feed_card.dart';

class HomeScreen extends StatefulWidget {
  final List<Map<String, dynamic>> feedItems;
  final Function(String) onDelete;
  final Map<String, dynamic> currentUser;

  const HomeScreen({
    Key? key,
    required this.feedItems,
    required this.onDelete,
    required this.currentUser,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedSort = '거리순';
  final List<String> _sortOptions = ['거리순', '인기순', '신규오픈순', '혜택많은순'];
  int _selectedTagIndex = 0;
  final List<String> _tags = ['#전체', '#동성로', '#율하', '#수성못', '#앞산', '#세탁', '#파스타맛집'];

  KakaoMapController? mapController;
  Set<Marker> markers = {};
  StreamSubscription<QuerySnapshot>? _storeSubscription;

  @override
  void initState() {
    super.initState();
  }

  void _startStoreSubscription() {
    _storeSubscription?.cancel();
    _storeSubscription = FirebaseFirestore.instance
        .collection('stores')
        .where('status', isEqualTo: 'approved')
        .where('hasRewards', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      final newMarkers = <Marker>{};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final GeoPoint location = data['location'];

        newMarkers.add(Marker(
          markerId: doc.id,
          latLng: LatLng(location.latitude, location.longitude),
        ));
      }
      if (mounted) {
        setState(() {
          markers = newMarkers;
        });
      }
    }, onError: (error) {
      print("가게 정보 실시간 감시 실패: $error");
    });
  }

  Future<void> _onMarkerTapped(String markerId) async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => StoreDetailScreen(storeId: markerId)),
      );
    } catch (e) {
      print('가게 상세 정보 로딩 실패: $e');
    }
  }

  @override
  void dispose() {
    _storeSubscription?.cancel();
    super.dispose();
  }

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
          SliverToBoxAdapter(
            child: SizedBox(
              height: 250,
              child: KakaoMap(
                onMapCreated: ((controller) {
                  mapController = controller;
                  _startStoreSubscription();
                }),
                markers: markers.toList(),
                center: LatLng(35.8714, 128.6014),
                onMarkerTap: (markerId, latLng, zoomLevel) => _onMarkerTapped(markerId),
              ),
            ),
          ),
          _buildSectionHeader("🔥 지금 뜨는 스팟 추천"),
          SliverToBoxAdapter(child: _buildTrendingSpotsList(context)),
          SliverToBoxAdapter(child: _BannerCarousel()),
          _buildSectionHeader("실시간 스팟 피드"),
          _buildRealtimeFeedList(displayedItems),
        ],
      ),
    );
  }

  Widget _buildTrendingSpotsList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collectionGroup('rewards')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 230, child: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox(height: 230, child: Center(child: Text('현재 추천 스팟이 없습니다.')));
        }
        final trendingSpots = snapshot.data!.docs;

        return SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: trendingSpots.length,
            itemBuilder: (context, index) {
              final spotDoc = trendingSpots[index];
              final spot = spotDoc.data() as Map<String, dynamic>;

              // --- 🔥🔥🔥 수정된 부분: 표시할 이미지 URL을 결정합니다. ---
              // 1순위: 리워드 자체 이미지, 2순위: 가게 대표 이미지
              final String? displayImageUrl = spot['imageUrl'] ?? spot['storeImageUrl'];

              final spotForCard = {
                'type': '리워드',
                'title': spot['title'] ?? '리워드',
                'storeName': spot['storeName'] ?? '가게',
                'imageUrl': displayImageUrl, // 사용할 이미지 URL 전달
                'storeId': spot['storeId'],
              };
              return _buildSpotCard(context, spotForCard);
            },
          ),
        );
      },
    );
  }

  Widget _buildSpotCard(BuildContext context, Map<String, dynamic> spot) {
    final storeId = spot['storeId'] as String?;
    final imageUrl = spot['imageUrl'] as String?;

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12.0),
      child: InkWell(
        onTap: () {
          if (storeId != null && storeId.isNotEmpty) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => StoreDetailScreen(storeId: storeId)));
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
                  // --- 🔥🔥🔥 수정된 부분: imageUrl이 있으면 그것을, 없으면 임시 이미지를 보여줍니다. ---
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                    imageUrl,
                    height: 140,
                    width: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                        height: 140,
                        width: 160,
                        color: Colors.grey[200],
                        child: const Icon(Icons.error_outline, color: Colors.grey)
                    ),
                  )
                      : Container(
                      height: 140,
                      width: 160,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey)
                  ),
                ),
                Positioned(
                  top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.orange[400], borderRadius: BorderRadius.circular(8)),
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
                  Expanded(child: Text(spot['storeName'] ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 2, 4, 0),
              child: Row(
                children: [
                  Icon(Icons.favorite, color: Colors.red[400], size: 14),
                  const SizedBox(width: 4),
                  if (storeId != null && storeId.isNotEmpty)
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('stores').doc(storeId).collection('regulars').snapshots(),
                        builder: (context, snapshot) {
                          final count = snapshot.data?.size ?? 0;
                          return Text('단골 $count', style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500));
                        }
                    )
                  else
                    Text('단골 0', style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
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
          currentUser: widget.currentUser,
        );
      },
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