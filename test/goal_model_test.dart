import 'package:flutter_test/flutter_test.dart';
import 'package:budget_su/models/goal_model.dart';

void main() {
  group('GoalModel', () {
    test('isCompleted and progress should calculate correctly', () {
      final completedGoal = GoalModel(
        title: 'Test Goal',
        current: 100.0,
        target: 100.0,
        createdBy: 'user1',
      );
      expect(completedGoal.isCompleted, true);
      expect(completedGoal.progress, 1.0);

      final incompleteGoal = GoalModel(
        title: 'Test Goal',
        current: 50.0,
        target: 100.0,
        createdBy: 'user1',
      );
      expect(incompleteGoal.isCompleted, false);
      expect(incompleteGoal.progress, 0.5);
    });

    test('remaining should calculate correctly and not be negative', () {
      final goal = GoalModel(
        title: 'Test Goal',
        current: 30.0,
        target: 100.0,
        createdBy: 'user1',
      );
      expect(goal.remaining, 70.0);

      final overGoal = GoalModel(
        title: 'Test Goal',
        current: 150.0,
        target: 100.0,
        createdBy: 'user1',
      );
      expect(overGoal.remaining, 0.0);
    });
  });
}
