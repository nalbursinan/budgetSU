import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_su/models/goal_model.dart';

void main() {
  testWidgets('GoalModel progress calculation displays correctly', (WidgetTester tester) async {
    // Create a test goal
    final goal = GoalModel(
      title: 'Test Goal',
      current: 75.0,
      target: 100.0,
      createdBy: 'user1',
    );

    // Build a simple widget that uses the goal
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Text('Goal: ${goal.title}'),
              Text('Progress: ${(goal.progress * 100).toStringAsFixed(0)}%'),
              Text('Remaining: \$${goal.remaining.toStringAsFixed(2)}'),
              Text('Completed: ${goal.isCompleted}'),
            ],
          ),
        ),
      ),
    );

    // Verify the widgets display the correct values
    expect(find.text('Goal: Test Goal'), findsOneWidget);
    expect(find.text('Progress: 75%'), findsOneWidget);
    expect(find.text('Remaining: \$25.00'), findsOneWidget);
    expect(find.text('Completed: false'), findsOneWidget);
  });
}
