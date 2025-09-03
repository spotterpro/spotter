// 📁 lib/src/screens/owner/trend_analysis_screen.dart (목업 데이터 완전 제거 최종본)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TrendAnalysisScreen extends StatefulWidget {
  final String storeId;
  const TrendAnalysisScreen({super.key, required this.storeId});

  @override
  State<TrendAnalysisScreen> createState() => _TrendAnalysisScreenState();
}

class _TrendAnalysisScreenState extends State<TrendAnalysisScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() => _selectedIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context)
        .textScaleFactor
        .clamp(1.0, 1.3)
        .toDouble();

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: scale),
      child: Scaffold(
        appBar: AppBar(title: const Text('트렌드 분석 상세')),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceVariant
                        .withOpacity(0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Theme.of(context).textTheme.bodyLarge?.color,
                    unselectedLabelColor: Colors.grey[600],
                    tabs: const [
                      Tab(text: '주간'),
                      Tab(text: '월간'),
                      Tab(text: '전체'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    _TrendDetailView(storeId: widget.storeId, range: 'week'),
                    _TrendDetailView(storeId: widget.storeId, range: 'month'),
                    _TrendDetailView(storeId: widget.storeId, range: 'all'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrendDetailView extends StatelessWidget {
  final String storeId;
  final String range;

  const _TrendDetailView({required this.storeId, required this.range});

  Query<Map<String, dynamic>> _buildQuery() {
    final now = DateTime.now();
    DateTime startDate;

    switch (range) {
      case 'week':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        startDate =
            DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'all':
      default:
        startDate = DateTime(2000);
        break;
    }

    return FirebaseFirestore.instance
        .collection('stores')
        .doc(storeId)
        .collection('visits')
        .where('timestamp', isGreaterThanOrEqualTo: startDate);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _buildQuery().snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('데이터 로딩 오류: ${snapshot.error}'));
        }

        final visits = snapshot.data?.docs ?? [];

        final totalVisitors = visits.length;
        final newVisitors = visits
            .where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['isFirstVisit'] == true;
        })
            .length;

        final returningVisitors = totalVisitors - newVisitors;
        final newVisitRate =
        totalVisitors == 0 ? 0.0 : (newVisitors / totalVisitors) * 100;
        final revisitRate =
        totalVisitors == 0 ? 0.0 : (returningVisitors / totalVisitors) * 100;

        final dailyData = List<double>.filled(7, 0.0);
        if (range == 'week') {
          for (var doc in visits) {
            final data = doc.data() as Map<String, dynamic>;
            final ts = (data['timestamp'] as Timestamp).toDate();
            final idx = ts.weekday - 1;
            if (idx >= 0 && idx < 7) dailyData[idx] += 1.0;
          }
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final crossAxisCount = w < 360 ? 1 : (w < 600 ? 2 : 3);
            final cardAspect =
            crossAxisCount == 1 ? 3.6 : (crossAxisCount == 2 ? 1.8 : 1.6);

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: cardAspect,
                    ),
                    itemCount: 4,
                    itemBuilder: (_, i) {
                      switch (i) {
                        case 0:
                          return _StatCard(
                            title: '총 방문자',
                            value: '$totalVisitors',
                            change: '+0',
                            changeColor: Colors.grey,
                          );
                        case 1:
                          return _StatCard(
                            title: '신규 방문율',
                            value: '${newVisitRate.toStringAsFixed(0)}%',
                            change: '+0%p',
                            changeColor: Colors.grey,
                          );
                        case 2:
                          return _StatCard(
                            title: '재방문율',
                            value: '${revisitRate.toStringAsFixed(0)}%',
                            change: '+0%p',
                            changeColor: Colors.grey,
                          );
                        default:
                          return const _StatCard(
                            title: '리워드 달성률',
                            value: '0%',
                            change: '+0%p',
                            changeColor: Colors.grey,
                          );
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  if (range == 'week')
                    _ChartContainer(
                      title: '요일별 방문자 분포',
                      chart: _buildLineChart(dailyData),
                    ),
                  const SizedBox(height: 24),
                  _ChartContainer(
                    title: '고객 세분화',
                    chart: _buildCustomerSegmentChart(context, vip: 0, regular: 0, fresh: newVisitors),
                    legend: _buildSegmentLegend(context, vip: 0, regular: 0, fresh: newVisitors, risky: 0),
                  ),
                  const SizedBox(height: 24),
                  const _ChartContainer(
                    title: '마케팅 효과',
                    legend: _MarketingLegend(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLineChart(List<double> dailyData) {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  const style = TextStyle(color: Colors.grey, fontSize: 12);
                  Widget text;
                  switch (value.toInt()) {
                    case 0: text = const Text('월', style: style); break;
                    case 1: text = const Text('화', style: style); break;
                    case 2: text = const Text('수', style: style); break;
                    case 3: text = const Text('목', style: style); break;
                    case 4: text = const Text('금', style: style); break;
                    case 5: text = const Text('토', style: style); break;
                    case 6: text = const Text('일', style: style); break;
                    default: text = const Text('', style: style); break;
                  }
                  return SideTitleWidget(
                      axisSide: meta.axisSide, child: text);
                },
              ),
            ),
            leftTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: dailyData
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
              isCurved: true,
              color: Colors.orange,
              barWidth: 3.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withOpacity(0.28),
                    Colors.orange.withOpacity(0.0)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          minX: 0,
          maxX: 6,
        ),
      ),
    );
  }

  Widget _buildCustomerSegmentChart(BuildContext context, {required int vip, required int regular, required int fresh}) {
    final double total = (vip + regular + fresh).toDouble();
    return SizedBox(
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: '총\n', style: TextStyle(color: Colors.grey)),
                TextSpan(
                  text: '${total.toInt()}',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          PieChart(
            PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: 68,
              startDegreeOffset: -90,
              sections: (total > 0)
                  ? [
                PieChartSectionData(
                  color: Colors.red,
                  value: vip.toDouble(),
                  title: '',
                  radius: 26,
                ),
                PieChartSectionData(
                  color: Colors.orange,
                  value: regular.toDouble(),
                  title: '',
                  radius: 26,
                ),
                PieChartSectionData(
                  color: Colors.green,
                  value: fresh.toDouble(),
                  title: '',
                  radius: 26,
                ),
              ]
                  : [
                PieChartSectionData(
                  color: Colors.grey.withOpacity(0.2),
                  value: 1.0,
                  title: '',
                  radius: 26,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentLegend(BuildContext context, {required int vip, required int regular, required int fresh, required int risky}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(color: Colors.red, text: 'VIP', value: '$vip명'),
            const SizedBox(width: 16),
            _LegendItem(color: Colors.orange, text: '일반', value: '$regular명'),
            const SizedBox(width: 16),
            _LegendItem(color: Colors.green, text: '신규', value: '$fresh명'),
          ],
        ),
        const Divider(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('충성고객 이탈 위험', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('$risky명', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
          ],
        )
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? change;
  final Color changeColor;

  const _StatCard({
    required this.title,
    required this.value,
    this.change,
    this.changeColor = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle =
    Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]);
    const valueStyle = TextStyle(fontSize: 22, fontWeight: FontWeight.bold);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: titleStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: valueStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
              if (change != null) ...[
                const SizedBox(width: 8),
                Text(change!, style: TextStyle(color: changeColor)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartContainer extends StatelessWidget {
  final String title;
  final Widget? chart;
  final Widget? legend;
  const _ChartContainer({required this.title, this.chart, this.legend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          if (chart != null) const SizedBox(height: 16),
          if (chart != null) chart!,
          if (legend != null) const SizedBox(height: 16),
          if (legend != null) legend!,
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  final String value;

  const _LegendItem(
      {required this.color, required this.text, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _MarketingLegend extends StatelessWidget {
  const _MarketingLegend();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MarketingStat(title: '리워드 후 재방문율', value: '+0%', changeColor: Colors.grey),
        _MarketingStat(title: '이벤트 방문자 수', value: '0명'),
        _MarketingStat(title: '투어 완주자 수', value: '0명'),
        _MarketingStat(title: '누적 방문 수', value: '0회'),
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