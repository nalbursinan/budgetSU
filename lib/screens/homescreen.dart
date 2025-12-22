import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../models/transaction_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
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
    return Consumer2<TransactionProvider, SettingsProvider>(
      builder: (context, transactionProvider, settingsProvider, child) {
        final dailyLimit = settingsProvider.dailySpendingLimit;
        
        final theme = Theme.of(context);
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildTodaySpendingCard(
                      dailyLimit: dailyLimit,
                      todaySpending: transactionProvider.todaySpending,
                    ),
                    const SizedBox(height: 24),
                    _buildTotalBalanceCard(
                      totalBalance: transactionProvider.balance,
                      totalIncome: transactionProvider.totalIncome,
                      totalExpenses: transactionProvider.totalExpenses,
                    ),
                    const SizedBox(height: 24),
                    _buildCategoryBreakdownCard(transactionProvider.spendingByCategory),
                    const SizedBox(height: 24),
                    _buildRecentTransactions(transactionProvider.getRecentTransactions()),
                    const SizedBox(height: 24),
                    _buildSpendingLocationCard(
                      onCampusSpending: transactionProvider.onCampusSpending,
                      offCampusSpending: transactionProvider.offCampusSpending,
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    return FadeTransition(
      opacity: _animationController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BudgetSU',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Track your campus spending',
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
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
    final double progress = (dailyLimit > 0) ? (todaySpending / dailyLimit).clamp(0.0, 1.0) : 0.0;
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
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 1.0 ? Colors.red[300]! : Colors.white,
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                remaining >= 0 
                    ? '\$${remaining.toStringAsFixed(2)} remaining today'
                    : '\$${(-remaining).toStringAsFixed(2)} over budget!',
                style: TextStyle(
                  color: remaining >= 0 ? Colors.white : Colors.red[200],
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

  Widget _buildTotalBalanceCard({
    required double totalBalance,
    required double totalIncome,
    required double totalExpenses,
  }) {
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
            Text(
              '\$${totalBalance.toStringAsFixed(2)}',
              style: const TextStyle(
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
                        children: [
                          const Icon(
                            Icons.trending_up,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '\$${totalIncome.toStringAsFixed(2)}',
                            style: const TextStyle(
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
                        children: [
                          const Icon(
                            Icons.trending_down,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '\$${totalExpenses.toStringAsFixed(2)}',
                            style: const TextStyle(
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

  Widget _buildCategoryBreakdownCard(Map<String, double> spendingByCategory) {
    final categories = spendingByCategory.entries.toList();
    categories.sort((a, b) => b.value.compareTo(a.value));
    final topCategories = categories.take(5).toList();
    final maxAmount = topCategories.isNotEmpty ? topCategories.first.value : 100.0;

    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
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
            Text(
              'Categorical Expenses',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            if (topCategories.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No expenses yet',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              )
            else
              ...topCategories.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '\$${entry.value.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: entry.value / maxAmount,
                        backgroundColor: theme.brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(List<TransactionModel> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Recent Transactions',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: transactions.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No transactions yet',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactions.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final isOnCampus = tx.campusLocation == 'On-Campus';
                    
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tx.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(
                                      tx.category,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (!tx.isIncome) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        '•',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
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
                                          color: isOnCampus
                                              ? (Theme.of(context).brightness == Brightness.dark
                                                  ? Colors.blue.withOpacity(0.2)
                                                  : const Color(0xFFEFF6FF))
                                              : (Theme.of(context).brightness == Brightness.dark
                                                  ? Colors.purple.withOpacity(0.2)
                                                  : const Color(0xFFFAF5FF)),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          tx.campusLocation,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isOnCampus
                                                ? Theme.of(context).brightness == Brightness.dark
                                                    ? Colors.blue[300]!
                                                    : const Color(0xFF2563EB)
                                                : Theme.of(context).brightness == Brightness.dark
                                                    ? Colors.purple[300]!
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
                            '${tx.isIncome ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: tx.isIncome
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

  Widget _buildSpendingLocationCard({
    required double onCampusSpending,
    required double offCampusSpending,
  }) {
    final total = onCampusSpending + offCampusSpending;
    final onCampusPercent = total > 0 ? (onCampusSpending / total * 100) : 50.0;
    final offCampusPercent = total > 0 ? (offCampusSpending / total * 100) : 50.0;

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
          color: Theme.of(context).cardColor,
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
              Text(
                'Spending Location',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildLocationItem(
                      icon: Icons.business,
                      iconColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.blue[400]!
                          : const Color(0xFF2563EB),
                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.blue.withOpacity(0.2)
                          : const Color(0xFFEFF6FF),
                      label: 'On-Campus',
                      amount: '\$${onCampusSpending.toStringAsFixed(2)}',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildLocationItem(
                      icon: Icons.location_on,
                      iconColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.purple[400]!
                          : const Color(0xFF9333EA),
                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.purple.withOpacity(0.2)
                          : const Color(0xFFFAF5FF),
                      label: 'Off-Campus',
                      amount: '\$${offCampusSpending.toStringAsFixed(2)}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 200,
                child: CustomPaint(
                  size: const Size(double.infinity, 200),
                  painter: DonutChartPainter(
                    onCampusPercent: onCampusPercent,
                    offCampusPercent: offCampusPercent,
                  ),
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
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final double onCampusPercent;
  final double offCampusPercent;

  DonutChartPainter({
    required this.onCampusPercent,
    required this.offCampusPercent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.height / 2.5;
    const strokeWidth = 35.0;

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

    final onCampusSweep = 2 * 3.14159 * (onCampusPercent / 100);
    final offCampusSweep = 2 * 3.14159 * (offCampusPercent / 100);

    // On-Campus arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.57,
      onCampusSweep,
      false,
      paint1,
    );

    // Off-Campus arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.57 + onCampusSweep,
      offCampusSweep,
      false,
      paint2,
    );

    // Labels
    final textPainter1 = TextPainter(
      text: TextSpan(
        text: 'On-Campus ${onCampusPercent.toStringAsFixed(0)}%',
        style: const TextStyle(
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
      text: TextSpan(
        text: 'Off-Campus ${offCampusPercent.toStringAsFixed(0)}%',
        style: const TextStyle(
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
      Offset(center.dx + radius - 40, center.dy + radius - 30),
    );
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return oldDelegate.onCampusPercent != onCampusPercent ||
           oldDelegate.offCampusPercent != offCampusPercent;
  }
}
