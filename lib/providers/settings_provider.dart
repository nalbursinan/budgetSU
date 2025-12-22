import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';

/// Model for user settings
class UserSettings {
  final double dailySpendingLimit;
  final bool budgetAlerts;
  final bool dailySummary;
  final bool goalReminders;
  final CampusLocation? campusLocation;

  const UserSettings({
    this.dailySpendingLimit = 50.0,
    this.budgetAlerts = true,
    this.dailySummary = false,
    this.goalReminders = true,
    this.campusLocation,
  });

  UserSettings copyWith({
    double? dailySpendingLimit,
    bool? budgetAlerts,
    bool? dailySummary,
    bool? goalReminders,
    CampusLocation? campusLocation,
    bool clearCampusLocation = false,
  }) {
    return UserSettings(
      dailySpendingLimit: dailySpendingLimit ?? this.dailySpendingLimit,
      budgetAlerts: budgetAlerts ?? this.budgetAlerts,
      dailySummary: dailySummary ?? this.dailySummary,
      goalReminders: goalReminders ?? this.goalReminders,
      campusLocation: clearCampusLocation ? null : (campusLocation ?? this.campusLocation),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'dailySpendingLimit': dailySpendingLimit,
      'budgetAlerts': budgetAlerts,
      'dailySummary': dailySummary,
      'goalReminders': goalReminders,
      'campusLocation': campusLocation?.toFirestore(),
    };
  }

  factory UserSettings.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) return const UserSettings();
    
    return UserSettings(
      dailySpendingLimit: (data['dailySpendingLimit'] as num?)?.toDouble() ?? 50.0,
      budgetAlerts: data['budgetAlerts'] as bool? ?? true,
      dailySummary: data['dailySummary'] as bool? ?? false,
      goalReminders: data['goalReminders'] as bool? ?? true,
      campusLocation: data['campusLocation'] != null
          ? CampusLocation.fromFirestore(data['campusLocation'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Campus location model
class CampusLocation {
  final double lat;
  final double lng;
  final double radius;

  const CampusLocation({
    required this.lat,
    required this.lng,
    required this.radius,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'lat': lat,
      'lng': lng,
      'radius': radius,
    };
  }

  factory CampusLocation.fromFirestore(Map<String, dynamic> data) {
    return CampusLocation(
      lat: (data['lat'] as num).toDouble(),
      lng: (data['lng'] as num).toDouble(),
      radius: (data['radius'] as num).toDouble(),
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

  // Getters
  UserSettings get settings => _settings;
  double get dailySpendingLimit => _settings.dailySpendingLimit;
  bool get budgetAlerts => _settings.budgetAlerts;
  bool get dailySummary => _settings.dailySummary;
  bool get goalReminders => _settings.goalReminders;
  CampusLocation? get campusLocation => _settings.campusLocation;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  /// Update campus location
  Future<bool> updateCampusLocation(CampusLocation? location) async {
    if (_currentUserId == null) return false;
    
    try {
      final newSettings = location != null
          ? _settings.copyWith(campusLocation: location)
          : _settings.copyWith(clearCampusLocation: true);
      await _firestoreService.updateUserSettings(_currentUserId!, newSettings);
      return true;
    } catch (e) {
      debugPrint('SettingsProvider: Failed to update campus location - $e');
      _errorMessage = 'Failed to update campus location: $e';
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

