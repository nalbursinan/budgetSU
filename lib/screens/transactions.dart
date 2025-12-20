import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';

class AppColors {
  static const Color background = Color(0xFFF5F5F5);

  static const Color onCampusBg = Color(0xFFE4EEFF);
  static const Color onCampusText = Color(0xFF0F63FF);

  static const Color offCampusBg = Color(0xFFF5E6FF);
  static const Color offCampusText = Color(0xFFB020FF);

  // Primary purple (buttons etc.)
  static const Color primaryPurple = Color(0xFF9E46F1);
}

/// On-campus food places
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

/// On-campus coffee places
const List<String> onCampusCoffeePlaces = [
  'Starbucks',
  'Coffy',
  'Espressolab',
];

/// Off-campus food places
const List<String> offCampusFoodPlaces = [
  'Off-campus Food 1',
  'Off-campus Food 2',
];

/// Off-campus coffee places
const List<String> offCampusCoffeePlaces = [
  'Off-campus Coffee 1',
  'Off-campus Coffee 2',
];

/// On-campus expense categories
const List<String> onCampusCategories = [
  'Food',
  'Coffee',
  'Transport',
  'Study',
  'Other',
];

/// Off-campus expense categories
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

/// On-campus income categories
const List<String> onCampusIncomeCategories = [
  'University Scholarship',
  'Part-time Job',
];

/// Off-campus income categories
const List<String> offCampusIncomeCategories = [
  'External Scholarship',
  'KYK Loan',
  'Family Support',
];

/// TRANSACTIONS SCREEN
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  void openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return const AddTransactionSheet();
      },
    );
  }

  String formatDate(DateTime d) {
    return "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final transactions = provider.transactions;
        
        // Group transactions by date
        final Map<String, List<TransactionModel>> groups = {};
        for (var tx in transactions) {
          final key = formatDate(tx.date);
          groups.putIfAbsent(key, () => []).add(tx);
        }
        final dates = groups.keys.toList()..sort((a, b) => b.compareTo(a));

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
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

                  // Loading indicator
                  if (provider.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    )
                  // Empty state
                  else if (transactions.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No transactions yet.\nTap + to add your first one!",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600], fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    )
                  // Transaction list
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
                              TransactionCard(
                                tx: tx,
                                onDelete: () => _deleteTransaction(tx),
                                onEdit: () => _editTransaction(tx),
                              ),
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
      },
    );
  }

  void _deleteTransaction(TransactionModel tx) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text('Are you sure you want to delete "${tx.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (tx.id != null) {
                final success = await context
                    .read<TransactionProvider>()
                    .deleteTransaction(tx.id!);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaction deleted'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editTransaction(TransactionModel tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return AddTransactionSheet(transaction: tx);
      },
    );
  }
}

/// TRANSACTION CARD
class TransactionCard extends StatelessWidget {
  final TransactionModel tx;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const TransactionCard({
    Key? key, 
    required this.tx, 
    this.onDelete,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool onCampus = tx.campusLocation == "On-Campus";

    return Dismissible(
      key: Key(tx.id ?? tx.title + tx.createdAt.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        onDelete?.call();
        return false; // Don't dismiss, let dialog handle it
      },
      child: GestureDetector(
        onTap: onEdit,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Category icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tx.isIncome 
                      ? Colors.green[50] 
                      : (onCampus ? AppColors.onCampusBg : AppColors.offCampusBg),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _getCategoryIcon(tx.category, tx.isIncome),
                  color: tx.isIncome 
                      ? Colors.green[600] 
                      : (onCampus ? AppColors.onCampusText : AppColors.offCampusText),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              // Details
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

              // Amount
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
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category, bool isIncome) {
    if (isIncome) return Icons.arrow_downward;
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Coffee':
        return Icons.coffee;
      case 'Transport':
        return Icons.directions_bus;
      case 'Study':
        return Icons.menu_book;
      case 'Market and Online Orders':
        return Icons.shopping_cart;
      case 'Credit Card':
        return Icons.credit_card;
      case 'Delivery / Paket Servis':
        return Icons.delivery_dining;
      default:
        return Icons.receipt;
    }
  }
}

/// ADD/EDIT TRANSACTION SHEET
class AddTransactionSheet extends StatefulWidget {
  final TransactionModel? transaction;

  const AddTransactionSheet({Key? key, this.transaction}) : super(key: key);

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  late String type;
  String? category;
  late bool isOnCampus;
  String? campusPlace;

  late TextEditingController descCtrl;
  late TextEditingController amountCtrl;

  bool amountError = false;
  bool isSubmitting = false;

  bool get isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    type = tx?.isIncome == true ? "Income" : "Expense";
    category = tx?.category;
    isOnCampus = tx?.campusLocation == "On-Campus" || tx?.campusLocation == null;
    descCtrl = TextEditingController(text: tx?.title ?? '');
    amountCtrl = TextEditingController(text: tx?.amount.toStringAsFixed(2) ?? '');
  }

  @override
  void dispose() {
    descCtrl.dispose();
    amountCtrl.dispose();
    super.dispose();
  }

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

  Future<void> submit() async {
    final amount = double.tryParse(amountCtrl.text.trim());
    final invalidAmount = amount == null || amount <= 0;
    final missingDescription = descCtrl.text.trim().isEmpty;
    final missingCategory = category == null;

    // Build specific error message
    List<String> errors = [];
    if (missingDescription) errors.add('Description');
    if (invalidAmount) errors.add('Amount');
    if (missingCategory) errors.add('Category');

    if (errors.isNotEmpty) {
      setState(() {
        amountError = invalidAmount;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill: ${errors.join(', ')}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);

    final provider = context.read<TransactionProvider>();
    bool success;

    if (isEditing) {
      // Update existing transaction
      final updatedTx = widget.transaction!.copyWith(
        title: descCtrl.text.trim(),
        category: category,
        amount: amount,
        isIncome: type == "Income",
        campusLocation: isOnCampus ? "On-Campus" : "Off-Campus",
      );
      success = await provider.updateTransaction(updatedTx);
    } else {
      // Add new transaction
      success = await provider.addTransaction(
        title: descCtrl.text.trim(),
        category: category!,
        amount: amount!,
        isIncome: type == "Income",
        campusLocation: isOnCampus ? "On-Campus" : "Off-Campus",
        date: DateTime.now(),
      );
    }

    setState(() => isSubmitting = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Transaction updated' : 'Transaction added'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Something went wrong'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                Text(
                  isEditing ? "Edit Transaction" : "Add Transaction",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              value: currentCategories.contains(category) ? category : null,
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
                onPressed: isSubmitting ? null : submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isEditing ? "Update Transaction" : "Add Transaction",
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),

            // DELETE BUTTON (only in edit mode)
            if (isEditing) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isSubmitting ? null : _showDeleteConfirmation,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text(
                    "Delete Transaction",
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text('Are you sure you want to delete "${widget.transaction?.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog
              if (widget.transaction?.id != null) {
                setState(() => isSubmitting = true);
                final success = await context
                    .read<TransactionProvider>()
                    .deleteTransaction(widget.transaction!.id!);
                setState(() => isSubmitting = false);
                
                if (success && mounted) {
                  Navigator.pop(context); // Close bottom sheet
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaction deleted'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
