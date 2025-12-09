import 'package:flutter/material.dart';


class AppColors {
  static const Color background = Color(0xFFF5F5F5);

  static const Color onCampusBg = Color(0xFFE4EEFF);
  static const Color onCampusText = Color(0xFF0F63FF);

  static const Color offCampusBg = Color(0xFFF5E6FF);
  static const Color offCampusText = Color(0xFFB020FF);

  // Ana mor (butonlar vs.)
  static const Color primaryPurple = Color(0xFF9E46F1);
}

/// On-campus yemek yerleri
const List<String> onCampusFoodPlaces = [
  'Yemekhane',
  'Küçükev',
  'Piazza',
  'Köpüklü',
  'PizzaBulls',
  'Subway',
  'SuSimit',
  'FassHane',
];

/// On-campus kahve yerleri
const List<String> onCampusCoffeePlaces = [
  'Starbucks',
  'Coffy',
  'Espressolab',
];

/// Off-campus yemek yerleri
const List<String> offCampusFoodPlaces = [
  'Off-campus Food 1',
  'Off-campus Food 2',
];

/// Off-campus kahve yerleri
const List<String> offCampusCoffeePlaces = [
  'Off-campus Coffee 1',
  'Off-campus Coffee 2',
];

/// On-campus gider kategorileri
const List<String> onCampusCategories = [
  'Food',
  'Coffee',
  'Transport',
  'Study',
  'Other',
];

/// Off-campus gider kategorileri
const List<String> offCampusCategories = [
  'Food',
  'Coffee',
  'Transport',
  'Study',
  'Other',
  'Market and Online Orders',
  'Credit Card',
  'Delivery / Paket Servis',
];

/// On-campus gelir kategorileri
const List<String> onCampusIncomeCategories = [
  'University Scholarship',
  'Part-time Job',
];

/// Off-campus gelir kategorileri
const List<String> offCampusIncomeCategories = [
  'External Scholarship',
  'KYK Loan',
  'Family Support',
];

/// =======================================================
/// MODEL
/// =======================================================

class TransactionModel {
  final String title;
  final String category;
  final double amount;
  final bool isIncome;
  final String campusLocation;
  final DateTime date;

  TransactionModel({
    required this.title,
    required this.category,
    required this.amount,
    required this.isIncome,
    required this.campusLocation,
    required this.date,
  });
}


/// TRANSACTIONS SCREEN


