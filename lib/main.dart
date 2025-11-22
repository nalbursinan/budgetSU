import 'package:flutter/material.dart';
import './screens/transactions.dart';
import './screens/mainscreen.dart';
import './screens/homescreen.dart';


//import '../lib/screens/analytics.dart';
//import '../lib/screens/goals.dart';
//import '../lib/screens/settings.dart';
// ===== Transaction Model =====



void main() {
  runApp(const BudgetSUApp());
}

class BudgetSUApp extends StatelessWidget {
  const BudgetSUApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BudgetSU',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        fontFamily: 'SF Pro Display',
      ),
      home: const MainScreen(), // 👈 artık initialRoute yerine MainScreen
    );
  }
}
