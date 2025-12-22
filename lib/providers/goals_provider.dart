import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/goal_model.dart';
import '../services/firestore_service.dart';

/// Goals Provider for state management
/// Handles real-time updates and CRUD operations for savings goals
class GoalsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<GoalModel> _goals = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _goalsSubscription;
  String? _currentUserId;

  // Getters
  List<GoalModel> get goals => _goals;
  List<GoalModel> get activeGoals => _goals.where((g) => !g.isCompleted).toList();
  List<GoalModel> get completedGoals => _goals.where((g) => g.isCompleted).toList();
  int get activeCount => activeGoals.length;
  int get completedCount => completedGoals.length;
  int get achievementsCount => completedGoals.length;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialize goals for a user
  void initializeForUser(String userId) {
    if (_currentUserId == userId && _goalsSubscription != null) {
      debugPrint('GoalsProvider: Already initialized for user $userId');
      return;
    }

    debugPrint('GoalsProvider: Initializing for user $userId');
    _currentUserId = userId;
    _isLoading = true;
    notifyListeners();

    // Cancel existing subscription
    _goalsSubscription?.cancel();

    // Listen to goals changes
    _goalsSubscription = _firestoreService
        .getGoalsStream(userId)
        .listen(
          (goals) {
            debugPrint('GoalsProvider: Received ${goals.length} goals');
            _goals = goals;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            debugPrint('GoalsProvider: Error - $error');
            _errorMessage = 'Failed to load goals: $error';
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  /// Add a new goal
  Future<bool> addGoal({
    required String title,
    required double target,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _errorMessage = 'User not logged in';
      notifyListeners();
      return false;
    }

    try {
      final goal = GoalModel(
        title: title,
        current: 0,
        target: target,
        createdBy: user.uid,
      );
      
      await _firestoreService.addGoal(goal);
      debugPrint('GoalsProvider: Goal added successfully');
      return true;
    } catch (e) {
      debugPrint('GoalsProvider: Failed to add goal - $e');
      _errorMessage = 'Failed to add goal: $e';
      notifyListeners();
      return false;
    }
  }

  /// Add progress to a goal
  Future<bool> addProgress(GoalModel goal, double amount) async {
    if (goal.id == null) {
      _errorMessage = 'Goal ID is required';
      notifyListeners();
      return false;
    }

    try {
      final updatedGoal = goal.copyWith(
        current: goal.current + amount,
      );
      
      await _firestoreService.updateGoal(updatedGoal);
      debugPrint('GoalsProvider: Progress added successfully');
      return true;
    } catch (e) {
      debugPrint('GoalsProvider: Failed to add progress - $e');
      _errorMessage = 'Failed to add progress: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update a goal
  Future<bool> updateGoal(GoalModel goal) async {
    if (goal.id == null) {
      _errorMessage = 'Goal ID is required';
      notifyListeners();
      return false;
    }

    try {
      await _firestoreService.updateGoal(goal);
      debugPrint('GoalsProvider: Goal updated successfully');
      return true;
    } catch (e) {
      debugPrint('GoalsProvider: Failed to update goal - $e');
      _errorMessage = 'Failed to update goal: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete a goal
  Future<bool> deleteGoal(String goalId) async {
    try {
      await _firestoreService.deleteGoal(goalId);
      debugPrint('GoalsProvider: Goal deleted successfully');
      return true;
    } catch (e) {
      debugPrint('GoalsProvider: Failed to delete goal - $e');
      _errorMessage = 'Failed to delete goal: $e';
      notifyListeners();
      return false;
    }
  }

  /// Clear all data (e.g., on logout)
  void clearData() {
    debugPrint('GoalsProvider: Clearing data');
    _goalsSubscription?.cancel();
    _goalsSubscription = null;
    _goals = [];
    _isLoading = false;
    _errorMessage = null;
    _currentUserId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _goalsSubscription?.cancel();
    super.dispose();
  }
}

