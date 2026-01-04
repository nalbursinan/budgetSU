import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/goals_provider.dart';
import '../services/firestore_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final theme = Theme.of(context);
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Analytics-style header
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Settings",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Manage your preferences and account",
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Profile Section
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final user = authProvider.user;
                    final email = user?.email ?? 'User';
                    final initials = email.isNotEmpty 
                        ? email.substring(0, 2).toUpperCase() 
                        : 'U';
                    
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[600]!, Colors.blue[400]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.white,
                              child: Text(
                                initials,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.displayName ?? 'BudgetSU User',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  email,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Student',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // Edit profile action
                            },
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Spending Limits Section
                Text(
                  'Spending Limits',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSpendingLimitCardWithStream(context, settingsProvider),

                const SizedBox(height: 24),

                // Appearance Section
                Text(
                  'Appearance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 12),
                _buildAppearanceCard(context, settingsProvider),

                const SizedBox(height: 24),

                // Notifications Section
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 12),
                _buildNotificationsCard(context, settingsProvider),

                const SizedBox(height: 24),

                // About Section
                Text(
                  'About',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 12),
                _buildAboutCard(context),

                const SizedBox(height: 16),

                // Links Section
                _buildLinksCard(context),

                const SizedBox(height: 24),

                // Logout Section
                Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 12),
                _buildLogoutCard(context),

                const SizedBox(height: 32),

                // Version Info
                Center(
                  child: Text(
                    'Made with ❤️ for students',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    '© 2025 BudgetSU',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpendingLimitCardWithStream(BuildContext context, SettingsProvider settingsProvider) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.uid;
    
    if (userId == null) {
      return _buildSpendingLimitCard(context, settingsProvider);
    }
    
    final firestoreService = FirestoreService();
    
    return StreamBuilder(
      stream: firestoreService.getUserSettingsStream(userId),
      builder: (context, snapshot) {
        final currentLimit = snapshot.hasData 
            ? snapshot.data!.dailySpendingLimit 
            : settingsProvider.dailySpendingLimit;
            
        return _buildSpendingLimitCard(context, settingsProvider, currentLimit: currentLimit);
      },
    );
  }

  Widget _buildSpendingLimitCard(BuildContext context, SettingsProvider settingsProvider, {double? currentLimit}) {
    final theme = Theme.of(context);
    final displayLimit = currentLimit ?? settingsProvider.dailySpendingLimit;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Spending Limit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '\$${displayLimit.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Colors.blue[600],
              inactiveTrackColor: Colors.blue[100],
              thumbColor: Colors.blue[700],
              overlayColor: Colors.blue[100],
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 10,
              ),
            ),
            child: Slider(
              value: displayLimit,
              min: 10,
              max: 200,
              divisions: 38,
              label: '\$${displayLimit.toStringAsFixed(0)}',
              onChanged: (value) {
                // Update locally for smooth slider movement
                settingsProvider.updateDailySpendingLimit(value);
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$10',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Text(
                '\$200',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Set a daily spending limit to help control your expenses and stay within budget',
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceCard(BuildContext context, SettingsProvider settingsProvider) {
    final theme = Theme.of(context);
    final isDarkMode = settingsProvider.themeMode == ThemeMode.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildSwitchTile(
        context,
        'Dark Mode',
        'Switch between light and dark theme',
        isDarkMode ? Icons.dark_mode : Icons.light_mode,
        isDarkMode,
        (value) {
          settingsProvider.toggleThemeMode();
        },
        isFirst: true,
        isLast: true,
      ),
    );
  }

  Widget _buildNotificationsCard(BuildContext context, SettingsProvider settingsProvider) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            context,
            'Budget Alerts',
            'Get notified when you\'re close to your budget limit',
            Icons.notifications_active_outlined,
            settingsProvider.budgetAlerts,
            (value) {
              settingsProvider.updateNotificationSettings(budgetAlerts: value);
            },
            isFirst: true,
          ),
          const Divider(height: 1),
          _buildSwitchTile(
            context,
            'Daily Summary',
            'Receive a daily summary of your spending',
            Icons.today_outlined,
            settingsProvider.dailySummary,
            (value) {
              settingsProvider.updateNotificationSettings(dailySummary: value);
            },
          ),
          const Divider(height: 1),
          _buildSwitchTile(
            context,
            'Goal Reminders',
            'Reminders to help you reach your savings goals',
            Icons.flag_outlined,
            settingsProvider.goalReminders,
            (value) {
              settingsProvider.updateNotificationSettings(goalReminders: value);
            },
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[400]!, Colors.blue[600]!],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BudgetSU',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Track your expenses, set budgets, and achieve your financial goals. Built for students to manage their finances effectively.',
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinksCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildListTile(
            context,
            'Privacy Policy',
            Icons.privacy_tip_outlined,
            () => _showPrivacyPolicy(context),
            isFirst: true,
          ),
          const Divider(height: 1),
          _buildListTile(
            context,
            'Terms of Service',
            Icons.description_outlined,
            () => _showTermsOfService(context),
          ),
          const Divider(height: 1),
          _buildListTile(
            context,
            'Help & Support',
            Icons.help_outline,
            () => _showHelpSupport(context),
          ),
          const Divider(height: 1),
          _buildListTile(
            context,
            'Rate This App',
            Icons.star_outline,
            () => _showRateApp(context),
            isLast: true,
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.privacy_tip, color: Colors.blue[600], size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            'BudgetSU Privacy Policy\n\n'
            'Last Updated: January 2025\n\n'
            '1. Data Collection\n'
            'We collect only the information necessary to provide our services:\n'
            '• Email address for account creation\n'
            '• Transaction data you enter\n'
            '• App preferences and settings\n\n'
            '2. Data Storage\n'
            'Your data is securely stored in Firebase and is only accessible by you. '
            'We do not share your personal information with third parties.\n\n'
            '3. Data Security\n'
            'We use industry-standard encryption to protect your data. '
            'All transactions are stored securely in Firebase Firestore.\n\n'
            '4. Your Rights\n'
            'You can delete your account and all associated data at any time through the app settings.\n\n'
            '5. Contact\n'
            'For privacy concerns, please contact us through the Help & Support section.',
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.description, color: Colors.blue[600], size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Terms of Service',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            'BudgetSU Terms of Service\n\n'
            'Last Updated: January 2025\n\n'
            '1. Acceptance of Terms\n'
            'By using BudgetSU, you agree to these terms and conditions.\n\n'
            '2. Use of Service\n'
            '• You must be at least 13 years old to use this app\n'
            '• You are responsible for maintaining the security of your account\n'
            '• You agree not to misuse the app or attempt to access other users\' data\n\n'
            '3. User Content\n'
            'You retain ownership of all data you enter. By using the app, you grant us '
            'permission to store and process your data to provide the service.\n\n'
            '4. Limitation of Liability\n'
            'BudgetSU is provided "as is" without warranties. We are not responsible '
            'for any financial decisions made based on the app\'s information.\n\n'
            '5. Changes to Terms\n'
            'We reserve the right to modify these terms at any time. '
            'Continued use constitutes acceptance of changes.',
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpSupport(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.help_outline, color: Colors.blue[600], size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Help & Support',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Frequently Asked Questions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildFAQItem(
                dialogContext,
                'How do I add a transaction?',
                'Tap the + button on the Transactions screen and fill in the details.',
              ),
              const SizedBox(height: 12),
              _buildFAQItem(
                dialogContext,
                'How do I set a daily spending limit?',
                'Go to Settings > Spending Limits and adjust the slider.',
              ),
              const SizedBox(height: 12),
              _buildFAQItem(
                dialogContext,
                'Can I edit or delete transactions?',
                'Yes! Tap on any transaction to edit it, or swipe left to delete.',
              ),
              const SizedBox(height: 12),
              _buildFAQItem(
                dialogContext,
                'How do I change my theme?',
                'Go to Settings > Appearance and toggle Dark Mode.',
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Need More Help?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'If you need additional assistance, please contact our support team at:\n'
                'support@budgetsu.app',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          answer,
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  void _showRateApp(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.star, color: Colors.amber[600], size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Rate BudgetSU',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'We hope you\'re enjoying BudgetSU!',
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Icon(
                  Icons.star,
                  color: Colors.amber[400],
                  size: 32,
                );
              }),
            ),
            const SizedBox(height: 16),
            Text(
              'Your feedback helps us improve the app. '
              'Thank you for using BudgetSU!',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you for your feedback!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Rate Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showLogoutDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.logout,
                  color: Colors.red[700],
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? Colors.blue.withValues(alpha: 0.2)
                  : Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: theme.brightness == Brightness.dark
                  ? Colors.blue[300]
                  : Colors.blue[700],
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.brightness == Brightness.dark
                ? Colors.blue[400]
                : Colors.blue[700],
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(12) : Radius.zero,
        bottom: isLast ? const Radius.circular(12) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? Colors.blue.withValues(alpha: 0.2)
                    : Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: theme.brightness == Brightness.dark
                    ? Colors.blue[300]
                    : Colors.blue[700],
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out of your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthProvider>().signOut();
              context.read<SettingsProvider>().clearData();
              context.read<TransactionProvider>().clearData();
              context.read<GoalsProvider>().clearData();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

