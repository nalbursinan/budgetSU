import 'package:cloud_firestore/cloud_firestore.dart';

/// Transaction Model for Firestore
/// Each document includes: id, title, category, amount, isIncome, campusLocation, createdBy, createdAt
class TransactionModel {
  final String? id;
  final String title;
  final String category;
  final double amount;
  final bool isIncome;
  final String campusLocation;
  final DateTime date;
  final String createdBy; // User ID
  final DateTime createdAt;

  TransactionModel({
    this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.isIncome,
    required this.campusLocation,
    required this.date,
    required this.createdBy,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert from Firestore document to TransactionModel
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      isIncome: data['isIncome'] ?? false,
      campusLocation: data['campusLocation'] ?? 'On-Campus',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert TransactionModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'category': category,
      'amount': amount,
      'isIncome': isIncome,
      'campusLocation': campusLocation,
      'date': Timestamp.fromDate(date),
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create a copy with updated fields
  TransactionModel copyWith({
    String? id,
    String? title,
    String? category,
    double? amount,
    bool? isIncome,
    String? campusLocation,
    DateTime? date,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      isIncome: isIncome ?? this.isIncome,
      campusLocation: campusLocation ?? this.campusLocation,
      date: date ?? this.date,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

