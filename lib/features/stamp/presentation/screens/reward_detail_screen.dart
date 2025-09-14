import 'package:flutter/material.dart';

class RewardDetailScreen extends StatelessWidget {
  const RewardDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.grey[100] : Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('스탬프 적립 현황'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(width: 60, height: 60, color: Colors.grey.shade300),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('맛집 파스타', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('스탬프 적립 카드', style: TextStyle(color: Colors.grey)),
                      ],
                    )
                  ],
                ),
                const Divider(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(
                        index < 2 ? Icons.star : Icons.star_border,
                        color: Colors.orange,
                        size: 40,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('목표 달성까지 앞으로 ', style: TextStyle(fontSize: 16, color: Colors.black)),
                      Text('1개', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                      Text(' 남았어요!', style: TextStyle(fontSize: 16, color: Colors.black)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.card_giftcard, color: Colors.green.shade600),
                    const SizedBox(width: 8),
                    Text('알리오 올리오 1+1', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}