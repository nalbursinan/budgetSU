import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goals_provider.dart';
import '../models/goal_model.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({Key? key}) : super(key: key);

  void _showCompletedGoals(BuildContext context, List<GoalModel> completedGoals) {
    if (completedGoals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No completed goals yet')),
      );
      return;
    }

    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Completed Goals',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              ...completedGoals.map(
                (g) => ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(
                    g.title,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                  subtitle: Text(
                    '\$${g.current.toStringAsFixed(2)} / \$${g.target.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    String? targetError;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            final theme = Theme.of(context);
            return AlertDialog(
              backgroundColor: theme.cardColor,
              title: Text(
                'Add Goal',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Goal name',
                      labelStyle: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: targetController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      setStateDialog(() {
                        if (value.isEmpty) {
                          targetError = null;
                        } else if (double.tryParse(value) == null) {
                          targetError = 'Invalid input error';
                        } else {
                          targetError = null;
                        }
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Target amount',
                      labelStyle: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                  if (targetError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        targetError!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final targetStr = targetController.text.trim();

                    if (title.isEmpty || targetStr.isEmpty) {
                      setStateDialog(() {
                        targetError = 'Please fill all fields';
                      });
                      return;
                    }

                    final target = double.tryParse(targetStr);
                    if (target == null || target <= 0) {
                      setStateDialog(() {
                        targetError = 'Invalid target amount';
                      });
                      return;
                    }

                    final goalsProvider = context.read<GoalsProvider>();
                    final success = await goalsProvider.addGoal(
                      title: title,
                      target: target,
                    );

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Goal added successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(goalsProvider.errorMessage ?? 'Failed to add goal'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddProgressDialog(BuildContext context, GoalModel goal) {
    final progressController = TextEditingController();
    String? progressError;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            final theme = Theme.of(context);
            return AlertDialog(
              backgroundColor: theme.cardColor,
              title: Text(
                'Add Progress to "${goal.title}"',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Current: \$${goal.current.toStringAsFixed(2)} / \$${goal.target.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: progressController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      setStateDialog(() {
                        if (value.isEmpty) {
                          progressError = null;
                        } else if (double.tryParse(value) == null) {
                          progressError = 'Invalid input error';
                        } else {
                          progressError = null;
                        }
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Amount to add',
                      labelStyle: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                  if (progressError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        progressError!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final progressStr = progressController.text.trim();
                    if (progressStr.isEmpty) {
                      setStateDialog(() {
                        progressError = 'Please enter an amount';
                      });
                      return;
                    }

                    final amount = double.tryParse(progressStr);
                    if (amount == null || amount <= 0) {
                      setStateDialog(() {
                        progressError = 'Invalid amount';
                      });
                      return;
                    }

                    final goalsProvider = context.read<GoalsProvider>();
                    final success = await goalsProvider.addProgress(goal, amount);

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                      if (success) {
                        // Check if goal is now completed
                        final newCurrent = goal.current + amount;
                        if (newCurrent >= goal.target) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('🎉 Congratulations! You\'ve reached your goal: ${goal.title}'),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Progress added successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(goalsProvider.errorMessage ?? 'Failed to add progress'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteGoalDialog(BuildContext context, GoalModel goal) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text(
            'Delete Goal',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          content: Text(
            'Are you sure you want to delete "${goal.title}"?',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (goal.id == null) return;
                
                final goalsProvider = context.read<GoalsProvider>();
                final success = await goalsProvider.deleteGoal(goal.id!);

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Goal deleted' : 'Failed to delete goal'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalsProvider>(
      builder: (context, goalsProvider, child) {
        final activeGoals = goalsProvider.activeGoals;
        final completedGoals = goalsProvider.completedGoals;
        final activeCount = goalsProvider.activeCount;
        final completedCount = goalsProvider.completedCount;
        final achievementsCount = goalsProvider.achievementsCount;

        final theme = Theme.of(context);
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: goalsProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Analytics-style header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Goals",
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onBackground,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Track your savings targets",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () => _showAddGoalDialog(context),
                              borderRadius: BorderRadius.circular(20),
                              child: const CircleAvatar(
                                radius: 20,
                                backgroundColor: Color(0xFF6A4DBC),
                                child: Icon(Icons.add, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _SummaryCard(
                                icon: Icons.track_changes,
                                value: activeCount.toString(),
                                label: 'Active Goals',
                                onTap: null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SummaryCard(
                                icon: Icons.check_circle_outline,
                                value: completedCount.toString(),
                                label: 'Completed',
                                onTap: () => _showCompletedGoals(context, completedGoals),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SummaryCard(
                                icon: Icons.emoji_events_outlined,
                                value: achievementsCount.toString(),
                                label: 'Achievements',
                                onTap: null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Active Goals',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onBackground,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (activeGoals.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 8,
                                  color: Colors.black.withOpacity(0.05),
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              'No active goals yet.\nTap the + button to add your first goal.',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          )
                        else
                          Column(
                            children: activeGoals
                                .map(
                                  (goal) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _GoalCard(
                                      goal: goal,
                                      onAddProgress: () => _showAddProgressDialog(context, goal),
                                      onDelete: () => _showDeleteGoalDialog(context, goal),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        const SizedBox(height: 24),
                        Text(
                          'Achievements',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onBackground,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (achievementsCount == 0)
                          Container(
                            width: double.infinity,
                            height: 90,
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 8,
                                  color: Colors.black.withOpacity(0.05),
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                'No achievements yet.\nComplete goals to unlock achievements.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            width: double.infinity,
                            height: 90,
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 8,
                                  color: Colors.black.withOpacity(0.05),
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.emoji_events,
                                  color: Colors.orangeAccent,
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '$achievementsCount achievement(s) unlocked!',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final VoidCallback? onTap;

  const _SummaryCard({
    Key? key,
    required this.icon,
    required this.value,
    required this.label,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                blurRadius: 8,
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 22, color: const Color(0xFF6A4DBC)),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final GoalModel goal;
  final VoidCallback onAddProgress;
  final VoidCallback onDelete;

  const _GoalCard({
    Key? key,
    required this.goal,
    required this.onAddProgress,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = goal.progress;
    final remaining = goal.remaining;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: onAddProgress,
                    child: Text(
                      'Add Progress',
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(Icons.delete_outline, color: Colors.red[300], size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '\$${goal.current.toStringAsFixed(2)} / \$${goal.target.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: theme.brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[300],
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF6A4DBC)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(0)}% complete',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                remaining > 0
                    ? '\$${remaining.toStringAsFixed(2)} to go'
                    : 'Goal reached!',
                style: TextStyle(
                  fontSize: 12,
                  color: remaining > 0
                      ? theme.colorScheme.onSurface.withOpacity(0.7)
                      : Colors.green,
                  fontWeight:
                      remaining > 0 ? FontWeight.normal : FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
