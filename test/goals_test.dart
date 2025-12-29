import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_su/screens/goals.dart'; // Doğrusu bu (Paket ismiyle)
// import 'package:budget_su/screens/mainscreen.dart'; // Eğer testte kullanmıyorsan bu satırı silmen en iyisi!

// TEST İÇİN İZOLE MODEL (Unit Test İçin)
class TestGoal {
  String title;
  double amount;
  TestGoal({required this.title, required this.amount});
}

void main() {
  
  //1. UNIT TEST (Matematik/Mantık)
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

    // Başlangıç kontrolü
    expect(find.text('Balance: \$0'), findsOneWidget);

    // TIKLA
    await tester.tap(find.byIcon(Icons.add));
    
    // Ekranı güncelle
    await tester.pump();

    // Sonuç kontrolü
    expect(find.text('Balance: \$100'), findsOneWidget);
  });
}