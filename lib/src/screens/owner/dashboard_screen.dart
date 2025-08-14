// 📁 lib/src/screens/owner/dashboard_screen.dart

import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final String storeId;

  const DashboardScreen({super.key, required this.storeId});

  // 사용자 모드로 돌아가는 공용 함수
  void _exitToUserMode(BuildContext context) {
    // MainScreen으로 돌아가는 로직 (추후 보강)
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('가게 대시보드'),
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
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _InfoCard(title: '현재 방문자', value: '3명', color: Colors.blue),
                _InfoCard(title: '오늘 신규손님', value: '12명', color: Colors.green),
                _InfoCard(title: '실시간 재방문율', value: '35%', color: Colors.orange),
                _InfoCard(title: '총 스포터 이용', value: '105회', color: Colors.purple),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('트렌드 분석'),
            const SizedBox(height: 16),
            _buildChartCard(context, '주간 방문자 변화'),
            const SizedBox(height: 16),
            _buildCustomerSegmentCard(context),
            const SizedBox(height: 32),
            _buildSectionTitle('마케팅 효율'),
            const SizedBox(height: 16),
            _buildMarketingCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
  }

  Widget _buildChartCard(BuildContext context, String title) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container( // Placeholder for graph
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Text('주간 방문자 그래프 영역')),
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
        side: BorderSide(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('방문 빈도별 손님 분포', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Segment(color: Colors.red, label: 'VIP', value: '15%'),
                _Segment(color: Colors.orange, label: '단골', value: '35%'),
                _Segment(color: Colors.green, label: '신규', value: '50%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketingCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _MarketingStat(title: '리워드 사용 후 재방문율', value: '68%'),
            const Divider(height: 24),
            _MarketingStat(title: '이벤트 참여 방문자', value: '42명'),
            const Divider(height: 24),
            _MarketingStat(title: '스탬프 투어 완료율', value: '25%'),
            const Divider(height: 24),
            _MarketingStat(title: '누적 스포터 방문', value: '105명'),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _InfoCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(color: Colors.grey[700])),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _Segment({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 20, color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _MarketingStat extends StatelessWidget {
  final String title;
  final String value;
  const _MarketingStat({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: Colors.grey[700])),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}