import 'package:flutter/material.dart';
import 'package:spotter/src/screens/tour_detail_screen.dart';

class OngoingToursScreen extends StatelessWidget {
  const OngoingToursScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ongoingTours = [
      {
        'title': '동네 카페 정복하기', 'description': '우리 동네 숨은 카페 5곳을 방문해보세요!',
        'reward': '보상: 아메리카노 1잔 무료', 'progress': 3, 'total': 5,
        'stamps': [
          {'completed': true, 'name': '카페 스프링', 'date': '2024-05-20', 'seed': 'cafe1'},
          {'completed': true, 'name': '커피나무', 'date': '2024-05-22', 'seed': 'cafe2'},
          {'completed': true, 'name': '스타벅스', 'date': '2024-05-25', 'seed': 'cafe3'},
          {'completed': false, 'name': '가게 4', 'date': null, 'seed': 'cafe4'},
          {'completed': false, 'name': '가게 5', 'date': null, 'seed': 'cafe5'},
        ]
      },
      {
        'title': '건강이 최고 챌린지', 'description': '헬스, 요가, 필라테스 3종 도장깨기',
        'reward': '보상: 프로틴 쉐이크 증정', 'progress': 1, 'total': 3,
        'stamps': [
          {'completed': true, 'name': '헬스 클럽', 'date': '2024-05-19', 'seed': 'gym'},
          {'completed': false, 'name': '요가 스튜디오', 'date': null, 'seed': 'yoga'},
          {'completed': false, 'name': '필라테스 센터', 'date': null, 'seed': 'pilates'},
        ]
      },
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('진행중인 투어'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: ongoingTours.length,
        itemBuilder: (context, index) {
          final tour = ongoingTours[index];
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TourDetailScreen(tourData: tour)));
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tour['title'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(tour['description'] as String, style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(tour['reward'] as String, style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: (tour['progress'] as int) / (tour['total'] as int),
                            backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200],
                            color: Colors.orange[400],
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('${tour['progress']}/${tour['total']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}