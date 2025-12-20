import 'package:flutter/material.dart';

// Ozan Kaçmaz homescreen template
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildTodaySpendingCard(dailyLimit: 100, todaySpending: 100),
                const SizedBox(height: 24),
                _buildTotalBalanceCard(totalBalance: 500, totalIncome: 800, totalExpenses: 300),
                const SizedBox(height: 24),
                _buildCategoryBreakdownCard(),
                const SizedBox(height: 24),
                _buildRecentTransactions(),
                const SizedBox(height: 24),
                _buildSpendingLocationCard(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _animationController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'BudgetSU',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Track your campus spending',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySpendingCard({
    required double todaySpending,
    required double dailyLimit,
  }) {
    final double progress = (dailyLimit > 0) ? todaySpending / dailyLimit : 0.0;
    final double remaining = dailyLimit - todaySpending;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      )),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Today's Spending",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${todaySpending.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      '/ \$${dailyLimit.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '\$${remaining.toStringAsFixed(2)} remaining today',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildTotalBalanceCard({required double totalBalance, required double totalIncome, required double totalExpenses,}) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9333EA), Color(0xFFA855F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9333EA).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Balance',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '1927.95',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 1,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Income',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          Icon(
                            Icons.trending_up,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '\$2000.00',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Expenses',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          Icon(
                            Icons.trending_down,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '\$72.05',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdownCard() { //Categorical expenses card
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Categorical Expenses',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: CustomPaint(
                size: const Size(double.infinity, 250),
                painter: BarChartPainter(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    final transactions = [
      {
        'title': 'Scholarship Payment',
        'category': 'Other',
        'amount': '+\$2000.00',
        'isIncome': true,
        'location': '',
      },
      {
        'title': 'Campus Cafeteria',
        'category': 'Food',
        'amount': '-\$12.50',
        'isIncome': false,
        'location': 'On-Campus',
      },
      {
        'title': 'Bus Ticket',
        'category': 'Transport',
        'amount': '-\$2.75',
        'isIncome': false,
        'location': 'Off-Campus',
      },
      {
        'title': 'Library Printing',
        'category': 'Study',
        'amount': '-\$5.00',
        'isIncome': false,
        'location': 'On-Campus',
      },
      {
        'title': 'Coffee Shop',
        'category': 'Food',
        'amount': '-\$6.80',
        'isIncome': false,
        'location': 'Off-Campus',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Recent Transactions',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey.withOpacity(0.2),
            ),
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction['title'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                transaction['category'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if ((transaction['location'] as String).isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '•',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (transaction['location'] as String) == 'On-Campus'
                                        ? const Color(0xFFEFF6FF)
                                        : const Color(0xFFFAF5FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    transaction['location'] as String,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: (transaction['location'] as String) == 'On-Campus'
                                          ? const Color(0xFF2563EB)
                                          : const Color(0xFF9333EA),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      transaction['amount'] as String,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: (transaction['isIncome'] as bool)
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpendingLocationCard() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      )),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Spending Location',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildLocationItem(
                      icon: Icons.business,
                      iconColor: const Color(0xFF2563EB),
                      backgroundColor: const Color(0xFFEFF6FF),
                      label: 'On-Campus',
                      amount: '\$62.50',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildLocationItem(
                      icon: Icons.location_on,
                      iconColor: const Color(0xFF9333EA),
                      backgroundColor: const Color(0xFFFAF5FF),
                      label: 'Off-Campus',
                      amount: '\$9.55',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 200,
                child: CustomPaint(
                  size: const Size(double.infinity, 200),
                  painter: DonutChartPainter(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationItem({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String label,
    required String amount,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
class DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.height / 2.5;
    final strokeWidth = 35.0;

    final paint1 = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final paint2 = Paint()
      ..color = const Color(0xFF9333EA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // On-Campus (87%)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.57,
      2 * 3.14159 * 0.87,
      false,
      paint1,
    );

    // Off-Campus (13%)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.57 + (2 * 3.14159 * 0.87),
      2 * 3.14159 * 0.13,
      false,
      paint2,
    );

    // Labels
    final textPainter1 = TextPainter(
      text: const TextSpan(
        text: 'On-Campus 87%',
        style: TextStyle(
          color: Color(0xFF2563EB),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter1.layout();
    textPainter1.paint(
      canvas,
      Offset(center.dx - radius - 80, center.dy - radius + 20),
    );

    final textPainter2 = TextPainter(
      text: const TextSpan(
        text: 'Off-Campus',
        style: TextStyle(
          color: Color(0xFF9333EA),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter2.layout();
    textPainter2.paint(
      canvas,
      Offset(center.dx + radius - 20, center.dy + radius - 30),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Background bars (limits)
    final limitPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.fill;

    // Bar dimensions
    final barWidth = 40.0;
    final spacing = size.width / 3;
    final baseY = size.height - 30;

    // Draw limit bars (background)
    // Transport limit
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(spacing - barWidth / 2, baseY - 200, barWidth, 200),
        const Radius.circular(8),
      ),
      limitPaint,
    );

    // Entertainment limit
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(spacing * 2 - barWidth / 2, baseY - 140, barWidth, 140),
        const Radius.circular(8),
      ),
      limitPaint,
    );

    // Draw spent bars (foreground)
    paint.color = const Color(0xFF2563EB);

    // Transport spent
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(spacing - barWidth / 2, baseY - 50, barWidth, 50),
        const Radius.circular(8),
      ),
      paint,
    );

    // Entertainment spent
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(spacing * 2 - barWidth / 2, baseY - 35, barWidth, 35),
        const Radius.circular(8),
      ),
      paint,
    );

    // Draw labels
    final textPainter1 = TextPainter(
      text: const TextSpan(
        text: 'Transport',
        style: TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter1.layout();
    textPainter1.paint(
      canvas,
      Offset(spacing - textPainter1.width / 2, baseY + 10),
    );

    final textPainter2 = TextPainter(
      text: const TextSpan(
        text: 'Entertainment',
        style: TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter2.layout();
    textPainter2.paint(
      canvas,
      Offset(spacing * 2 - textPainter2.width / 2, baseY + 10),
    );

    // Draw legend
    final limitRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(20, 20, 12, 12),
      const Radius.circular(3),
    );
    canvas.drawRRect(limitRect, limitPaint);

    final limitTextPainter = TextPainter(
      text: const TextSpan(
        text: 'Limit',
        style: TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    limitTextPainter.layout();
    limitTextPainter.paint(canvas, const Offset(40, 16));

    final spentRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(100, 20, 12, 12),
      const Radius.circular(3),
    );
    canvas.drawRRect(spentRect, paint);

    final spentTextPainter = TextPainter(
      text: const TextSpan(
        text: 'Spent',
        style: TextStyle(
          color: Color(0xFF2563EB),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    spentTextPainter.layout();
    spentTextPainter.paint(canvas, const Offset(120, 16));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

}