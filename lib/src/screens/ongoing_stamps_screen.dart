import 'package:flutter/material.dart';
import 'package:spotter/src/screens/stamp_detail_screen.dart';

class OngoingStampsScreen extends StatelessWidget {
  const OngoingStampsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ongoingStamps = [
      {'store': '카페 스프링', 'reward': '아메리카노 1잔 무료', 'progress': 1, 'total': 5, 'seed': 'cafe'},
      {'store': '헬스 클럽', 'reward': '프로틴 쉐이크 증정', 'progress': 2, 'total': 10, 'seed': 'gym'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('진행중인 스탬프'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ongoingStamps.length,
        itemBuilder: (context, index) {
          final stamp = ongoingStamps[index];
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                // --- 형님의 요청대로 수정된 부분 ---
                // 스탬프 상세 화면으로 이동할 때, 해당 스탬프의 데이터를 함께 전달합니다.
                Navigator.push(context, MaterialPageRoute(builder: (context) => StampDetailScreen(stampData: stamp)));
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network('https://picsum.photos/seed/${stamp['seed']}/100/100', width: 70, height: 70, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('진행중인 리워드', style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(stamp['store'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 2),
                          Text(stamp['reward'] as String),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: (stamp['progress'] as int) / (stamp['total'] as int),
                                  backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200],
                                  color: Colors.orange[400],
                                  minHeight: 6,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('${stamp['progress']}/${stamp['total']}', style: const TextStyle(fontWeight: FontWeight.bold)),
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
        },
      ),
    );
  }
}