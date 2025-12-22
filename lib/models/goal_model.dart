import 'package:cloud_firestore/cloud_firestore.dart';

/// Goal model for savings targets
class GoalModel {
  final String? id;
  final String title;
  final double current;
  final double target;
  final String createdBy;
  final DateTime createdAt;

  GoalModel({
    this.id,
    required this.title,
    required this.current,
    required this.target,
    required this.createdBy,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isCompleted => current >= target;
  
  double get progress => target == 0 ? 0.0 : (current / target).clamp(0.0, 1.0);
  
  double get remaining => (target - current).clamp(0.0, double.infinity);

  /// Create a copy with updated fields
  GoalModel copyWith({
    String? id,
    String? title,
    double? current,
    double? target,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      current: current ?? this.current,
      target: target ?? this.target,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'current': current,
      'target': target,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create from Firestore document
  factory GoalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GoalModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      current: (data['current'] as num?)?.toDouble() ?? 0.0,
      target: (data['target'] as num?)?.toDouble() ?? 0.0,
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'GoalModel(id: $id, title: $title, current: $current, target: $target)';
  }
}

