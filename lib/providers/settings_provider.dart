import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firestore_service.dart';

/// Model for user settings
class UserSettings {
  final double dailySpendingLimit;
  final bool budgetAlerts;
  final bool dailySummary;
  final bool goalReminders;

  const UserSettings({
    this.dailySpendingLimit = 50.0,
    this.budgetAlerts = true,
    this.dailySummary = false,
    this.goalReminders = true,
  });

  UserSettings copyWith({
    double? dailySpendingLimit,
    bool? budgetAlerts,
    bool? dailySummary,
    bool? goalReminders,
  }) {
    return UserSettings(
      dailySpendingLimit: dailySpendingLimit ?? this.dailySpendingLimit,
      budgetAlerts: budgetAlerts ?? this.budgetAlerts,
      dailySummary: dailySummary ?? this.dailySummary,
      goalReminders: goalReminders ?? this.goalReminders,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'dailySpendingLimit': dailySpendingLimit,
      'budgetAlerts': budgetAlerts,
      'dailySummary': dailySummary,
      'goalReminders': goalReminders,
    };
  }

  factory UserSettings.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) return const UserSettings();
    
    return UserSettings(
      dailySpendingLimit: (data['dailySpendingLimit'] as num?)?.toDouble() ?? 50.0,
      budgetAlerts: data['budgetAlerts'] as bool? ?? true,
      dailySummary: data['dailySummary'] as bool? ?? false,
      goalReminders: data['goalReminders'] as bool? ?? true,
    );
  }
}

/// Settings Provider for managing user settings state
class SettingsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  UserSettings _settings = const UserSettings();
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentUserId;
  StreamSubscription? _settingsSubscription;
  
  // Theme mode management with SharedPreferences
  ThemeMode _themeMode = ThemeMode.light;
  static const String _themeModeKey = 'theme_mode';
  bool _themeModeLoaded = false;

  // Getters
  UserSettings get settings => _settings;
  double get dailySpendingLimit => _settings.dailySpendingLimit;
  bool get budgetAlerts => _settings.budgetAlerts;
  bool get dailySummary => _settings.dailySummary;
  bool get goalReminders => _settings.goalReminders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ThemeMode get themeMode => _themeMode;

  /// Initialize theme mode from SharedPreferences (should be called on app startup)
  Future<void> initializeThemeMode() async {
    if (_themeModeLoaded) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeIndex = prefs.getInt(_themeModeKey);
      if (themeModeIndex != null && themeModeIndex >= 0 && themeModeIndex < ThemeMode.values.length) {
        _themeMode = ThemeMode.values[themeModeIndex];
      }
      _themeModeLoaded = true;
      notifyListeners();
      debugPrint('SettingsProvider: Theme mode loaded - $_themeMode');
    } catch (e) {
      debugPrint('SettingsProvider: Failed to load theme mode - $e');
      _themeModeLoaded = true; // Mark as loaded even on error to prevent retries
    }
  }

  /// Update theme mode and persist to SharedPreferences
  Future<void> updateThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, mode.index);
      debugPrint('SettingsProvider: Theme mode saved - $mode');
    } catch (e) {
      debugPrint('SettingsProvider: Failed to save theme mode - $e');
    }
  }

  /// Toggle between light and dark theme
  Future<void> toggleThemeMode() async {
    final newMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await updateThemeMode(newMode);
  }

  /// Initialize settings for a user
  void initializeForUser(String userId) {
    if (_currentUserId == userId && _settingsSubscription != null) {
      debugPrint('SettingsProvider: Already initialized for user $userId');
      return;
    }

    debugPrint('SettingsProvider: Initializing for user $userId');
    _currentUserId = userId;
    _isLoading = true;
    notifyListeners();

    // Cancel existing subscription
    _settingsSubscription?.cancel();

    // Listen to settings changes
    _settingsSubscription = _firestoreService
        .getUserSettingsStream(userId)
        .listen(
          (settings) {
            debugPrint('SettingsProvider: Received settings update');
            _settings = settings;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            debugPrint('SettingsProvider: Error - $error');
            _errorMessage = 'Failed to load settings: $error';
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  /// Update daily spending limit
  Future<bool> updateDailySpendingLimit(double limit) async {
    if (_currentUserId == null) return false;
    
    try {
      final newSettings = _settings.copyWith(dailySpendingLimit: limit);
      await _firestoreService.updateUserSettings(_currentUserId!, newSettings);
      return true;
    } catch (e) {
      debugPrint('SettingsProvider: Failed to update daily limit - $e');
      _errorMessage = 'Failed to update daily limit: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update notification settings
  Future<bool> updateNotificationSettings({
    bool? budgetAlerts,
    bool? dailySummary,
    bool? goalReminders,
  }) async {
    if (_currentUserId == null) return false;
    
    try {
      final newSettings = _settings.copyWith(
        budgetAlerts: budgetAlerts,
        dailySummary: dailySummary,
        goalReminders: goalReminders,
      );
      await _firestoreService.updateUserSettings(_currentUserId!, newSettings);
      return true;
    } catch (e) {
      debugPrint('SettingsProvider: Failed to update notifications - $e');
      _errorMessage = 'Failed to update notification settings: $e';
      notifyListeners();
      return false;
    }
  }

  /// Clear all data (e.g., on logout)
  void clearData() {
    debugPrint('SettingsProvider: Clearing data');
    _settingsSubscription?.cancel();
    _settingsSubscription = null;
    _settings = const UserSettings();
    _isLoading = false;
    _errorMessage = null;
    _currentUserId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _settingsSubscription?.cancel();
    super.dispose();
  }
}

