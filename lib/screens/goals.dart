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

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Completed Goals',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...completedGoals.map(
                (g) => ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(g.title),
                  subtitle: Text(
                    '\$${g.current.toStringAsFixed(2)} / \$${g.target.toStringAsFixed(2)}',
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
            return AlertDialog(
              title: const Text('Add Goal'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Goal name'),
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
                    decoration:
                        const InputDecoration(labelText: 'Target amount'),
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
                  child: const Text('Cancel'),
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
            return AlertDialog(
              title: Text('Add Progress to "${goal.title}"'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Current: \$${goal.current.toStringAsFixed(2)} / \$${goal.target.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
                    decoration:
                        const InputDecoration(labelText: 'Amount to add'),
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
                  child: const Text('Cancel'),
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
        return AlertDialog(
          title: const Text('Delete Goal'),
          content: Text('Are you sure you want to delete "${goal.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
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

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
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
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Goals",
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Track your savings targets",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
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
                        const Text(
                          'Active Goals',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (activeGoals.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 8,
                                  color: Colors.black.withOpacity(0.05),
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Text(
                              'No active goals yet.\nTap the + button to add your first goal.',
                              style: TextStyle(fontSize: 14),
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
                        const Text(
                          'Achievements',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (achievementsCount == 0)
                          Container(
                            width: double.infinity,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.white,
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
                            child: const Center(
                              child: Text(
                                'No achievements yet.\nComplete goals to unlock achievements.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          )
                        else
                          Container(
                            width: double.infinity,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.white,
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
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white,
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
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
    final progress = goal.progress;
    final remaining = goal.remaining;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: onAddProgress,
                    child: const Text('Add Progress'),
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
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.grey[300],
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
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
              Text(
                remaining > 0
                    ? '\$${remaining.toStringAsFixed(2)} to go'
                    : 'Goal reached!',
                style: TextStyle(
                  fontSize: 12,
                  color: remaining > 0 ? Colors.grey[700] : Colors.green,
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
