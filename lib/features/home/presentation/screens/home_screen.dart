import 'package:flutter/material.dart';
import 'dart:async';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spotter/features/message/presentation/screens/message_screen.dart';
import 'package:spotter/features/store/presentation/screens/store_detail_screen.dart';
import 'package:spotter/features/feed/presentation/widgets/feed_card.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;

  const HomeScreen({
    Key? key,
    required this.currentUser,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedSort = '거리순';
  final List<String> _sortOptions = ['거리순', '인기순', '신규오픈순', '혜택많은순'];

  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  Timer? _debounce;

  KakaoMapController? mapController;
  Marker? _myLocationMarker;

  LatLng _currentCenter = LatLng(35.8714, 128.6014);
  bool _isMapLoading = true;
  bool _isMovingToMyLocation = false;

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if(mounted) {
        setState(() {
          _searchText = _searchController.text;
        });
      }
    });
  }

  Future<void> _initializeMap() async {
    await _checkAndRequestLocationPermission();
    await _moveToCurrentUserLocation(isInitial: true);
  }

  Future<void> _checkAndRequestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      status = await Permission.location.request();
    }
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> _moveToCurrentUserLocation({bool isInitial = false}) async {
    if (_isMovingToMyLocation) return;
    if (mounted) setState(() => _isMovingToMyLocation = true);

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final newCenter = LatLng(position.latitude, position.longitude);

      final myLocationMarker = Marker(
        markerId: 'myLocation',
        latLng: newCenter,
        markerImageSrc: 'http://t1.daumcdn.net/localimg/localimages/07/mapapidoc/markerStar.png',
      );

      if (mounted) {
        setState(() {
          _myLocationMarker = myLocationMarker;
          if (isInitial) {
            _currentCenter = newCenter;
            _isMapLoading = false;
          }
        });
      }
      mapController?.panTo(newCenter);
    } catch (e) {
      debugPrint("현재 위치 탐색 실패: $e");
      if (isInitial && mounted) {
        setState(() { _isMapLoading = false; });
      }
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) setState(() => _isMovingToMyLocation = false);
    }
  }

  Future<void> _deletePost(String postId) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시물이 삭제되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 중 오류가 발생했습니다: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _updatePost(String postId, String newCaption, List<String> newTags) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'caption': newCaption,
        'tags': newTags,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시물이 수정되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('수정 중 오류가 발생했습니다: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Query _buildQueryWithSearchAndSort(Query baseQuery) {
    Query query = baseQuery;
    if (_searchText.isNotEmpty) {
      List<String> searchTerms = _searchText.toLowerCase().split(' ').where((s) => s.isNotEmpty).toList();
      for (var term in searchTerms) {
        query = query.where('keywords', arrayContains: term);
      }
    } else {
      query = query.orderBy('createdAt', descending: true);
    }
    return query;
  }

  Stream<QuerySnapshot> _getStoreStream() {
    Query baseQuery = FirebaseFirestore.instance.collection('stores').where('status', isEqualTo: 'approved');
    return _buildQueryWithSearchAndSort(baseQuery).snapshots();
  }

  Stream<QuerySnapshot> _getPostStream() {
    Query baseQuery = FirebaseFirestore.instance.collection('posts');
    return _buildQueryWithSearchAndSort(baseQuery).snapshots();
  }

  Future<void> _onStoreOverlayTapped(String storeId) async {
    if (!mounted) return;
    try {
      Navigator.push(context, MaterialPageRoute(builder: (context) => StoreDetailScreen(
        storeId: storeId,
        currentUser: widget.currentUser,
      )));
    } catch (e) {
      debugPrint('가게 상세 정보 로딩 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true, floating: false, elevation: 1, toolbarHeight: 60,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Spotter', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.message_outlined), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MessageScreen()))),
                    IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
          SliverPersistentHeader(
            delegate: _StickyFilterHeaderDelegate(
              searchController: _searchController,
              selectedSort: _selectedSort,
              sortOptions: _sortOptions,
              onSortChanged: (newValue) { if (mounted) setState(() { _selectedSort = newValue!; }); },
            ),
            pinned: true,
          ),
          SliverToBoxAdapter(child: SizedBox(height: 250, child: StreamBuilder<QuerySnapshot>(
            stream: _getStoreStream(),
            builder: (context, snapshot) {
              List<CustomOverlay> storeOverlays = [];
              if (snapshot.hasData) {
                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final GeoPoint? location = data['location'];
                  if (location == null) continue;

                  String storeName = data['storeName'] ?? '이름 없음';
                  if (storeName.length > 8) {
                    storeName = '${storeName.substring(0, 7)}…';
                  }

                  final content = '<div style="background-color: white; border: 1.5px solid #FF7A00; border-radius: 8px; padding: 4px 8px; font-size: 13px; font-weight: bold; color: black; white-space: nowrap;">$storeName</div>';

                  storeOverlays.add(CustomOverlay(
                    customOverlayId: doc.id,
                    latLng: LatLng(location.latitude, location.longitude),
                    content: content,
                  ));
                }
              }

              final List<Marker> allMarkers = [];
              if (_myLocationMarker != null) {
                allMarkers.add(_myLocationMarker!);
              }

              return Stack(
                children: [
                  KakaoMap(
                    onMapCreated: ((controller) { mapController = controller; }),
                    markers: allMarkers,
                    customOverlays: storeOverlays,
                    center: _currentCenter,
                    onCustomOverlayTap: (overlayId, latLng) {
                      _onStoreOverlayTapped(overlayId);
                    },
                  ),
                  if (_isMapLoading)
                    Container(color: Colors.white.withOpacity(0.7), child: const Center(child: CircularProgressIndicator())),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: FloatingActionButton(
                      onPressed: _isMovingToMyLocation ? null : _moveToCurrentUserLocation,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      mini: true,
                      child: _isMovingToMyLocation
                          ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.orange)),
                      )
                          : const Icon(Icons.my_location),
                      heroTag: 'myLocationFab',
                    ),
                  ),
                ],
              );
            },
          ))),
          _buildSectionHeader("🔥 지금 뜨는 스팟 추천"),
          SliverToBoxAdapter(child: _buildTrendingSpotsList(context)),
          SliverToBoxAdapter(child: _BannerCarousel()),
          _buildSectionHeader("실시간 스팟 피드"),
          _buildRealtimeFeedList(),
        ],
      ),
    );
  }

  Widget _buildRealtimeFeedList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getPostStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text('피드가 없거나 검색 결과가 없습니다.'))));
        final feedItems = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {...data, 'id': doc.id};
        }).toList();
        return SliverList.builder(
          itemCount: feedItems.length,
          itemBuilder: (context, index) {
            final item = feedItems[index];
            return FeedCard(
              collectionPath: 'posts',
              key: ValueKey(item['id']),
              item: item,
              currentUser: widget.currentUser,
              onDelete: () => _deletePost(item['id']),
              onUpdate: (caption, tags) => _updatePost(item['id'], caption, tags),
            );
          },
        );
      },
    );
  }

  Widget _buildTrendingSpotsList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collectionGroup('rewards').where('isActive', isEqualTo: true).orderBy('createdAt', descending: true).limit(10).snapshots(),
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
              final displayImageUrl = spot['imageUrl'] ?? spot['storeImageUrl'];
              final spotForCard = {
                'type': '리워드', 'title': spot['title'] ?? '리워드', 'storeName': spot['storeName'] ?? '가게',
                'imageUrl': displayImageUrl, 'storeId': spot['storeId'],
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => StoreDetailScreen(
              storeId: storeId,
              // [아우] 🔥🔥🔥 최종 수정 지점입니다! 🔥🔥🔥
              currentUser: widget.currentUser,
            )));
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
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                    imageUrl, height: 140, width: 160, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(height: 140, width: 160, color: Colors.grey[200], child: const Icon(Icons.error_outline, color: Colors.grey)),
                  )
                      : Container(height: 140, width: 160, color: Colors.grey[200], child: const Icon(Icons.image_not_supported, color: Colors.grey)),
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
              child: Text(spot['storeName'] ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
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
                          return Text('단골 ${snapshot.data?.size ?? 0}', style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500));
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

  SliverToBoxAdapter _buildSectionHeader(String title) { return SliverToBoxAdapter( child: Padding( padding: const EdgeInsets.fromLTRB(16, 24, 16, 8), child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), if (title.contains("스팟 추천")) const Text('전체보기', style: TextStyle(color: Colors.grey, fontSize: 14)), ], ), ), ); }
}

