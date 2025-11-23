import 'package:flutter/material.dart';

/// =======================================================
/// COLORS
/// =======================================================

class AppColors {
  static const Color background = Color(0xFFF5F7FF);

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

/// Off-campus yemek yerleri (şimdilik örnek, istersen değiştir)
const List<String> offCampusFoodPlaces = [
  'Off-campus Food 1',
  'Off-campus Food 2',
];

/// Off-campus kahve yerleri (şimdilik örnek)
const List<String> offCampusCoffeePlaces = [
  'Off-campus Coffee 1',
  'Off-campus Coffee 2',
];

/// On-campus’ta gözükecek gider kategorileri
const List<String> onCampusCategories = [
  'Food',
  'Coffee',
  'Transport',
  'Study',
  'Other',
];

/// Off-campus’ta gözükecek gider kategorileri
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
  final String title; // örn: "Campus Cafeteria"
  final String category; // Food, Coffee, Transport, ...
  final double amount; // her zaman pozitif tutuluyor
  final bool isIncome; // true = gelir, false = gider
  final String campusLocation; // "On-Campus", "Off-Campus"
  final DateTime date; // işlem tarihi

  TransactionModel({
    required this.title,
    required this.category,
    required this.amount,
    required this.isIncome,
    required this.campusLocation,
    required this.date,
  });
}

