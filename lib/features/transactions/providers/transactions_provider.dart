import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_model.dart';

class TransactionsState {
  final List<TransactionModel> transactions;
  final double availableBudget;
  final double spentBudget;
  final double targetBudget;

  const TransactionsState({
    required this.transactions,
    required this.availableBudget,
    required this.spentBudget,
    required this.targetBudget,
  });

  TransactionsState copyWith({
    List<TransactionModel>? transactions,
    double? availableBudget,
    double? spentBudget,
    double? targetBudget,
  }) {
    return TransactionsState(
      transactions: transactions ?? this.transactions,
      availableBudget: availableBudget ?? this.availableBudget,
      spentBudget: spentBudget ?? this.spentBudget,
      targetBudget: targetBudget ?? this.targetBudget,
    );
  }
}

class TransactionsNotifier extends Notifier<TransactionsState> {
  @override
  TransactionsState build() {
    return TransactionsState(
      availableBudget: 1845000,
      spentBudget: 318500,
      targetBudget: 1773500,
      transactions: [
        TransactionModel(
          id: '1',
          merchant: 'Keells Super (Union Place)',
          subtitle: 'Today, 9:10 AM • Groceries • Commercial Bank',
          amount: 6900,
          cashback: 69,
          type: TransactionType.expense,
          category: TransactionCategoryType.groceries,
          date: DateTime.now(),
          note: 'Weekly essentials & fresh groceries',
        ),
        TransactionModel(
          id: '2',
          merchant: 'Dialog Axiata (Broadband)',
          subtitle: 'Yesterday, 6:45 PM • Internet/Tech • HNB',
          amount: 3450,
          cashback: 35,
          type: TransactionType.expense,
          category: TransactionCategoryType.bills,
          date: DateTime.now().subtract(const Duration(days: 1)),
          note: 'Home fibre & mobile postpaid bill',
        ),
        TransactionModel(
          id: '3',
          merchant: 'Pizza Hut Sri Lanka (Kollupitiya)',
          subtitle: 'Oct 17, 8:20 PM • Dining & Takeout • Cash',
          amount: 3150,
          cashback: 31.50,
          type: TransactionType.expense,
          category: TransactionCategoryType.dining,
          date: DateTime.now().subtract(const Duration(days: 3)),
          note: 'Team dinner after sprint launch #work',
          receiptFileName: 'Receipt_PizzaHut_1910.jpg',
          receiptItemCount: 3,
          receiptMatchPercent: 100,
        ),
        TransactionModel(
          id: '4',
          merchant: 'CEB Electricity & Water Bill',
          subtitle: 'Oct 15, 11:30 AM • Utilities • BOC Account',
          amount: 3450,
          cashback: 35,
          type: TransactionType.expense,
          category: TransactionCategoryType.bills,
          date: DateTime.now().subtract(const Duration(days: 5)),
          note: 'Monthly electricity and water utility bill',
        ),
        TransactionModel(
          id: '5',
          merchant: 'Apartment Rent (Colombo 03)',
          subtitle: 'Oct 10, 8:00 AM • Standing Order',
          amount: 120000,
          cashback: 1200,
          type: TransactionType.expense,
          category: TransactionCategoryType.housing,
          date: DateTime.now().subtract(const Duration(days: 10)),
          note: 'Monthly apartment rental Colombo 03',
        ),
        TransactionModel(
          id: '6',
          merchant: 'PickMe Sri Lanka (Airport & Fuel)',
          subtitle: 'Oct 08, 5:15 PM • Transport • Visa Card',
          amount: 4800,
          cashback: 48,
          type: TransactionType.expense,
          category: TransactionCategoryType.transport,
          date: DateTime.now().subtract(const Duration(days: 12)),
          note: 'Airport dropoff and expressway toll fee',
        ),
        TransactionModel(
          id: '7',
          merchant: 'Salary Credit (Techlabs Global)',
          subtitle: 'Oct 25, 9:00 AM • Primary Income • Commercial Bank',
          amount: 450000,
          cashback: 0,
          type: TransactionType.income,
          category: TransactionCategoryType.salary,
          date: DateTime.now().subtract(const Duration(days: 15)),
          note: 'Monthly salary credit Techlabs Global',
        ),
      ],
    );
  }

