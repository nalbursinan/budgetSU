import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';

/// Firestore Service for CRUD operations on transactions
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection reference
  CollectionReference get _transactionsCollection => 
      _firestore.collection('transactions');

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
}
