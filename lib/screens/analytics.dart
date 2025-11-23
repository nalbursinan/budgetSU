import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

//change the manuel data values after creating/connecting transaction page
import 'mainscreen.dart';
import 'transactions.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {

  String activeView = "daily"; // daily / hours / weekly


  String breakdownTab = "category"; // category / location

  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  // ---------------------- MOCK DATA ----------------------

  // daily expenses (7 days)
  final dailyData = <double>[
    20.0,
    12.0,
    32.0,
    18.0,
    25.0,
    10.0,
    30.0,
  ];


  final hourCategories = [
    {"label": "Morning", "value": 14.0, "color": const Color(0xFFF59E0B)},
    {"label": "Afternoon", "value": 25.0, "color": const Color(0xFF8B5CF6)},
    {"label": "Evening", "value": 32.0, "color": const Color(0xFF3B82F6)},
    {"label": "Night", "value": 10.0, "color": const Color(0xFF6B7280)},
  ];

  // weekly expense
  final weeklyData = <double>[
    50.0,
    42.0,
    61.0,
    30.0,
    80.0,
  ];

  // example for category
  final categoryData = [
    {"label": "Food", "value": 40.0},
    {"label": "Transport", "value": 25.0},
    {"label": "Study", "value": 15.0},
    {"label": "Fun", "value": 20.0},
  ];

  // lokasyon (örnek)
  final locationData = [
    {"label": "On-Campus", "value": 62.5},
    {"label": "Off-Campus", "value": 9.55},
  ];

  // ---------------------- BUILD ----------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeTransition(
                opacity: _anim,
                child: const Text(
                  "Analytics",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Deep insights into your spending",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 24),
              _buildToggleButtons(),

              const SizedBox(height: 24),
              if (activeView == "daily") _buildDailyView(),
              if (activeView == "hours") _buildHoursView(),
              if (activeView == "weekly") _buildWeeklyView(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------- MAIN TOGGLE (Daily / Hours / Weekly) ----------------------

  Widget _buildToggleButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          _toggleButton("Hours"),
          _toggleButton("Daily"),
          _toggleButton("Weekly"),
        ],
      ),
    );
  }

  Widget _toggleButton(String label) {
    final selected = activeView == label.toLowerCase();

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => activeView = label.toLowerCase()),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
              colors: [Color(0xFF9333EA), Color(0xFF3B82F6)],
            )
                : null,
            color: selected ? null : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------- DAILY VIEW ----------------------

  Widget _buildDailyView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _gradientCard(
          title: "Most Spent Day",
          value: "\$32.00",
          subtitle: "Friday",
          icon: Icons.show_chart,
          color1: const Color(0xFF9333EA),
          color2: const Color(0xFF3B82F6),
        ),
        const SizedBox(height: 24),
        _whiteCard(
          title: "Daily Spending (Last 7 Days)",
          child: SizedBox(
            height: 320,
            child: BarChart(
              BarChartData(
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                barGroups: List.generate(
                  dailyData.length,
                      (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: dailyData[i],
                        width: 18,
                        color: const Color(0xFF8B5CF6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------- HOURS VIEW ----------------------

  Widget _buildHoursView() {
    final double total =
    hourCategories.fold(0, (sum, e) => sum + (e["value"] as double));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _gradientCard(
          title: "Peak Spending Time",
          value: "\$32.00",
          subtitle: "Evening (17:00–21:00)",
          icon: Icons.access_time,
          color1: const Color(0xFFF59E0B),
          color2: const Color(0xFF3B82F6),
        ),
        const SizedBox(height: 24),
        _whiteCard(
          title: "Spending by Time of Day",
          child: SizedBox(
            height: 260,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 40,
                sectionsSpace: 3,
                sections: hourCategories.map((e) {
                  final double value = e["value"] as double;
                  final double percent = total > 0 ? value / total * 100 : 0;
                  return PieChartSectionData(
                    value: value,
                    color: e["color"] as Color,
                    title: "${percent.toStringAsFixed(0)}%",
                    radius: 60,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------- WEEKLY VIEW ----------------------

  Widget _buildWeeklyView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _gradientCard(
          title: "Weekly Overview",
          value: "\$48.00",
          subtitle: "Avg per week",
          icon: Icons.calendar_today,
          color1: const Color(0xFF2563EB),
          color2: const Color(0xFF3B82F6),
        ),
        const SizedBox(height: 24),

        // Weekly comparison bar chart
        _whiteCard(
          title: "Weekly Comparison",
          child: SizedBox(
            height: 320,
            child: BarChart(
              BarChartData(
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                barGroups: List.generate(
                  weeklyData.length,
                      (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: weeklyData[i],
                        width: 20,
                        color: const Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Spending trend (line chart)
        _buildSpendingTrendCard(),

        const SizedBox(height: 24),

        // By Category / By Location toggle
        _buildBreakdownToggle(),

        const SizedBox(height: 16),

        if (breakdownTab == "category")
          _buildCategoryBreakdownCard()
        else
          _buildLocationComparisonCard(),

        const SizedBox(height: 24),

        _buildInsightsCard(),
      ],
    );
  }

  // ---------------------- SPENDING TREND (LINE CHART) ----------------------

  Widget _buildSpendingTrendCard() {
    return _whiteCard(
      title: "Spending Trend",
      child: SizedBox(
        height: 320,
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: 6,
            minY: 0,
            maxY: 100,
            borderData: FlBorderData(show: true),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 20,
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
                    final index = value.toInt();
                    if (index < 0 || index >= days.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        days[index],
                        style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, interval: 20),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                spots: const [
                  FlSpot(0, 30),
                  FlSpot(1, 45),
                  FlSpot(2, 20),
                  FlSpot(3, 60),
                  FlSpot(4, 40),
                  FlSpot(5, 80),
                  FlSpot(6, 55),
                ],
                color: const Color(0xFF3B82F6),
                barWidth: 4,
                dotData: FlDotData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------- BREAKDOWN TOGGLE ----------------------

  Widget _buildBreakdownToggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _breakdownButton("By Category", "category"),
          _breakdownButton("By Location", "location"),
        ],
      ),
    );
  }

  Widget _breakdownButton(String label, String value) {
    final selected = breakdownTab == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => breakdownTab = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: selected
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected ? Colors.black87 : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------- CATEGORY BREAKDOWN ----------------------

  Widget _buildCategoryBreakdownCard() {
    final double total =
    categoryData.fold(0, (sum, e) => sum + (e["value"] as double));

    return _whiteCard(
      title: "Category Breakdown",
      child: Column(
        children: [
          SizedBox(
            height: 260,
            child: BarChart(
              BarChartData(
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= categoryData.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            categoryData[index]["label"] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black87,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(
                  categoryData.length,
                      (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: categoryData[i]["value"] as double,
                        width: 18,
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: categoryData.map((e) {
              final value = e["value"] as double;
              final percent = total > 0 ? value / total * 100 : 0;
              return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      e["label"] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${percent.toStringAsFixed(0)}%",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ---------------------- LOCATION COMPARISON ----------------------

  Widget _buildLocationComparisonCard() {
    final double total =
    locationData.fold(0, (sum, e) => sum + (e["value"] as double));
    final onCampus = locationData[0]["value"] as double;
    final offCampus = locationData[1]["value"] as double;

    return _whiteCard(
      title: "Location Comparison",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 260,
            child: BarChart(
              BarChartData(
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() == 0) {
                          return const Text(
                            "On-Campus",
                            style: TextStyle(fontSize: 11),
                          );
                        } else if (value.toInt() == 1) {
                          return const Text(
                            "Off-Campus",
                            style: TextStyle(fontSize: 11),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: onCampus,
                        width: 24,
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: offCampus,
                        width: 24,
                        color: const Color(0xFF9333EA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _locationRow(
            label: "On-Campus",
            value: onCampus,
            percent: total > 0 ? onCampus / total : 0,
            color: const Color(0xFF2563EB),
          ),
          const SizedBox(height: 8),
          _locationRow(
            label: "Off-Campus",
            value: offCampus,
            percent: total > 0 ? offCampus / total : 0,
            color: const Color(0xFF9333EA),
          ),
        ],
      ),
    );
  }

  Widget _locationRow({
    required String label,
    required double value,
    required double percent,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            Text(
              "${(percent * 100).toStringAsFixed(1)}%",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: percent.clamp(0, 1),
            minHeight: 6,
            backgroundColor: const Color(0xFFE5E7EB),
            color: color,
          ),
        ),
      ],
    );
  }

  // ---------------------- INSIGHTS CARD ----------------------

  Widget _buildInsightsCard() {
    final double avgPerDay = dailyData.isNotEmpty
        ? dailyData.reduce((a, b) => a + b) / dailyData.length
        : 0;


    final topCategory = categoryData.reduce(
          (a, b) =>
      (a["value"] as double) >= (b["value"] as double) ? a : b,
    );

    final double totalLocation =
    locationData.fold(0, (sum, e) => sum + (e["value"] as double));
    final double onCampusPercent = totalLocation > 0
        ? (locationData[0]["value"] as double) / totalLocation * 100
        : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Color(0xFFF59E0B)),
              SizedBox(width: 8),
              Text(
                "Insights",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "• You spend an average of \$${avgPerDay.toStringAsFixed(2)} per day",
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            "• Your highest spending category is ${topCategory["label"]}",
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            "• ${onCampusPercent.toStringAsFixed(1)}% of your expenses are on-campus",
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // ---------------------- COMMON CARD HELPERS ----------------------

  Widget _gradientCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color1,
    required Color color2,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color1, color2]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color1.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _whiteCard({
    required String title,
    required Widget child,
  }) {

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
