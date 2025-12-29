import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_su/screens/goals.dart';

// (for Unit Test)
class TestGoal {
  String title;
  double amount;
  TestGoal({required this.title, required this.amount});
}

void main() {
  
  //1. UNIT TEST (logic test)
  test('Goal calculation logic test', () {
    final goal = TestGoal(title: "New Laptop", amount: 1500.0);
    double saved = 500.0;
    
    expect(goal.amount - saved, 1000.0);
  });


  //2. WIDGET TEST 
  testWidgets('Test Add Button Interaction (Increment Logic)', (WidgetTester tester) async {
    
  
    int balance = 0; 
    
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: Center(child: Text('Balance: \$$balance')),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    balance += 100;
                  });
                },
                child: const Icon(Icons.add),
              ),
            );
          },
        ),
      ),
    );

    // beginning control
    expect(find.text('Balance: \$0'), findsOneWidget);

    // click
    await tester.tap(find.byIcon(Icons.add));
    
    // update the screen
    await tester.pump();

    // result check
    expect(find.text('Balance: \$100'), findsOneWidget);
  });
}