  TransactionModel addExpense({
    required double amount,
    required String merchant,
    required TransactionCategoryType category,
    String? note,
    String? receiptFileName,
    int? receiptItemCount,
    int? receiptMatchPercent,
    String? receiptImagePath,
  }) {
    final newTx = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      merchant: merchant,
      subtitle: 'Just now',
      amount: amount,
      cashback: (amount * 0.01).roundToDouble(),
      type: TransactionType.expense,
      category: category,
      date: DateTime.now(),
      note: note,
      receiptFileName: receiptFileName,
      receiptItemCount: receiptItemCount,
      receiptMatchPercent: receiptMatchPercent,
      receiptImagePath: receiptImagePath,
    );

    final newSpent = state.spentBudget + amount;
    final newAvailable = (state.availableBudget - amount).clamp(0.0, double.infinity);

    state = state.copyWith(
      transactions: [newTx, ...state.transactions],
      spentBudget: newSpent,
      availableBudget: newAvailable,
    );

    return newTx;
  }

  TransactionModel addIncome({
    required double amount,
    required String source,
    required TransactionCategoryType category,
    String? account,
    String? note,
  }) {
    final newTx = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      merchant: source,
      subtitle: 'Just now',
      amount: amount,
      cashback: 0.0,
      type: TransactionType.income,
      category: category,
      date: DateTime.now(),
      account: account ?? 'Commercial Bank (••4821)',
      note: note,
    );

    final newAvailable = state.availableBudget + amount;

    state = state.copyWith(
      transactions: [newTx, ...state.transactions],
      availableBudget: newAvailable,
    );

    return newTx;
  }

  void addTransaction(TransactionModel tx) {
    double newSpent = state.spentBudget;
    double newAvailable = state.availableBudget;

    if (tx.type == TransactionType.expense) {
      newSpent += tx.amount;
      newAvailable = (newAvailable - tx.amount).clamp(0.0, double.infinity);
    } else {
      newAvailable += tx.amount;
    }

    state = state.copyWith(
      transactions: [tx, ...state.transactions],
      spentBudget: newSpent,
      availableBudget: newAvailable,
    );
  }

  void updateTransaction(TransactionModel updated) {
    final index = state.transactions.indexWhere((t) => t.id == updated.id);
    if (index == -1) return;

    final oldTx = state.transactions[index];
    final list = List<TransactionModel>.from(state.transactions);
    list[index] = updated;

    double newSpent = state.spentBudget;
    double newAvailable = state.availableBudget;

    // Adjust budgets if amount changed
    if (oldTx.type == TransactionType.expense) {
      newSpent = newSpent - oldTx.amount + updated.amount;
      newAvailable = newAvailable + oldTx.amount - updated.amount;
    } else {
      newAvailable = newAvailable - oldTx.amount + updated.amount;
    }

    state = state.copyWith(
      transactions: list,
      spentBudget: newSpent,
      availableBudget: newAvailable,
    );
  }

  void deleteTransaction(String id) {
    final index = state.transactions.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final oldTx = state.transactions[index];
    final list = List<TransactionModel>.from(state.transactions)..removeAt(index);

    double newSpent = state.spentBudget;
    double newAvailable = state.availableBudget;

    if (oldTx.type == TransactionType.expense) {
      newSpent = (newSpent - oldTx.amount).clamp(0.0, double.infinity);
      newAvailable += oldTx.amount;
    } else {
      newAvailable = (newAvailable - oldTx.amount).clamp(0.0, double.infinity);
    }

    state = state.copyWith(
      transactions: list,
      spentBudget: newSpent,
      availableBudget: newAvailable,
    );
  }
}

final transactionsProvider =
    NotifierProvider<TransactionsNotifier, TransactionsState>(
        TransactionsNotifier.new);