class _StickyFilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController searchController;
  final String selectedSort;
  final List<String> sortOptions;
  final ValueChanged<String?> onSortChanged;

  _StickyFilterHeaderDelegate({
    required this.searchController,
    required this.selectedSort,
    required this.sortOptions,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final searchBarColor = isDarkMode ? Colors.grey[800] : Colors.grey[200];
    final dropdownColor = Theme.of(context).cardColor;
    final borderColor = isDarkMode ? Colors.grey[700] : Colors.grey[300];
    final iconColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 12.0),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(color: searchBarColor, borderRadius: BorderRadius.circular(12.0)),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                      hintText: '지역, 가게, #태그 검색',
                      prefixIcon: Icon(Icons.search, color: iconColor),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                      hintStyle: TextStyle(color: iconColor)
                  ),
                  style: TextStyle(fontSize: 15, color: textColor),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: dropdownColor,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: borderColor!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedSort,
                  dropdownColor: dropdownColor,
                  items: sortOptions.map((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value, style: TextStyle(fontSize: 14, color: textColor)));
                  }).toList(),
                  onChanged: onSortChanged,
                  icon: Icon(Icons.keyboard_arrow_down, size: 20, color: iconColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override double get maxExtent => 64.0;
  @override double get minExtent => 64.0;
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
              onPageChanged: (value) { if(mounted) setState(() { _current = value; }); },
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
                  color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)
                      .withOpacity(_current == entry.key ? 0.9 : 0.4),
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