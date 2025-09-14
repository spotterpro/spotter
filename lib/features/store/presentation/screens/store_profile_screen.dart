import 'package:flutter/material.dart';

class StoreProfileScreen extends StatefulWidget {
  const StoreProfileScreen({super.key});

  @override
  State<StoreProfileScreen> createState() => _StoreProfileScreenState();
}

class _StoreProfileScreenState extends State<StoreProfileScreen> {
  int? _selectedRewardIndex; // 선택된 리워드의 인덱스를 저장

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1554118811-1e0d58224f24?q=80&w=3247&auto=format&fit=crop',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.5),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16.0),
                        children: [
                          _buildStoreHeader(),
                          const SizedBox(height: 16),
                          _buildStoreInfo(),
                          const SizedBox(height: 24),
                          // [레이아웃 변경] 가게 최신 소식
                          _buildSectionTitle('📢 가게 최신 소식'),
                          _buildStoreNewsCard(),
                          const SizedBox(height: 24),
                          // [레이아웃 변경] 진행중인 리워드
                          _buildSectionTitle('🎁 진행중인 리워드'),
                          _buildSelectableRewardCard(0, '알리오 올리오 1+1', '3회 방문 시'),
                          _buildSelectableRewardCard(1, '첫 방문 10% 할인', '첫 방문 고객님'),
                          _buildSelectableRewardCard(2, '행운의 돌림판', '가게에서 NFC 태깅 시'),
                          const SizedBox(height: 24),
                          _buildSectionTitle('📸 방문객 인증샷'),
                          _buildVisitorPhotosGrid(),
                        ],
                      ),
                    ),
                    _buildBottomActionButtons(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // [기능 추가] 선택 가능한 리워드 카드
  Widget _buildSelectableRewardCard(int index, String title, String subtitle) {
    final bool isSelected = _selectedRewardIndex == index;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.orange : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedRewardIndex = null; // 다시 탭하면 선택 해제
            } else {
              _selectedRewardIndex = index;
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Container(width: 50, height: 50, color: Colors.grey.shade300),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
        ),
      ),
    );
  }

  // [UI 수정] 하단 버튼 크기 조율
  Widget _buildBottomActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 0, blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.favorite_border),
              label: const Text('단골 맺기'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // TODO: 스탬프 태깅 창 띄우기 (선택된 리워드 정보 전달)
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: const Color(0xFFFFA726),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('스탬프 찍기', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ... 이하 다른 위젯 메소드들은 이전과 동일합니다 ...
  Widget _buildStoreHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('맛집 파스타', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            const Icon(Icons.local_fire_department, color: Colors.orange),
          ],
        ),
        const Text('음식점', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 12),
        const Text(
          '매일 아침 직접 뽑는 생면으로 만드는 인생 파스타. 특별한 날을 위한 최고의 선택.',
          style: TextStyle(height: 1.5),
        ),
      ],
    );
  }

  Widget _buildStoreInfo() {
    return Column(
      children: [
        _buildInfoRow(Icons.location_on_outlined, '대구시 중구 서문시장'),
        _buildInfoRow(Icons.access_time_outlined, '매일 11:30 - 21:00 (브레이크 타임 15:00-17:00)'),
        _buildInfoRow(Icons.people_alt_outlined, '단골 수: 88명'),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStoreNewsCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Container(width: 70, height: 70, color: Colors.grey.shade300),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('이번 주 스페셜! 🍝 트러플 크림 파스타와 함께하는 낭만적인 저녁. 오직 이번 주에만 만나보실 수 있습니다. #맛집...', style: TextStyle(fontSize: 14)),
                  SizedBox(height: 4),
                  Text('2025. 9. 12.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitorPhotosGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Container(color: Colors.grey.shade300),
        );
      },
    );
  }
}