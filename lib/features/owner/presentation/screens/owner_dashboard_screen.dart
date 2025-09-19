// features/owner/presentation/screens/owner_dashboard_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// [추가] 일반 모드(MainScreen)로 돌아가기 위해 import
import 'package:spotter/features/main_navigation/presentation/screens/main_screen.dart';

class OwnerDashboardScreen extends StatelessWidget {
  final String storeId;
  const OwnerDashboardScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    final storeStream = FirebaseFirestore.instance.collection('store_applications').doc(storeId).snapshots();

    return StreamBuilder<DocumentSnapshot>(
      stream: storeStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text("데이터 로딩 오류: ${snapshot.error}")));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(body: Center(child: Text("가게 정보를 찾을 수 없습니다.")));
        }

        final storeData = snapshot.data!.data() as Map<String, dynamic>;

        return Scaffold(
          appBar: AppBar(
            title: const Text('사장님 대시보드', style: TextStyle(fontWeight: FontWeight.bold)),
            automaticallyImplyLeading: false,
            elevation: 1,
            actions: [
              // [수정] 설정 버튼 -> '일반 모드로 전환' 버튼으로 변경 및 기능 구현
              IconButton(
                tooltip: '일반 모드로 전환',
                icon: const Icon(Icons.exit_to_app),
                onPressed: () {
                  // 현재까지의 모든 화면을 스택에서 제거하고, MainScreen으로 이동합니다.
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                        (route) => false,
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildRealtimeStatusCard(context, storeData),
                const SizedBox(height: 24),
                _buildTrendAnalysisCard(context),
                const SizedBox(height: 24),
                _buildCustomerSegmentCard(context),
                const SizedBox(height: 24),
                _buildMarketingEffectCard(context),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- 이하 모든 UI 헬퍼 위젯들은 이전 최종본과 동일합니다 ---

  Widget _buildRealtimeStatusCard(BuildContext context, Map<String, dynamic> data) {
    final numberFormatter = NumberFormat.decimalPattern('ko');
    final currentVisitors = data['currentVisitors'] ?? 12;
    final currentVisitorsChange = data['currentVisitorsChange'] ?? 3;
    final newCustomers = data['newCustomersToday'] ?? 4;
    final newCustomersChange = data['newCustomersChange'] ?? 1;
    final revisitingCustomers = data['revisitingCustomersToday'] ?? 7;
    final revisitingCustomersChange = data['revisitingCustomersChange'] ?? 2;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, icon: Icons.access_time_filled, title: '실시간 현황'),
            const SizedBox(height: 20),
            _buildStatusRow('현재 방문자', '${numberFormatter.format(currentVisitors)}명', highlightText: '+${numberFormatter.format(currentVisitorsChange)}명', highlightColor: Colors.green),
            const Divider(height: 32),
            _buildStatusRow('오늘 신규 고객', '${numberFormatter.format(newCustomers)}명', highlightText: '+${numberFormatter.format(newCustomersChange)}명', highlightColor: Colors.green),
            const Divider(height: 32),
            _buildStatusRow('오늘 재방문객', '${numberFormatter.format(revisitingCustomers)}명', highlightText: '+${numberFormatter.format(revisitingCustomersChange)}명', highlightColor: Colors.green),
            const Divider(height: 32),
            _buildPlanStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanStatus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("Spotter 플랜", style: TextStyle(fontSize: 14, color: Colors.grey)),
        Row(
          children: [
            _buildTimeColumn("29", "일"),
            _buildTimeColumn("23", "시간"),
            _buildTimeColumn("59", "분"),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16)
              ),
              child: const Text('베이직', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTimeColumn(String time, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(time, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(width: 2),
          Text(unit, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String title, String value, {String? highlightText, Color? highlightColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            if (highlightText != null) ...[
              const SizedBox(width: 8),
              Text(highlightText, style: TextStyle(color: highlightColor ?? Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)),
            ]
          ],
        )
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, {required IconData icon, required String title, VoidCallback? onMoreTap}) {
    return Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Row(children: [ Icon(icon, color: Colors.orange, size: 20), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),],), if (onMoreTap != null) TextButton(onPressed: onMoreTap, child: const Text('자세히')),],);
  }

  Widget _buildTrendAnalysisCard(BuildContext context) {
    return Card( elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: Padding( padding: const EdgeInsets.all(20.0), child: Column(children: [ _buildSectionTitle(context, icon: Icons.trending_up, title: '트렌드 분석', onMoreTap: () {}), const SizedBox(height: 24), SizedBox(height: 150, child: LineChart(LineChartData(lineBarsData: [LineChartBarData(spots: const [ FlSpot(0, 3), FlSpot(1, 4), FlSpot(2, 3.5), FlSpot(3, 5), FlSpot(4, 4), FlSpot(5, 6), FlSpot(6, 5.5), ], isCurved: true, color: Colors.orange, barWidth: 4, isStrokeCapRound: true, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: true, color: Colors.orange.withOpacity(0.1)),), ], titlesData: FlTitlesData(bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: _bottomTitleWidgets)), leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),), gridData: const FlGridData(show: false), borderData: FlBorderData(show: false),),),),],),),);
  }

  static Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(color: Colors.grey, fontSize: 12);
    Widget text;
    switch (value.toInt()) { case 0: text = const Text('월', style: style); break; case 1: text = const Text('화', style: style); break; case 2: text = const Text('수', style: style); break; case 3: text = const Text('목', style: style); break; case 4: text = const Text('금', style: style); break; case 5: text = const Text('토', style: style); break; case 6: text = const Text('일', style: style); break; default: text = const Text('', style: style); break;}
    return SideTitleWidget(axisSide: meta.axisSide, child: text);
  }

  Widget _buildCustomerSegmentCard(BuildContext context) {
    return Card( elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: Padding( padding: const EdgeInsets.all(20.0), child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ _buildSectionTitle(context, icon: Icons.people, title: '고객 세분화'), const SizedBox(height: 16), _buildSegmentRow('❤️ VIP (주 3회+)', 15), _buildSegmentRow('⭐ 일반 (주 1-2회)', 48), _buildSegmentRow('👋 신규 (첫 방문)', 22), const Divider(height: 24), Row(children: [ Text('충성고객 이탈 위험: ', style: TextStyle(fontSize: 14, color: Colors.red.shade900)), const Text('3명', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),],)],),),);
  }

  Widget _buildSegmentRow(String title, int count) {
    return Padding( padding: const EdgeInsets.symmetric(vertical: 6.0), child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Text(title, style: const TextStyle(fontSize: 14)), Text('${NumberFormat.decimalPattern('ko').format(count)}명', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),],),);
  }

  Widget _buildMarketingEffectCard(BuildContext context) {
    return Card( elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: Padding( padding: const EdgeInsets.all(20.0), child: Column(children: [ _buildSectionTitle(context, icon: Icons.campaign, title: '마케팅 효과'), const SizedBox(height: 16), _buildEffectRow('리워드 후 재방문율', '+15%', Colors.green), _buildEffectRow('이벤트 방문자 수', '+40%', Colors.green), _buildEffectRow('투어 완주자 수', '5명', Colors.black), _buildEffectRow('누적 방문수', '1,234회', Colors.black),],),),);
  }

  Widget _buildEffectRow(String title, String value, Color valueColor) {
    return Padding( padding: const EdgeInsets.symmetric(vertical: 8.0), child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Text(title, style: const TextStyle(fontSize: 14)), Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: valueColor)),],),);
  }
}