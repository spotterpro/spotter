import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:spotter/features/user/presentation/screens/user_profile_screen.dart'; // [추가]

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late KakaoMapController mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Spotter',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.black54),
            onPressed: () {},
          ),
          IconButton(
            icon:
            const Icon(Icons.notifications_none_outlined, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: '   지역, 가게, #태그 검색',
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: '거리순',
                        items: <String>['거리순', '인기순', '최신순']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (_) {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 250,
              child: KakaoMap(
                onMapCreated: (controller) {
                  mapController = controller;
                  mapController.setCenter(LatLng(35.8714354, 128.601445));
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF2C3E50),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Row(
                children: [
                  const Icon(Icons.storefront, color: Colors.white, size: 32),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '선착순 100명 한정, 3개월 무료!',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '가게를 등록하고 모든 기능을 무료로 이용해보세요.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '🔥 지금 뜨는 스팟 추천',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('전체보기'),
                      ),
                    ],
                  ),
                  const Text('사장님과 크루가 만든 특별한 혜택과 투어를 만나보세요!'),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.only(right: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: SizedBox(
                            width: 150,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade400,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12.0),
                                      topRight: Radius.circular(12.0),
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('스팟 이름', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text('스팟에 대한 간단한 설명', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                '실시간 스팟 피드',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                return _buildFeedItem(context); // context 전달
              },
              childCount: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedItem(BuildContext context) { // context를 받도록 수정
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            // [수정] GestureDetector를 추가하여 프로필 화면으로 이동시킵니다.
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const UserProfileScreen()),
                );
              },
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey,
                  ),
                  SizedBox(width: 12.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('스포터', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('편집샵 ABC · 2025-09-12', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 300,
            color: Colors.grey.shade300,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text('새로 산 옷 자랑! 이 편집샵 완전 내 스타일이야👍'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 8.0,
              children: ['#오오티디', '#패션', '#편집샵']
                  .map((tag) => Chip(
                label: Text(tag, style: const TextStyle(fontSize: 12)),
                backgroundColor: Colors.grey.shade200,
                side: BorderSide.none,
              ))
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Icon(Icons.favorite_border, color: Colors.grey.shade700, size: 20),
                const SizedBox(width: 4),
                Text('좋아요 112', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                const SizedBox(width: 16),
                Icon(Icons.chat_bubble_outline, color: Colors.grey.shade700, size: 20),
                const SizedBox(width: 4),
                Text('댓글 3', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}