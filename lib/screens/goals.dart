import 'package:flutter/material.dart';

class Goal {
  String title;
  double current;
  double target;

  Goal({
    required this.title,
    required this.current,
    required this.target,
  });

  bool get isCompleted => current >= target;
}

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({Key? key}) : super(key: key);

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final List<Goal> _goals = [];

  void _showCompletedGoals(List<Goal> completedGoals) {
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
            children: completedGoals
                .map(
                  (g) => ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: Text(g.title),
                    subtitle: Text(
                      '\$${g.current.toStringAsFixed(2)} / \$${g.target.toStringAsFixed(2)}',
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  void _showAddGoalDialog() {
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    String? targetError;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final targetStr = targetController.text.trim();

                    if (title.isEmpty || targetStr.isEmpty) {
                      setStateDialog(() {
                        targetError = 'Invalid input error';
                      });
                      return;
                    }

                    final target = double.tryParse(targetStr);
                    if (target == null) {
                      setStateDialog(() {
                        targetError = 'Invalid input error';
                      });
                      return;
                    }

                    setState(() {
                      _goals
                          .add(Goal(title: title, current: 0, target: target));
                    });

                    Navigator.pop(context);
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

  void _showAddProgressDialog(Goal goal) {
    final progressController = TextEditingController();
    String? progressError;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Add Progress to "${goal.title}"'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final progressStr = progressController.text.trim();
                    if (progressStr.isEmpty) {
                      setStateDialog(() {
                        progressError = 'Invalid input error';
                      });
                      return;
                    }

                    final amount = double.tryParse(progressStr);
                    if (amount == null) {
                      setStateDialog(() {
                        progressError = 'Invalid input error';
                      });
                      return;
                    }

                    setState(() {
                      goal.current += amount;
                    });

                    Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    final activeGoals = _goals.where((g) => !g.isCompleted).toList();
    final completedGoals = _goals.where((g) => g.isCompleted).toList();
    final activeCount = activeGoals.length;
    final completedCount = completedGoals.length;
    final achievementsCount = completedGoals.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF3EFFF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Goals',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B228A),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Track your savings targets',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7A6AB5),
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: _showAddGoalDialog,
                  borderRadius: BorderRadius.circular(20),
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFF6A4DBC),
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
                    onTap: () => _showCompletedGoals(completedGoals),
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
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3B228A),
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
                          onAddProgress: () => _showAddProgressDialog(goal),
                        ),
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 24),
            const Text(
              'Achievements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3B228A),
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
  final Goal goal;
  final VoidCallback onAddProgress;

  const _GoalCard({
    Key? key,
    required this.goal,
    required this.onAddProgress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = (goal.target == 0) ? 0.0 : goal.current / goal.target;
    final remaining = goal.target - goal.current;

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
              TextButton(
                onPressed: onAddProgress,
                child: const Text('Add Progress'),
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
              value: progress.clamp(0.0, 1.0),
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
                '${(progress * 100).clamp(0, 100).toStringAsFixed(0)}% complete',
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
