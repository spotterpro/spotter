import 'package:flutter/material.dart';

class MyGrowthLogScreen extends StatelessWidget {
  const MyGrowthLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('나의 성장 기록'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCircularProgress(),
            const SizedBox(height: 32),
            _buildSectionTitle('XP 시스템이란?'),
            const SizedBox(height: 8),
            _buildXpSystemInfo(),
            const SizedBox(height: 32),
            _buildSectionTitle('XP 획득 방법'),
            const SizedBox(height: 16),
            _buildXpMethodsWrap(),
            const SizedBox(height: 32),
            _buildSectionTitle('레벨별 칭호'),
            const SizedBox(height: 16),
            _buildLevelTitlesList(),
          ],
        ),
      ),
    );
  }

  // --- 형님의 요청대로 수정된 부분 ---
  Widget _buildCircularProgress() {
    const double currentXp = 530;
    const double maxXP = 1000;
    const double progress = currentXp / maxXP;

    return Center(
      child: SizedBox(
        width: 150,
        height: 150,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 10,
              backgroundColor: Colors.grey[200],
              // 배경 트랙 색상을 더 연한 주황색으로 변경
              color: Colors.orange.withOpacity(0.2),
            ),
            CircularProgressIndicator(
              value: progress,
              strokeWidth: 10,
              // 게이지 색상을 XP 바와 동일한 Colors.orange[400]으로 변경
              color: Colors.orange[400],
              strokeCap: StrokeCap.round,
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('LV.', style: TextStyle(color: Colors.grey)),
                  Text('25', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                  Text('$currentXp / $maxXP XP', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  // --- 여기까지 수정되었습니다 ---

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildXpSystemInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'XP(경험치)는 Spotter에서의 다양한 활동을 통해 얻을 수 있는 포인트입니다. XP를 모아 레벨을 올리고, 더 높은 등급의 칭호를 획득하여 당신의 영향력을 증명해보세요!',
        style: TextStyle(color: Colors.black87, height: 1.5),
      ),
    );
  }

  Widget _buildXpMethodsWrap() {
    final List<Widget> xpCards = [
      const _XpMethodCard(icon: Icons.camera_alt_outlined, title: '피드 인증', xp: '+20 XP'),
      const _XpMethodCard(icon: Icons.style_outlined, title: '스탬프 획득', xp: '+10 XP'),
      const _XpMethodCard(icon: Icons.emoji_events_outlined, title: '투어 완료', xp: '+50 XP'),
      const _XpMethodCard(icon: Icons.card_giftcard_outlined, title: '리워드 사용', xp: '+5 XP'),
      const _XpMethodCard(icon: Icons.chat_bubble_outline, title: '커뮤니티 활동', xp: '+2 XP'),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: xpCards.map((card) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: (constraints.maxWidth / 2) - 6,
              child: card,
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildLevelTitlesList() {
    return Column(
      children: [
        _LevelTitleTile(icon: Icons.child_friendly, level: 1, title: '새내기 스포터', isUnlocked: true),
        _LevelTitleTile(icon: Icons.explore_outlined, level: 10, title: '동네 탐험가', isUnlocked: true),
        _LevelTitleTile(icon: Icons.emoji_emotions_outlined, level: 25, title: '골목대장', isUnlocked: true),
        _LevelTitleTile(icon: Icons.business_outlined, level: 50, title: '도시 개척자', isUnlocked: false),
        _LevelTitleTile(icon: Icons.workspace_premium_outlined, level: 100, title: '스팟 마스터', isUnlocked: false),
      ],
    );
  }
}

class _XpMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String xp;
  const _XpMethodCard({required this.icon, required this.title, required this.xp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(xp, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _LevelTitleTile extends StatelessWidget {
  final IconData icon;
  final int level;
  final String title;
  final bool isUnlocked;

  const _LevelTitleTile({
    required this.icon,
    required this.level,
    required this.title,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: isUnlocked ? Colors.orange.withOpacity(0.1) : Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isUnlocked ? Colors.orange[400] : Colors.grey[400],
          foregroundColor: Colors.white,
          child: Icon(icon),
        ),
        title: Text('LV. $level', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(title),
        trailing: isUnlocked
            ? Icon(Icons.check_circle, color: Colors.green[600])
            : null,
      ),
    );
  }
}