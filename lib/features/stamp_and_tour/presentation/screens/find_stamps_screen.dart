import 'package:flutter/material.dart';
import 'package:spotter/features/store/presentation/screens/store_detail_screen.dart';
import 'package:spotter/features/stamp_and_tour/presentation/screens/tour_detail_screen.dart';

class FindStampsScreen extends StatelessWidget {
  // [아우] 🔥🔥🔥 StoreDetailScreen에 전달할 currentUser를 이 화면부터 받아야 합니다.
  final Map<String, dynamic> currentUser;

  const FindStampsScreen({
    super.key,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        'isTour': false,
        'icon': Icons.card_giftcard,
        'iconColor': Colors.teal,
        'title': "알리오 올리오 1+1",
        'subtitle': "맛집 파스타",
        'trailing': "800m",
        'storeData': <String, dynamic>{
          'id': '6PdcdJAiNqVpZ9DDvtY0itRGYBP2',
          'storeName': '맛집 파스타',
          'regulars': 125,
          'seed': 'pasta',
          'category': '음식점',
          'description': '매일 아침 직접 뽑는 생면으로 만드는 인생 파스타.',
          'address': '대구시 중구 서문시장',
        },
      },
      {
        'isTour': false,
        'icon': Icons.percent,
        'iconColor': Colors.teal,
        'title': "첫 방문 10% 할인",
        'subtitle': "맛집 파스타",
        'trailing': "800m",
        'storeData': <String, dynamic>{
          'id': '6PdcdJAiNqVpZ9DDvtY0itRGYBP2',
          'storeName': '맛집 파스타',
          'regulars': 125,
          'seed': 'pasta',
          'category': '음식점',
          'description': '매일 아침 직접 뽑는 생면으로 만드는 인생 파스타.',
          'address': '대구시 중구 서문시장',
        },
      },
      {
        'isTour': true,
        'icon': Icons.menu_book,
        'iconColor': Colors.purple,
        'title': "파스타 로드 완전정복",
        'subtitle': "보상: 고르곤졸라 피자",
        'trailing': "투어",
        'tourData': <String, dynamic>{
          'title': '파스타 로드 완전정복', 'description': '우리 동네 파스타 맛집 3곳을 방문해보세요!',
          'reward': '고르곤졸라 피자',
          'stamps': [
            {'completed': true, 'name': '맛집 파스타', 'date': '2024-05-20', 'seed': 'pasta'},
            {'completed': false, 'name': '생면 파스타', 'date': null, 'seed': 'pasta2'},
            {'completed': false, 'name': '화덕피자 파스타', 'date': null, 'seed': 'pasta3'},
          ],
        },
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('주변 스탬프 찾기'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          final storeData = item['storeData'] is Map
              ? Map<String, dynamic>.from(item['storeData'] as Map)
              : <String, dynamic>{};
          final tourData = item['tourData'] is Map
              ? Map<String, dynamic>.from(item['tourData'] as Map)
              : <String, dynamic>{};

          return _buildItem(
            context,
            icon: item['icon'] as IconData,
            iconColor: item['iconColor'] as Color,
            title: item['title'] as String,
            subtitle: item['subtitle'] as String,
            trailing: item['trailing'] as String,
            isTour: item['isTour'] as bool,
            storeData: storeData,
            tourData: tourData,
            // [아우] 🔥🔥🔥 currentUser 정보를 _buildItem으로 전달합니다.
            currentUser: currentUser,
          );
        },
      ),
    );
  }

  Widget _buildItem(
      BuildContext context, {
        required IconData icon,
        required Color iconColor,
        required String title,
        required String subtitle,
        required String trailing,
        required bool isTour,
        required Map<String, dynamic> storeData,
        required Map<String, dynamic> tourData,
        // [아우] 🔥🔥🔥 currentUser 정보를 받습니다.
        required Map<String, dynamic> currentUser,
      }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          foregroundColor: iconColor,
          child: Icon(icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(trailing, style: TextStyle(color: isTour ? Colors.purple : Colors.grey[600])),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
        onTap: () {
          if (isTour) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => TourDetailScreen(tourData: tourData)));
          } else {
            final storeId = storeData['id'] as String?;
            if (storeId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // [아우] 🔥🔥🔥 StoreDetailScreen에 currentUser를 전달합니다!
                  builder: (context) => StoreDetailScreen(
                    storeId: storeId,
                    currentUser: currentUser,
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }
}