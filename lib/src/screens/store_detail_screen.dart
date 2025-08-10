import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spotter/src/screens/stamp_detail_screen.dart';
import 'package:spotter/src/screens/store_news_detail_screen.dart'; // 가게 소식 상세 화면 임포트

class StoreDetailScreen extends StatefulWidget {
  final Map<String, dynamic> storeData;
  const StoreDetailScreen({super.key, required this.storeData});

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  bool _isFavorited = false;
  late int _favoriteCount;

  final List<Map<String, dynamic>> _rewards = [
    {
      'id': 1, 'store': '맛집 파스타', 'reward': '알리오 올리오 1+1', 'subtitle': '3회 방문 시',
      'icon': Icons.card_giftcard, 'progress': 0, 'total': 3, 'seed': 'pasta_alio'
    },
    {
      'id': 2, 'store': '맛집 파스타', 'reward': '첫 방문 10% 할인', 'subtitle': '첫 방문 고객님',
      'icon': Icons.percent, 'progress': 0, 'total': 1, 'seed': 'pasta_sale'
    },
  ];

  int _selectedRewardId = -1;

  @override
  void initState() {
    super.initState();
    _favoriteCount = widget.storeData['regulars'] ?? 0;
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
      if (_isFavorited) {
        _favoriteCount++;
      } else {
        _favoriteCount--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.storeData['storeName'] ?? '가게 이름', style: const TextStyle(shadows: [Shadow(blurRadius: 10.0, color: Colors.black)])),
              background: Image.network(
                'https://picsum.photos/seed/${widget.storeData['seed']}/800/600',
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.3),
                colorBlendMode: BlendMode.darken,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildInfoSection(context),
              _buildSection(
                context: context,
                title: '🎁 리워드 선택',
                children: _rewards.map((reward) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _buildRewardCard(
                        context,
                        icon: reward['icon'],
                        title: reward['reward'] as String,
                        subtitle: reward['subtitle'] as String,
                        isSelected: _selectedRewardId == reward['id'],
                        onTap: () {
                          setState(() {
                            if (_selectedRewardId == reward['id']) {
                              _selectedRewardId = -1;
                            } else {
                              _selectedRewardId = reward['id'];
                            }
                          });
                        }
                    ),
                  );
                }).toList(),
              ),
              _buildSection(
                context: context,
                title: '📢 가게 최신 소식',
                children: [
                  // --- 형님의 요청대로 수정된 부분 ---
                  InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const StoreNewsDetailScreen()));
                      },
                      child: _buildNewsCard(context)
                  ),
                ],
              ),
              _buildSection(
                context: context,
                title: '📸 방문객 인증샷',
                children: [
                  _buildPhotoGrid(context)
                ],
              ),
              const SizedBox(height: 100),
            ]),
          ),
        ],
      ),
      bottomSheet: _buildBottomSheet(context),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.storeData['category'] ?? "카테고리", style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(widget.storeData['description'] ?? "가게 설명이 없습니다.", style: const TextStyle(fontSize: 16, height: 1.5)),
          const SizedBox(height: 16),
          _InfoRow(icon: Icons.location_on_outlined, text: widget.storeData['address'] ?? '주소 정보 없음'),
          const SizedBox(height: 8),
          const _InfoRow(icon: Icons.access_time_outlined, text: '매일 11:30 - 21:00 (브레이크 타임 15:00-17:00)'),
          const SizedBox(height: 8),
          _InfoRow(icon: Icons.people_alt_outlined, text: '단골: $_favoriteCount명'),
        ],
      ),
    );
  }

  Widget _buildSection({required BuildContext context, required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRewardCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required bool isSelected, required VoidCallback onTap}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isSelected ? Colors.orange : Theme.of(context).dividerColor,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isSelected ? Colors.orange.withOpacity(0.1) : Colors.teal.withOpacity(0.1),
          foregroundColor: isSelected ? Colors.orange[800] : Colors.teal,
          child: Icon(icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network('https://picsum.photos/seed/pasta_news/200/200', width: 80, height: 80, fit: BoxFit.cover),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("🍝 이번 주 신메뉴 출시! 바질 페스토 파스타를 만나보세요. 신선한 바질과 고소한 잣의 환상적인 조화! #신메뉴 #...", maxLines: 3, overflow: TextOverflow.ellipsis),
              SizedBox(height: 4),
              Text("1일 전", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network('https://picsum.photos/seed/laundry_feed/400/400', fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network('https://picsum.photos/seed/pasta_feed_my/400/400', fit: BoxFit.cover),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    final selectedReward = _selectedRewardId != -1
        ? _rewards.firstWhere((r) => r['id'] == _selectedRewardId)
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return ScaleTransition(child: child, scale: animation);
              },
              child: OutlinedButton.icon(
                key: ValueKey<bool>(_isFavorited),
                onPressed: _toggleFavorite,
                icon: FaIcon(_isFavorited ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart, color: Colors.red[400]),
                label: const Text('단골'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  foregroundColor: _isFavorited ? Colors.red[400] : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _selectedRewardId != -1 ? () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => StampDetailScreen(stampData: selectedReward!)));
                } : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.orange[400],
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                ),
                child: const Text('스탬프 도전하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}