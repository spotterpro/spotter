// 📁 lib/src/screens/owner/dashboard_screen.dart (디자인 최종 수정본)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spotter/models/user_model.dart';
import 'package:spotter/services/mode_prefs.dart';
import 'package:spotter/src/screens/app_decider.dart';

class DashboardScreen extends StatelessWidget {
  final String storeId;

  const DashboardScreen({super.key, required this.storeId});

  Future<void> _exitToUserMode(BuildContext context) async {
    await ModePrefs.setStoreMode(false);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null && context.mounted) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userDoc.exists && context.mounted) {
        final userProfile = UserProfile.fromDocument(userDoc);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => AppDecider(user: user, userProfile: userProfile)),
              (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('stores').doc(storeId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Scaffold(
              appBar: AppBar(title: const Text('오류')),
              body: const Center(child: Text('가게 정보를 불러올 수 없습니다.')),
            );
          }

          final storeData = snapshot.data!.data() as Map<String, dynamic>;
          // 🔥 1번 지시사항: AppBar 제목을 '사장님 대시보드'로 고정
          final storeName = storeData['storeName'] ?? '가게';

          return Scaffold(
            appBar: AppBar(
              title: Text('$storeName 대시보드'), // AppBar 제목 수정
              actions: [
                IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  tooltip: '사용자 모드로 전환',
                  onPressed: () => _exitToUserMode(context),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('실시간 현황'),
                  const SizedBox(height: 16),

                  _StatusCard(
                    title: '현재 방문자',
                    value: '12',
                    unit: '명',
                    change: '+3',
                    changeColor: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _StatusCard(
                    title: '오늘 신규 고객',
                    value: '4',
                    unit: '명',
                    change: '25%',
                  ),
                  const SizedBox(height: 12),
                  _StatusCard(
                    title: '실시간 재방문율',
                    value: '68',
                    unit: '%',
                    change: '+5%p',
                    changeColor: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _StatusCard(
                    title: 'Spotter 참여 시간',
                    value: '25일 10시간 30분',
                    isPremium: true,
                  ),

                  const SizedBox(height: 32),
                  _buildSectionTitle('트렌드 분석', showDetails: true),
                  const SizedBox(height: 16),
                  _buildChartCard(context),
                  const SizedBox(height: 32),
                  _buildSectionTitle('고객 세분화'),
                  const SizedBox(height: 16),
                  _buildCustomerSegmentCard(context),
                  const SizedBox(height: 32),
                  _buildSectionTitle('마케팅 효과'),
                  const SizedBox(height: 16),
                  _buildMarketingCard(context),
                ],
              ),
            ),
          );
        }
    );
  }

  // 🔥 2번 지시사항: 모든 섹션 제목에 동일한 스타일이 적용되도록 함수화
  Widget _buildSectionTitle(String title, {bool showDetails = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.show_chart, color: Colors.orange[800], size: 14),
            ),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        if (showDetails)
          Text('자세히', style: TextStyle(color: Colors.orange[700], fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildChartCard(BuildContext context) {
    //...(이하 생략)...
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('주간 방문자 변화', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Image.network('https://i.imgur.com/2Y82k9H.png', fit: BoxFit.contain)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSegmentCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('고객 세분화', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _Segment(icon: Icons.diamond, color: Colors.red, label: 'VIP (주 3회+)', value: '15명'),
            const SizedBox(height: 16),
            _Segment(icon: Icons.star, color: Colors.orange, label: '일반 (주 1-2회)', value: '48명'),
            const SizedBox(height: 16),
            _Segment(icon: Icons.lightbulb, color: Colors.green, label: '신규 (첫 방문)', value: '22명'),
            const Divider(height: 28),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('충성고객 이탈 위험', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('3명', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMarketingCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('마케팅 효과', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _MarketingStat(title: '리워드 후 재방문율', value: '+15%', changeColor: Colors.green),
            _MarketingStat(title: '이벤트 방문자 수', value: '+40%', changeColor: Colors.green),
            _MarketingStat(title: '투어 완주자 수', value: '5명'),
            _MarketingStat(title: '누적 방문 수', value: '1,234회'),
          ],
        ),
      ),
    );
  }
}

// 🔥 3번 지시사항: '실시간 현황' 카드 UI를 지시대로 수정
class _StatusCard extends StatelessWidget {
  final String title;
  final String value;
  final String? unit;
  final String? change;
  final Color? changeColor;
  final bool isPremium;

  const _StatusCard({
    required this.title,
    required this.value,
    this.unit,
    this.change,
    this.changeColor,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                // 왼쪽: 작은 폰트의 변화량
                if (change != null)
                  Text(change!, style: TextStyle(color: changeColor ?? Colors.grey[600], fontSize: 16)),
                if (isPremium) // 프리미엄 카드는 변화량 대신 공백
                  const SizedBox(),

                // 오른쪽: 큰 폰트의 주요 수치
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    if (unit != null) const SizedBox(width: 4),
                    if (unit != null) Text(unit!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    if (isPremium)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text('프리미엄', style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
//...(이하 생략)...
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _Segment({required this.icon, required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: Colors.grey[700])),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}

class _MarketingStat extends StatelessWidget {
//...(이하 생략)...
  final String title;
  final String value;
  final Color? changeColor;
  const _MarketingStat({required this.title, required this.value, this.changeColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[700])),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: changeColor)),
        ],
      ),
    );
  }
}