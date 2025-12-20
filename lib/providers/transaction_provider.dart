import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';
import '../services/firestore_service.dart';

/// Transaction Provider for state management
/// Handles real-time updates and CRUD operations
class TransactionProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<TransactionModel> _transactions = [];
  List<TransactionModel> _todayTransactions = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _transactionSubscription;
  StreamSubscription? _todaySubscription;
  String? _currentUserId; // Track current user to prevent duplicate initialization
  
  // Getters
  List<TransactionModel> get transactions => _transactions;
  List<TransactionModel> get todayTransactions => _todayTransactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Calculated values
  double get totalIncome => _transactions
      .where((t) => t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);
      
  double get totalExpenses => _transactions
      .where((t) => !t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);
      
  double get balance => totalIncome - totalExpenses;
  
  double get todaySpending => _todayTransactions
      .where((t) => !t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);
      
  double get onCampusSpending => _transactions
      .where((t) => !t.isIncome && t.campusLocation == 'On-Campus')
      .fold(0, (sum, t) => sum + t.amount);
      
  double get offCampusSpending => _transactions
      .where((t) => !t.isIncome && t.campusLocation == 'Off-Campus')
      .fold(0, (sum, t) => sum + t.amount);

  /// Get spending by category
  Map<String, double> get spendingByCategory {
    final Map<String, double> categorySpending = {};
    for (var t in _transactions.where((t) => !t.isIncome)) {
      categorySpending[t.category] = 
          (categorySpending[t.category] ?? 0) + t.amount;
    }
    return categorySpending;
  }

  /// Initialize and listen to transactions for a user
  void initializeForUser(String userId) {
    // Prevent duplicate initialization for the same user
    if (_currentUserId == userId && _transactionSubscription != null) {
      debugPrint('TransactionProvider: Already initialized for user $userId');
      return;
    }
    
    debugPrint('TransactionProvider: Initializing for user $userId');
    _currentUserId = userId;
    _setLoading(true);
    _clearError();
    
    // Cancel existing subscriptions
    _transactionSubscription?.cancel();
    _todaySubscription?.cancel();
    
    // Listen to all transactions
    _transactionSubscription = _firestoreService
        .getTransactionsStream(userId)
        .listen(
          (transactions) {
            debugPrint('TransactionProvider: Received ${transactions.length} transactions');
            _transactions = transactions;
            _setLoading(false);
            notifyListeners();
          },
          onError: (error) {
            debugPrint('TransactionProvider: Error - $error');
            _setError('Failed to load transactions: $error');
            _setLoading(false);
          },
        );
    
    // Listen to today's transactions
    _todaySubscription = _firestoreService
        .getTodayTransactions(userId)
        .listen(
          (transactions) {
            debugPrint('TransactionProvider: Received ${transactions.length} today transactions');
            _todayTransactions = transactions;
            notifyListeners();
          },
          onError: (error) {
            debugPrint('TransactionProvider: Today error - $error');
          },
        );
  }

  /// Add a new transaction
  Future<bool> addTransaction({
    required String title,
    required String category,
    required double amount,
    required bool isIncome,
    required String campusLocation,
    required DateTime date,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _setError('User not logged in');
      return false;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final transaction = TransactionModel(
        title: title,
        category: category,
        amount: amount,
        isIncome: isIncome,
        campusLocation: campusLocation,
        date: date,
        createdBy: user.uid,
      );
      
      await _firestoreService.addTransaction(transaction);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to add transaction: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Update an existing transaction
  Future<bool> updateTransaction(TransactionModel transaction) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _firestoreService.updateTransaction(transaction);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update transaction: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Delete a transaction
  Future<bool> deleteTransaction(String transactionId) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _firestoreService.deleteTransaction(transactionId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to delete transaction: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Get recent transactions (limit count)
  List<TransactionModel> getRecentTransactions({int limit = 5}) {
    return _transactions.take(limit).toList();
  }

  /// Clear all data (e.g., on logout)
  void clearData() {
    debugPrint('TransactionProvider: Clearing data');
    _transactionSubscription?.cancel();
    _todaySubscription?.cancel();
    _transactionSubscription = null;
    _todaySubscription = null;
    _transactions = [];
    _todayTransactions = [];
    _isLoading = false;
    _errorMessage = null;
    _currentUserId = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    _transactionSubscription?.cancel();
    _todaySubscription?.cancel();
    super.dispose();
  }
}

