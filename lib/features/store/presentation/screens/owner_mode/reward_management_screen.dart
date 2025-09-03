// 📁 lib/src/screens/owner/reward_management_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spotter/features/store/presentation/screens/owner_mode/reward_form_screen.dart';


class RewardManagementScreen extends StatelessWidget {
  final String storeId;
  const RewardManagementScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('리워드 관리'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // + 새 리워드 만들기 버튼
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => RewardFormScreen(storeId: storeId)));
              },
              child: DottedBorder(
                color: Colors.orange,
                strokeWidth: 1.5,
                dashPattern: const [8, 6],
                radius: const Radius.circular(12),
                borderType: BorderType.RRect,
                child: Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      '+ 새 리워드 만들기',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 현재 리워드 목록
            const Text(
              '현재 리워드 목록',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Firestore에서 리워드 목록 실시간으로 불러오기
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('stores')
                  .doc(storeId)
                  .collection('rewards')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('리워드를 불러오는 중 오류가 발생했습니다.'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        '아직 생성된 리워드가 없습니다.\n새로운 리워드를 만들어 고객 방문을 유도해보세요!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, height: 1.5),
                      ),
                    ),
                  );
                }

                final rewards = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: rewards.length,
                  itemBuilder: (context, index) {
                    final reward = rewards[index].data() as Map<String, dynamic>;
                    return _RewardCard(
                      title: reward['title'] ?? '이름 없는 리워드',
                      subtitle: '스탬프 ${reward['requiredStamps'] ?? '?'}개 필요',
                      isActive: reward['isActive'] ?? true,
                      onTap: () {
                        // TODO: 리워드 수정 화면으로 이동
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// 리워드 목록 카드 UI
class _RewardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isActive;
  final VoidCallback onTap;

  const _RewardCard({
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: (isActive ? Colors.green : Colors.grey).withOpacity(0.1),
          foregroundColor: isActive ? Colors.green[800] : Colors.grey[600],
          child: const FaIcon(FontAwesomeIcons.gift, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isActive ? null : Colors.grey,
            decoration: isActive ? TextDecoration.none : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Text(subtitle, style: TextStyle(color: isActive ? Colors.grey[600] : Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}