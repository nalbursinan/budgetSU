import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../models/goal_model.dart';
import '../providers/settings_provider.dart';

/// Firestore Service for CRUD operations on transactions, goals, and user settings
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection references
  CollectionReference get _transactionsCollection => 
      _firestore.collection('transactions');
  
  CollectionReference get _userSettingsCollection =>
      _firestore.collection('userSettings');
  
  CollectionReference get _goalsCollection =>
      _firestore.collection('goals');

  /// CREATE - Add a new transaction
  Future<String> addTransaction(TransactionModel transaction) async {
    try {
      final docRef = await _transactionsCollection.add(transaction.toFirestore());
      debugPrint('FirestoreService: Added transaction ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('FirestoreService: Failed to add transaction - $e');
      throw Exception('Failed to add transaction: $e');
    }
  }

  /// READ - Get all transactions for a specific user (real-time stream)
  /// Sorting is done client-side to avoid composite index requirement
  Stream<List<TransactionModel>> getTransactionsStream(String userId) {
    debugPrint('FirestoreService: Setting up stream for user $userId');
    return _transactionsCollection
        .where('createdBy', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          debugPrint('FirestoreService: Received ${snapshot.docs.length} docs');
          final transactions = snapshot.docs
              .map((doc) => TransactionModel.fromFirestore(doc))
              .toList();
          // Sort client-side to avoid composite index requirement
          transactions.sort((a, b) => b.date.compareTo(a.date));
          return transactions;
        });
  }

  /// READ - Get transactions for today
  Stream<List<TransactionModel>> getTodayTransactions(String userId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    
    return _transactionsCollection
        .where('createdBy', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final transactions = snapshot.docs
              .map((doc) => TransactionModel.fromFirestore(doc))
              .where((tx) => tx.date.isAfter(startOfDay) || 
                            tx.date.isAtSameMomentAs(startOfDay))
              .toList();
          transactions.sort((a, b) => b.date.compareTo(a.date));
          return transactions;
        });
  }

  /// READ - Get a single transaction by ID
  Future<TransactionModel?> getTransaction(String transactionId) async {
    try {
      final doc = await _transactionsCollection.doc(transactionId).get();
      if (doc.exists) {
        return TransactionModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('FirestoreService: Failed to get transaction - $e');
      throw Exception('Failed to get transaction: $e');
    }
  }

  /// UPDATE - Update an existing transaction
  Future<void> updateTransaction(TransactionModel transaction) async {
    if (transaction.id == null) {
      throw Exception('Transaction ID is required for update');
    }
    try {
      debugPrint('FirestoreService: Updating transaction ${transaction.id}');
      await _transactionsCollection
          .doc(transaction.id)
          .update(transaction.toFirestore());
      debugPrint('FirestoreService: Transaction updated successfully');
    } catch (e) {
      debugPrint('FirestoreService: Failed to update transaction - $e');
      throw Exception('Failed to update transaction: $e');
    }
  }

  /// DELETE - Remove a transaction
  Future<void> deleteTransaction(String transactionId) async {
    try {
      debugPrint('FirestoreService: Deleting transaction $transactionId');
      await _transactionsCollection.doc(transactionId).delete();
      debugPrint('FirestoreService: Transaction deleted successfully');
    } catch (e) {
      debugPrint('FirestoreService: Failed to delete transaction - $e');
      throw Exception('Failed to delete transaction: $e');
    }
  }

  /// Calculate total balance for a user
  Future<Map<String, double>> getBalanceSummary(String userId) async {
    try {
      final snapshot = await _transactionsCollection
          .where('createdBy', isEqualTo: userId)
          .get();
      
      double totalIncome = 0;
      double totalExpenses = 0;
      
      for (var doc in snapshot.docs) {
        final transaction = TransactionModel.fromFirestore(doc);
        if (transaction.isIncome) {
          totalIncome += transaction.amount;
        } else {
          totalExpenses += transaction.amount;
        }
      }
      
      return {
        'totalIncome': totalIncome,
        'totalExpenses': totalExpenses,
        'balance': totalIncome - totalExpenses,
      };
    } catch (e) {
      debugPrint('FirestoreService: Failed to calculate balance - $e');
      throw Exception('Failed to calculate balance: $e');
    }
  }

  // ============================================
  // USER SETTINGS METHODS
  // ============================================

  /// Get user settings stream (real-time updates)
  Stream<UserSettings> getUserSettingsStream(String userId) {
    debugPrint('FirestoreService: Setting up settings stream for user $userId');
    return _userSettingsCollection
        .doc(userId)
        .snapshots()
        .map((snapshot) {
          debugPrint('FirestoreService: Received settings snapshot');
          if (snapshot.exists) {
            return UserSettings.fromFirestore(snapshot.data() as Map<String, dynamic>?);
          }
          return const UserSettings();
        });
  }

  /// Get user settings once
  Future<UserSettings> getUserSettings(String userId) async {
    try {
      final doc = await _userSettingsCollection.doc(userId).get();
      if (doc.exists) {
        return UserSettings.fromFirestore(doc.data() as Map<String, dynamic>?);
      }
      return const UserSettings();
    } catch (e) {
      debugPrint('FirestoreService: Failed to get user settings - $e');
      throw Exception('Failed to get user settings: $e');
    }
  }

  /// Update user settings (creates if doesn't exist)
  Future<void> updateUserSettings(String userId, UserSettings settings) async {
    try {
      debugPrint('FirestoreService: Updating settings for user $userId');
      await _userSettingsCollection.doc(userId).set(
        settings.toFirestore(),
        SetOptions(merge: true),
      );
      debugPrint('FirestoreService: Settings updated successfully');
    } catch (e) {
      debugPrint('FirestoreService: Failed to update user settings - $e');
      throw Exception('Failed to update user settings: $e');
    }
  }

  // ============================================
  // GOALS METHODS
  // ============================================

  /// CREATE - Add a new goal
  Future<String> addGoal(GoalModel goal) async {
    try {
      final docRef = await _goalsCollection.add(goal.toFirestore());
      debugPrint('FirestoreService: Added goal ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('FirestoreService: Failed to add goal - $e');
      throw Exception('Failed to add goal: $e');
    }
  }

  /// READ - Get all goals for a specific user (real-time stream)
  Stream<List<GoalModel>> getGoalsStream(String userId) {
    debugPrint('FirestoreService: Setting up goals stream for user $userId');
    return _goalsCollection
        .where('createdBy', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          debugPrint('FirestoreService: Received ${snapshot.docs.length} goals');
          final goals = snapshot.docs
              .map((doc) => GoalModel.fromFirestore(doc))
              .toList();
          // Sort by creation date (newest first)
          goals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return goals;
        });
  }

  /// READ - Get a single goal by ID
  Future<GoalModel?> getGoal(String goalId) async {
    try {
      final doc = await _goalsCollection.doc(goalId).get();
      if (doc.exists) {
        return GoalModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('FirestoreService: Failed to get goal - $e');
      throw Exception('Failed to get goal: $e');
    }
  }

  /// UPDATE - Update an existing goal
  Future<void> updateGoal(GoalModel goal) async {
    if (goal.id == null) {
      throw Exception('Goal ID is required for update');
    }
    try {
      debugPrint('FirestoreService: Updating goal ${goal.id}');
      await _goalsCollection
          .doc(goal.id)
          .update(goal.toFirestore());
      debugPrint('FirestoreService: Goal updated successfully');
    } catch (e) {
      debugPrint('FirestoreService: Failed to update goal - $e');
      throw Exception('Failed to update goal: $e');
    }
  }

  /// DELETE - Remove a goal
  Future<void> deleteGoal(String goalId) async {
    try {
      debugPrint('FirestoreService: Deleting goal $goalId');
      await _goalsCollection.doc(goalId).delete();
      debugPrint('FirestoreService: Goal deleted successfully');
    } catch (e) {
      debugPrint('FirestoreService: Failed to delete goal - $e');
      throw Exception('Failed to delete goal: $e');
    }
  }
}
