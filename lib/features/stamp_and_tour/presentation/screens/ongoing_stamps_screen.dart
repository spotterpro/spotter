// 📁 lib/src/screens/ongoing_stamps_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OngoingStampsScreen extends StatelessWidget {
  const OngoingStampsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('진행중인 스탬프')),
        body: const Center(child: Text('로그인이 필요합니다.')),
      );
    }

    final query = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('ongoing_rewards')
        .where('rewardData.conditionType', isEqualTo: 'visitCount')
        .orderBy('startedAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('진행중인 스탬프'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('진행 중인 횟수 리워드가 없습니다.'));
          }

          final challenges = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: challenges.length,
            itemBuilder: (context, index) {
              final challenge = challenges[index].data() as Map<String, dynamic>;
              final rewardData = challenge['rewardData'] as Map<String, dynamic>? ?? {};
              return _buildStampCard(context, challenge, rewardData);
            },
          );
        },
      ),
    );
  }

  Widget _buildStampCard(BuildContext context, Map<String, dynamic> challengeData, Map<String, dynamic> rewardData) {
    final progress = challengeData['progress'] as int? ?? 0;
    final requiredStamps = rewardData['requiredStamps'] as int? ?? 1;
    final remaining = requiredStamps - progress;

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    rewardData['storeImageUrl'] ?? 'https://picsum.photos/seed/${challengeData['storeId']}/100/100',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_,__,___) => Container(width: 50, height: 50, color: Colors.grey[200]),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rewardData['storeName'] ?? '가게 이름', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      const SizedBox(height: 2),
                      Text(rewardData['title'] ?? '리워드', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(requiredStamps, (index) {
                final isStamped = index < progress;
                return Icon(
                  isStamped ? Icons.star_rounded : Icons.star_border_rounded,
                  color: isStamped ? Colors.orange : Colors.grey[300],
                  size: 36,
                );
              }),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.card_giftcard, color: Colors.green[800], size: 16),
                  const SizedBox(width: 8),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: '목표 달성까지 앞으로 '),
                        TextSpan(
                          text: '$remaining개',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        const TextSpan(text: ' 남았어요!'),
                      ],
                    ),
                    style: TextStyle(color: Colors.green[800]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}