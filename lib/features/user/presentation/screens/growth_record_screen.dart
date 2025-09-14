import 'package:flutter/material.dart';
import 'dart:math' as math;

class GrowthRecordScreen extends StatelessWidget {
  const GrowthRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('나의 성장 기록', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
            _buildLevelGauge(),
            const SizedBox(height: 32),
            _buildSectionTitle('XP 시스템이란?'),
            const SizedBox(height: 8),
            const Text(
              'XP(경험치)는 Spotter에서의 다양한 활동을 통해 얻을 수 있는 포인트입니다. XP를 모아 레벨을 올리고, 더 높은 등급의 칭호를 획득하여 당신의 영향력을 증명해보세요!',
              style: TextStyle(color: Colors.black54, height: 1.5),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('XP 획득 방법'),
            const SizedBox(height: 12),
            _buildXpMethodGrid(),
            const SizedBox(height: 32),
            _buildSectionTitle('레벨별 칭호'),
            const SizedBox(height: 12),
            _buildLevelTitlesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildLevelGauge() {
    const double currentXp = 530;
    const double totalXp = 1000;
    const double progress = currentXp / totalXp;

    return Center(
      child: SizedBox(
        width: 150,
        height: 150,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: 1,
              strokeWidth: 12,
              backgroundColor: Colors.grey[200],
              color: Colors.orange.shade100,
            ),
            Transform.rotate(
              angle: -math.pi / 2,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 12,
                color: Colors.orange,
                strokeCap: StrokeCap.round,
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('LV.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const Text('25', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, height: 1.2)),
                  Text('${currentXp.toInt()} / ${totalXp.toInt()} XP', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildXpMethodGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        _buildXpMethodCard(Icons.camera_alt, '피드 인증', '+20 XP'),
        _buildXpMethodCard(Icons.approval, '스탬프 획득', '+10 XP'),
        _buildXpMethodCard(Icons.emoji_events, '투어 완료', '+50 XP'),
        _buildXpMethodCard(Icons.card_giftcard, '리워드 사용', '+5 XP'),
        _buildXpMethodCard(Icons.chat_bubble, '커뮤니티 활동', '+2 XP'),
      ],
    );
  }

  Widget _buildXpMethodCard(IconData icon, String title, String xp) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(xp, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelTitlesList() {
    return Column(
      children: [
        _buildTitleMilestone('LV. 1', '새내기 스포터', true),
        _buildTitleMilestone('LV. 10', '동네 탐험가', true),
        _buildTitleMilestone('LV. 25', '골목대장', true),
        _buildTitleMilestone('LV. 50', '도시 개척자', false),
        _buildTitleMilestone('LV. 100', '스팟 마스터', false),
      ],
    );
  }

  Widget _buildTitleMilestone(String level, String title, bool achieved) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: achieved ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: achieved ? Colors.green.shade100 : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: achieved ? Colors.green : Colors.grey.shade300,
            foregroundColor: Colors.white,
            radius: 20,
            child: const Icon(Icons.stars),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(level, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}