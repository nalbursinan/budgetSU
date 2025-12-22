import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/goals_provider.dart';
import 'screens/auth/auth_wrapper.dart';

void main() async {
  // Ensure Flutter engine is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize theme mode before running app
  final settingsProvider = SettingsProvider();
  await settingsProvider.initializeThemeMode();
  
  runApp(BudgetSUApp(settingsProvider: settingsProvider));
}

class BudgetSUApp extends StatelessWidget {
  final SettingsProvider? settingsProvider;
  
  const BudgetSUApp({Key? key, this.settingsProvider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider.value(value: settingsProvider ?? SettingsProvider()),
        ChangeNotifierProvider(create: (_) => GoalsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: 'BudgetSU',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: const Color(0xFFF5F5F5),
              fontFamily: 'SF Pro Display',
              colorScheme: ColorScheme.light(
                primary: Colors.blue[700]!,
                secondary: Colors.blue[400]!,
                surface: Colors.white,
                background: const Color(0xFFF5F5F5),
                error: Colors.red[700]!,
                onPrimary: Colors.white,
                onSecondary: Colors.white,
                onSurface: Colors.black87,
                onBackground: Colors.black87,
                onError: Colors.white,
              ),
              cardColor: Colors.white,
              cardTheme: CardThemeData(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 0,
              ),
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: const Color(0xFF121212),
              fontFamily: 'SF Pro Display',
              colorScheme: ColorScheme.dark(
                primary: Colors.blue[400]!,
                secondary: Colors.blue[300]!,
                surface: const Color(0xFF1E1E1E),
                background: const Color(0xFF121212),
                error: Colors.red[400]!,
                onPrimary: Colors.white,
                onSecondary: Colors.white,
                onSurface: Colors.white,
                onBackground: Colors.white,
                onError: Colors.white,
              ),
              cardColor: const Color(0xFF1E1E1E),
              cardTheme: CardThemeData(
                color: const Color(0xFF1E1E1E),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1E1E1E),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              dividerColor: Colors.white.withOpacity(0.1),
            ),
            themeMode: settingsProvider.themeMode,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}