/// =======================================================
/// TRANSACTIONS SCREEN (EMPTY START)
/// =======================================================

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
    String two(int x) => x.toString().padLeft(2, '0');
    return "${two(d.day)}.${two(d.month)}.${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    // Tarihe göre gruplama
    final Map<String, List<TransactionModel>> groups = {};
    for (var tx in transactions) {
      final key = formatDate(tx.date);
      groups.putIfAbsent(key, () => []).add(tx);
    }
    final dates = groups.keys.toList()
      ..sort((a, b) => a.compareTo(b)); // istersen tersine çevirebilirsin

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----- HEADER -----
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Transactions",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: openAddSheet,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryPurple,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "${transactions.length} total",
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),

              // ----- EMPTY STATE / LIST -----
              if (transactions.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      "No transactions yet.\nTap + to add your first one!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 15,
                      ),
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
    bool offCampus = tx.campusLocation == "Off-Campus";

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
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                    if (onCampus || offCampus) ...[
                      const SizedBox(width: 6),
                      const Text(
                        "•",
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
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
                  ],
                ),
              ],
            ),
          ),

          // AMOUNT
          Text(
            "${tx.isIncome ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}",
            style: TextStyle(
              color: tx.isIncome ? Colors.green[600] : Colors.red[600],
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
  String type = "Expense"; // Expense / Income
  String? category; // Food, Coffee, ...
  bool isOnCampus = true;
  String? campusPlace; // seçilen mekan

  final descCtrl = TextEditingController();
  final amountCtrl = TextEditingController();

  InputDecoration box(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF3F3F3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  /// Kategori + On/Off-campus'a göre doğru mekan listesini seç (sadece Food/Coffee için)
  List<String> _getCurrentPlaceList() {
    if (category == "Food") {
      return isOnCampus ? onCampusFoodPlaces : offCampusFoodPlaces;
    }
    if (category == "Coffee") {
      return isOnCampus ? onCampusCoffeePlaces : offCampusCoffeePlaces;
    }
    return [];
  }

  void submit() {
    if (descCtrl.text.isEmpty ||
        amountCtrl.text.isEmpty ||
        category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields.")),
      );
      return;
    }

    final amount = double.tryParse(amountCtrl.text);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid amount.")),
      );
      return;
    }

    final tx = TransactionModel(
      title: descCtrl.text,
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

    // Food veya Coffee seçiliyse mekan dropdown'u gözüksün
    final bool showPlaceDropdown =
        category == "Food" || category == "Coffee";

    final String placeLabel =
    isOnCampus ? "On-Campus place" : "Off-Campus place";

    // Şu anki tipe ve location'a göre hangi kategori listesi?
    final List<String> currentCategories = () {
      if (type == "Expense") {
        return isOnCampus ? onCampusCategories : offCampusCategories;
      } else {
        return isOnCampus
            ? onCampusIncomeCategories
            : offCampusIncomeCategories;
      }
    }();

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  const Text(
                    "Add Transaction",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // TYPE
              const Text("Type"),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                decoration: box(""),
                value: type,
                items: const [
                  DropdownMenuItem(
                      value: "Expense", child: Text("Expense")),
                  DropdownMenuItem(
                      value: "Income", child: Text("Income")),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    type = value;

                    // Yeni tipe göre geçerli kategori listesini hesapla
                    final allowed = type == "Expense"
                        ? (isOnCampus
                        ? onCampusCategories
                        : offCampusCategories)
                        : (isOnCampus
                        ? onCampusIncomeCategories
                        : offCampusIncomeCategories);

                    // Seçili kategori artık geçerli değilse sıfırla
                    if (category != null && !allowed.contains(category)) {
                      category = null;
                    }

                    // Income'da Food/Coffee yoksa place dropdown da zaten görünmez
                    campusPlace = null;
                  });
                },
              ),
              const SizedBox(height: 16),

              // DESCRIPTION
              const Text("Description"),
              const SizedBox(height: 6),
              TextField(
                controller: descCtrl,
                decoration: box("e.g., Bus Ticket"),
              ),
              const SizedBox(height: 16),

              // AMOUNT
              const Text("Amount"),
              const SizedBox(height: 6),
              TextField(
                controller: amountCtrl,
                decoration: box("0.00"),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),

              // CATEGORY
              const Text("Category"),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                decoration: box("Select category"),
                value: category,
                items: currentCategories
                    .map(
                      (c) => DropdownMenuItem<String>(
                    value: c,
                    child: Text(c),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    category = value;
                    campusPlace = null; // kategori değişince mekan sıfırla
                  });
                },
              ),

              // PLACE DROPDOWN (Food / Coffee + Expense ise)
              if (showPlaceDropdown && type == "Expense") ...[
                const SizedBox(height: 16),
                Text(placeLabel),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: campusPlace,
                  decoration: box("Select place"),
                  items: _getCurrentPlaceList()
                      .map(
                        (p) => DropdownMenuItem<String>(
                      value: p,
                      child: Text(p),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    setState(() => campusPlace = value);
                    // description boşsa oto-doldur
                    if (value != null && descCtrl.text.trim().isEmpty) {
                      descCtrl.text = value;
                    }
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
                        campusPlace = null;

                        final allowed = type == "Expense"
                            ? onCampusCategories
                            : onCampusIncomeCategories;
                        if (category != null &&
                            !allowed.contains(category)) {
                          category = null;
                        }
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: isOnCampus
                              ? AppColors.primaryPurple
                              : Colors.white,
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(14),
                          ),
                          border: Border.all(color: AppColors.primaryPurple),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.apartment,
                              color: isOnCampus
                                  ? Colors.white
                                  : AppColors.primaryPurple,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "On-Campus",
                              style: TextStyle(
                                color: isOnCampus
                                    ? Colors.white
                                    : AppColors.primaryPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        isOnCampus = false;
                        campusPlace = null;

                        final allowed = type == "Expense"
                            ? offCampusCategories
                            : offCampusIncomeCategories;
                        if (category != null &&
                            !allowed.contains(category)) {
                          category = null;
                        }
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: !isOnCampus
                              ? AppColors.primaryPurple
                              : Colors.white,
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(14),
                          ),
                          border: Border.all(color: AppColors.primaryPurple),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: !isOnCampus
                                  ? Colors.white
                                  : AppColors.primaryPurple,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Off-Campus",
                              style: TextStyle(
                                color: !isOnCampus
                                    ? Colors.white
                                    : AppColors.primaryPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Add Transaction",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