class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<TransactionModel> transactions = [];

  void openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return AddTransactionSheet(
          onSubmit: (tx) {
            setState(() {
              transactions.add(tx);
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  String formatDate(DateTime d) {
    return "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<TransactionModel>> groups = {};
    for (var tx in transactions) {
      final key = formatDate(tx.date);
      groups.putIfAbsent(key, () => []).add(tx);
    }
    final dates = groups.keys.toList()..sort();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Analytics-style header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Transactions",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${transactions.length} total transactions",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: openAddSheet,
                    borderRadius: BorderRadius.circular(20),
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primaryPurple,
                      child: Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // EMPTY / LIST
              if (transactions.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      "No transactions yet.\nTap + to add your first one!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 15),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView(
                    children: [
                      for (var date in dates) ...[
                        Text(
                          date,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),

                        for (var tx in groups[date]!) ...[
                          TransactionCard(tx: tx),
                          const SizedBox(height: 14),
                        ],

                        const SizedBox(height: 18),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// =======================================================
/// TRANSACTION CARD
/// =======================================================

class TransactionCard extends StatelessWidget {
  final TransactionModel tx;

  const TransactionCard({Key? key, required this.tx}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool onCampus = tx.campusLocation == "On-Campus";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          // LEFT SIDE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      tx.category,
                      style:
                      TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(width: 6),
                    const Text("•",
                        style: TextStyle(fontSize: 10, color: Colors.grey)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: onCampus
                            ? AppColors.onCampusBg
                            : AppColors.offCampusBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            onCampus
                                ? Icons.apartment
                                : Icons.location_on_outlined,
                            size: 14,
                            color: onCampus
                                ? AppColors.onCampusText
                                : AppColors.offCampusText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tx.campusLocation,
                            style: TextStyle(
                              fontSize: 12,
                              color: onCampus
                                  ? AppColors.onCampusText
                                  : AppColors.offCampusText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // RIGHT SIDE
          Text(
            "${tx.isIncome ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}",
            style: TextStyle(
              color:
              tx.isIncome ? Colors.green[600] : Colors.red[600],
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================================================
/// ADD TRANSACTION SHEET
/// =======================================================

class AddTransactionSheet extends StatefulWidget {
  final Function(TransactionModel) onSubmit;

  const AddTransactionSheet({Key? key, required this.onSubmit})
      : super(key: key);

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  String type = "Expense";
  String? category;
  bool isOnCampus = true;
  String? campusPlace;

  final descCtrl = TextEditingController();
  final amountCtrl = TextEditingController();

  bool amountError = false;

  InputDecoration box(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF3F3F3),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  List<String> _getPlaceList() {
    if (category == "Food") {
      return isOnCampus ? onCampusFoodPlaces : offCampusFoodPlaces;
    }
    if (category == "Coffee") {
      return isOnCampus ? onCampusCoffeePlaces : offCampusCoffeePlaces;
    }
    return [];
  }

  void submit() {
    final amount = double.tryParse(amountCtrl.text.trim());
    final invalidAmount = amount == null;
    final missingFields =
        descCtrl.text.trim().isEmpty || category == null;

    if (invalidAmount || missingFields) {
      setState(() {
        amountError = invalidAmount;
      });

      return;
    }

    final tx = TransactionModel(
      title: descCtrl.text.trim(),
      category: category!,
      amount: amount,
      isIncome: type == "Income",
      campusLocation: isOnCampus ? "On-Campus" : "Off-Campus",
      date: DateTime.now(),
    );

    widget.onSubmit(tx);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    final currentCategories = (type == "Expense")
        ? (isOnCampus ? onCampusCategories : offCampusCategories)
        : (isOnCampus ? onCampusIncomeCategories : offCampusIncomeCategories);

    final showPlaceDropdown =
        (category == "Food" || category == "Coffee") && type == "Expense";

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              children: [
                const Text("Add Transaction",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 16),

            // TYPE
            const Text("Type"),
            const SizedBox(height: 6),
            DropdownButtonFormField(
              value: type,
              decoration: box(""),
              items: const [
                DropdownMenuItem(value: "Expense", child: Text("Expense")),
                DropdownMenuItem(value: "Income", child: Text("Income")),
              ],
              onChanged: (v) {
                setState(() {
                  type = v!;
                  category = null;
                  campusPlace = null;
                });
              },
            ),
            const SizedBox(height: 16),

            // DESCRIPTION
            const Text("Description"),
            const SizedBox(height: 6),
            TextField(controller: descCtrl, decoration: box("e.g., Bus Ticket")),
            const SizedBox(height: 16),

            // AMOUNT
            const Text("Amount"),
            const SizedBox(height: 6),
            TextField(
              controller: amountCtrl,
              decoration: box("0.00").copyWith(
                errorText: amountError ? "Please enter a valid number" : null,
              ),
              keyboardType: TextInputType.text,
              onChanged: (value) {
                setState(() {
                  if (value.trim().isEmpty) {
                    amountError = true;
                  } else if (double.tryParse(value) == null) {
                    amountError = true;
                  } else {
                    amountError = false;
                  }
                });
              },
            ),
            const SizedBox(height: 16),

            // CATEGORY
            const Text("Category"),
            const SizedBox(height: 6),
            DropdownButtonFormField(
              value: category,
              decoration: box("Select category"),
              items: currentCategories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  category = v;
                  campusPlace = null;
                });
              },
            ),

            // PLACES
            if (showPlaceDropdown) ...[
              const SizedBox(height: 16),
              Text(isOnCampus ? "On-Campus place" : "Off-Campus place"),
              const SizedBox(height: 6),
              DropdownButtonFormField(
                value: campusPlace,
                decoration: box("Select place"),
                items: _getPlaceList()
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    campusPlace = v;
                    if (descCtrl.text.trim().isEmpty && v != null) {
                      descCtrl.text = v;
                    }
                  });
                },
              ),
            ],

            const SizedBox(height: 16),

            // LOCATION
            const Text("Location"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      isOnCampus = true;
                      category = null;
                      campusPlace = null;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isOnCampus
                            ? AppColors.primaryPurple
                            : Colors.white,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(14),
                        ),
                        border:
                        Border.all(color: AppColors.primaryPurple),
                      ),
                      child: Center(
                        child: Text("On-Campus",
                            style: TextStyle(
                              color: isOnCampus
                                  ? Colors.white
                                  : AppColors.primaryPurple,
                            )),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      isOnCampus = false;
                      category = null;
                      campusPlace = null;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !isOnCampus
                            ? AppColors.primaryPurple
                            : Colors.white,
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(14),
                        ),
                        border:
                        Border.all(color: AppColors.primaryPurple),
                      ),
                      child: Center(
                        child: Text("Off-Campus",
                            style: TextStyle(
                              color: !isOnCampus
                                  ? Colors.white
                                  : AppColors.primaryPurple,
                            )),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // SUBMIT
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text("Add Transaction",
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}