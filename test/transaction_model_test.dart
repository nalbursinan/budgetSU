import 'package:flutter_test/flutter_test.dart';
import 'package:budget_su/models/transaction_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('TransactionModel', () {
    test('toFirestore should convert model to map correctly', () {
      final date = DateTime(2024, 1, 15);
      final transaction = TransactionModel(
        title: 'Test Transaction',
        category: 'Food',
        amount: 25.50,
        isIncome: false,
        campusLocation: 'On-Campus',
        date: date,
        createdBy: 'user1',
      );

      final firestoreData = transaction.toFirestore();
      expect(firestoreData['title'], 'Test Transaction');
      expect(firestoreData['category'], 'Food');
      expect(firestoreData['amount'], 25.50);
      expect(firestoreData['isIncome'], false);
      expect(firestoreData['campusLocation'], 'On-Campus');
      expect(firestoreData['createdBy'], 'user1');
      expect(firestoreData['date'], isA<Timestamp>());
      expect(firestoreData['createdAt'], isA<Timestamp>());
    });
  });
}
