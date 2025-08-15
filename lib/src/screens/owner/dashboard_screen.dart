// 📁 lib/src/screens/owner/dashboard_screen.dart (뒤로가기 버튼 제거 최종본)

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:spotter/models/user_model.dart';
import 'package:spotter/services/mode_prefs.dart';
import 'package:spotter/src/screens/app_decider.dart';
import 'package:spotter/src/screens/owner/trend_analysis_screen.dart';

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

  Map<String, DateTime> _getTodayRange() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return {'start': startOfDay, 'end': endOfDay};
  }

  @override
  Widget build(BuildContext context) {
    final todayRange = _getTodayRange();

    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('stores')
            .doc(storeId)
            .collection('visits')
            .where('timestamp', isGreaterThanOrEqualTo: todayRange['start'])
            .where('timestamp', isLessThan: todayRange['end'])
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasError) {
            return Scaffold(appBar: AppBar(title: const Text("오류")), body: Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다: ${snapshot.error}')));
          }

          final visitDocs = snapshot.data?.docs ?? [];
          final newVisitorsToday = visitDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            return data?['isFirstVisit'] == true;
          }).length;

          final totalVisitorsToday = visitDocs.length;
          final returningVisitorsToday = totalVisitorsToday - newVisitorsToday;
          final revisitRate = totalVisitorsToday == 0 ? 0.0 : (returningVisitorsToday / totalVisitorsToday) * 100;

          String returningChange = returningVisitorsToday > 0 ? "+$returningVisitorsToday" : "+0";
          Color returningChangeColor = returningVisitorsToday > 0 ? Colors.green : Colors.grey;
          String newChange = newVisitorsToday > 0 ? "+$newVisitorsToday" : "+0";
          Color newChangeColor = newVisitorsToday > 0 ? Colors.green : Colors.grey;
          String revisitChange = revisitRate > 0 ? "+${revisitRate.toStringAsFixed(0)}%" : "+0%";
          Color revisitChangeColor = revisitRate > 0 ? Colors.green : Colors.grey;

          return Scaffold(
            appBar: AppBar(
              // 🔥🔥🔥 --- 바로 이 부분입니다, 형님! --- 🔥🔥🔥
              automaticallyImplyLeading: false, // 뒤로가기 버튼을 제거합니다.
              title: const Text('사장님 대시보드'),    // 제목을 고정합니다.
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
                    value: '$returningVisitorsToday',
                    unit: '명',
                    change: returningChange,
                    changeColor: returningChangeColor,
                  ),
                  const SizedBox(height: 12),
                  _StatusCard(
                    title: '오늘 신규 고객',
                    value: '$newVisitorsToday',
                    unit: '명',
                    change: newChange,
                    changeColor: newChangeColor,
                  ),
                  const SizedBox(height: 12),
                  _StatusCard(
                    title: '실시간 재방문율',
                    value: revisitRate.toStringAsFixed(0),
                    unit: '%',
                    change: revisitChange,
                    changeColor: revisitChangeColor,
                  ),
                  const SizedBox(height: 12),
                  const _RemainingTimeCard(),

                  const SizedBox(height: 32),
                  _buildSectionTitle(
                      '트렌드 분석',
                      showDetails: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TrendAnalysisScreen(storeId: storeId)),
                        );
                      }
                  ),
                  const SizedBox(height: 16),
                  _buildChartCard(context, storeId),

                  const SizedBox(height: 32),
                  _buildSectionTitle('고객 세분화'),
                  const SizedBox(height: 16),
                  _buildCustomerSegmentCard(context, newVisitors: newVisitorsToday),

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

  Widget _buildSectionTitle(String title, {bool showDetails = false, VoidCallback? onTap}) {
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
          InkWell(
            onTap: onTap,
            child: Text('자세히', style: TextStyle(color: Colors.orange[700], fontSize: 14, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  Widget _buildChartCard(BuildContext context, String storeId) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

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
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('stores')
                  .doc(storeId)
                  .collection('visits')
                  .where('timestamp', isGreaterThanOrEqualTo: startOfWeekDate)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 150, child: Center(child: CircularProgressIndicator()));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return SizedBox(height: 150, child: _WeeklyVisitorChart(weeklyData: List.filled(7, 0)));
                }

                final visits = snapshot.data!.docs;
                final weeklyData = List.filled(7, 0);
                for (var visit in visits) {
                  final data = visit.data() as Map<String, dynamic>;
                  final timestamp = (data['timestamp'] as Timestamp).toDate();
                  weeklyData[timestamp.weekday - 1]++;
                }

                return SizedBox(height: 150, child: _WeeklyVisitorChart(weeklyData: weeklyData));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSegmentCard(BuildContext context, {required int newVisitors}) {
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
            _Segment(icon: Icons.diamond, color: Colors.red, label: 'VIP (주 3회+)', value: '0명'),
            const SizedBox(height: 16),
            _Segment(icon: Icons.star, color: Colors.orange, label: '일반 (주 1-2회)', value: '0명'),
            const SizedBox(height: 16),
            _Segment(icon: Icons.lightbulb, color: Colors.green, label: '신규 (첫 방문)', value: '$newVisitors명'),
            const Divider(height: 28),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('충성고객 이탈 위험', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('0명', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
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
            _MarketingStat(title: '리워드 후 재방문율', value: '+0%', changeColor: Colors.grey),
            _MarketingStat(title: '이벤트 방문자 수', value: '0명'),
            _MarketingStat(title: '투어 완주자 수', value: '0명'),
            _MarketingStat(title: '누적 방문 수', value: '0회'),
          ],
        ),
      ),
    );
  }
}

