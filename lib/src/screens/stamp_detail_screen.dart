import 'package:flutter/material.dart';

class StampDetailScreen extends StatelessWidget {
  final Map<String, dynamic> stampData;

  const StampDetailScreen({super.key, required this.stampData});

  @override
  Widget build(BuildContext context) {
    final int progress = stampData['progress'] as int;
    final int total = stampData['total'] as int;

    return Scaffold(
      appBar: AppBar(
        title: Text(stampData['store'] as String),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage('https://picsum.photos/seed/${stampData['seed']}/200/200'),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '${stampData['store'] as String} 스탬프 적립 카드',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: total,
              itemBuilder: (context, index) {
                if (index < progress) {
                  // 완료된 스탬프
                  return CircleAvatar(
                    backgroundColor: Colors.orange[400],
                    child: const Icon(Icons.star, color: Colors.white),
                  );
                } else {
                  // 비어있는 스탬프
                  return CircleAvatar(
                    backgroundColor: Colors.grey[200],
                  );
                }
              },
            ),
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Text(
                    '목표 달성까지 앞으로 ${total - progress}개 남았어요!',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12)
                    ),
                    child: Text(
                      '🎁 ${stampData['reward'] as String}',
                      style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}