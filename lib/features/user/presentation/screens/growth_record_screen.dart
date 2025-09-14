import 'package:flutter/material.dart';
import 'dart:math' as math;

class GrowthRecordScreen extends StatelessWidget {
  const GrowthRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('나의 성장 기록', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLevelGauge(context),
            const SizedBox(height: 32),
            _buildSectionTitle('XP 시스템이란?'),
            const SizedBox(height: 8),
            const Text(
              'XP(경험치)는 Spotter에서의 다양한 활동을 통해 얻을 수 있는 포인트입니다. XP를 모아 레벨을 올리고, 더 높은 등급의 칭호를 획득하여 당신의 영향력을 증명해보세요!',
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('XP 획득 방법'),
            const SizedBox(height: 12),
            _buildXpMethodGrid(context),
            const SizedBox(height: 32),
            _buildSectionTitle('레벨별 칭호'),
            const SizedBox(height: 12),
            _buildLevelTitlesList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildLevelGauge(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
              backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              color: isDarkMode ? Colors.orange.shade800.withOpacity(0.5) : Colors.orange.shade100,
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

  Widget _buildXpMethodGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        _buildXpMethodCard(context, Icons.camera_alt, '피드 인증', '+20 XP'),
        _buildXpMethodCard(context, Icons.approval, '스탬프 획득', '+10 XP'),
        _buildXpMethodCard(context, Icons.emoji_events, '투어 완료', '+50 XP'),
        _buildXpMethodCard(context, Icons.card_giftcard, '리워드 사용', '+5 XP'),
        _buildXpMethodCard(context, Icons.chat_bubble, '커뮤니티 활동', '+2 XP'),
      ],
    );
  }

  Widget _buildXpMethodCard(BuildContext context, IconData icon, String title, String xp) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
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

  Widget _buildLevelTitlesList(BuildContext context) {
    return Column(
      children: [
        _buildTitleMilestone(context, 'LV. 1', '새내기 스포터', true),
        _buildTitleMilestone(context, 'LV. 10', '동네 탐험가', true),
        _buildTitleMilestone(context, 'LV. 25', '골목대장', true),
        _buildTitleMilestone(context, 'LV. 50', '도시 개척자', false),
        _buildTitleMilestone(context, 'LV. 100', '스팟 마스터', false),
      ],
    );
  }

  Widget _buildTitleMilestone(BuildContext context, String level, String title, bool achieved) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color cardColor = achieved
        ? (isDarkMode ? Colors.green.shade900.withOpacity(0.6) : Colors.green.shade50)
        : (isDarkMode ? const Color(0xFF1E1E1E) : Colors.white);

    final Color borderColor = achieved
        ? (isDarkMode ? Colors.green.shade800 : Colors.green.shade100)
        : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200);

    final Color iconBackgroundColor = achieved
        ? (isDarkMode ? Colors.green.shade400 : Colors.green)
        : (isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300);

    final Color iconForegroundColor = achieved ? Colors.white : (isDarkMode ? Colors.grey.shade300 : Colors.white);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: iconBackgroundColor,
            foregroundColor: iconForegroundColor,
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