class _RemainingTimeCard extends StatefulWidget {
  const _RemainingTimeCard();

  @override
  State<_RemainingTimeCard> createState() => _RemainingTimeCardState();
}

class _RemainingTimeCardState extends State<_RemainingTimeCard> {
  Timer? _timer;
  Duration _remainingTime = Duration.zero;
  final DateTime _expiryDate = DateTime.now().add(const Duration(days: 29, hours: 13, minutes: 45));

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _updateTime());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    if (mounted) {
      setState(() {
        _remainingTime = _expiryDate.difference(DateTime.now());
      });
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return "기간 만료";
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String days = duration.inDays.toString();
    String hours = twoDigits(duration.inHours.remainder(24));
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$days일 $hours시간 $minutes분 ${seconds}초";
  }

  @override
  Widget build(BuildContext context) {
    return _StatusCard(
      title: '잔여 시간',
      value: _formatDuration(_remainingTime),
      isPremium: false,
    );
  }
}

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
    this.isPremium = true,
  });

  @override
  Widget build(BuildContext context) {
    bool isTimeCard = title == '잔여 시간';

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
            Row(
              children: [
                Text(title, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                if (isTimeCard) ...[
                  const SizedBox(width: 8),
                  Text(
                    'BASIC',
                    style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ]
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                if (isTimeCard) ...[
                  Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ] else ... [
                  Text(change ?? '', style: TextStyle(color: changeColor ?? Colors.grey[600], fontSize: 16)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      if (unit != null) const SizedBox(width: 4),
                      if (unit != null) Text(unit!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
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

class _WeeklyVisitorChart extends StatelessWidget {
  final List<int> weeklyData;
  const _WeeklyVisitorChart({required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey
                );
                Widget text;
                switch (value.toInt()) {
                  case 0:
                    text = const Text('월', style: style);
                    break;
                  case 1:
                    text = const Text('화', style: style);
                    break;
                  case 2:
                    text = const Text('수', style: style);
                    break;
                  case 3:
                    text = const Text('목', style: style);
                    break;
                  case 4:
                    text = const Text('금', style: style);
                    break;
                  case 5:
                    text = const Text('토', style: style);
                    break;
                  case 6:
                    text = const Text('일', style: style);
                    break;
                  default:
                    text = const Text('', style: style);
                    break;
                }

                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: text,
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: weeklyData.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.toDouble());
            }).toList(),
            isCurved: true,
            color: Colors.orange,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.orange.withOpacity(0.3),
                  Colors.orange.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}