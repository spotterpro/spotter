import 'package:flutter/material.dart';

class SpotIndexInfoScreen extends StatelessWidget {
  const SpotIndexInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('스팟 지수', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentIndexHeader(),
            const SizedBox(height: 32),
            const Text(
              '스팟 지수(Spot Index)는 Spotter 내에서 당신의 실제 탐험 활동과 기여도를 나타내는 명예 점수입니다. 스팟 지수가 높을수록 신뢰도 높은 동네 탐험가임을 증명합니다.',
              style: TextStyle(color: Colors.black54, height: 1.5),
            ),
            const SizedBox(height: 32),
            const Text('스팟 지수 획득 방법', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildIndexMethodCard(Icons.approval, '신규 스탬프 획득', '+10 점', '새로운 가게를 방문하여 첫 스탬프를 찍을 때마다 획득합니다.'),
            _buildIndexMethodCard(Icons.camera_alt, '인증 피드 작성', '+30 점', '스탬프를 인증하여 피드를 작성할 때마다 획득합니다.'),
            _buildIndexMethodCard(Icons.emoji_events, '투어 완료', '+100 점', '지정된 투어 코스를 모두 완료했을 때 보너스로 획득합니다.'),
            _buildIndexMethodCard(Icons.favorite, "내 게시물 '좋아요' 획득", '+1 점', "다른 유저에게 '좋아요'를 받을 때마다 획득합니다."),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentIndexHeader() {
    return Center(
      child: Column(
        children: [
          Text(
            '850', // TODO: 실제 스팟 지수 데이터 연동
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.orange.shade700),
          ),
          const Text('현재 나의 스팟 지수', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildIndexMethodCard(IconData icon, String title, String points, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(description, style: const TextStyle(color: Colors.black54, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(points, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}