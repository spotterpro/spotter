import 'package:flutter/material.dart';

class TourDetailScreen extends StatelessWidget {
  const TourDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('투어 진행 현황', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('동성로 핫플 정복', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('동성로의 가장 핫한 가게들을 방문해보세요.', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 32),
                _buildStep(icon: Icons.check_circle, color: Colors.orange, title: '(완료) 카페 스프링', subtitle: '수집일: 2024-05-20'),
                _buildStep(icon: Icons.check_circle, color: Colors.orange, title: '(완료) 맛집 파스타', subtitle: '수집일: 2024-05-18'),
                _buildStep(icon: Icons.looks_3_outlined, color: Colors.grey, title: '가게 3', subtitle: ''),
                _buildStep(icon: Icons.looks_4_outlined, color: Colors.grey, title: '가게 4', subtitle: '', isLast: true),
                const Divider(height: 40),
                Row(
                  children: [
                    Icon(Icons.redeem, color: Colors.teal.shade400, size: 30),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('최종 보상: 기념 뱃지 세트', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 4),
                          Text('모든 스탬프를 모으면 지급됩니다.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep({required IconData icon, required Color color, required String title, required String subtitle, bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Icon(icon, color: color),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    color: Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              if (subtitle.isNotEmpty)
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}