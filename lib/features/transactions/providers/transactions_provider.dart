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
      spentBudget: 650000,
      targetBudget: 1773500,
      transactions: [
        TransactionModel(
          id: '1',
          merchant: 'Keells Super',
          subtitle: '9:10 AM',
          amount: 6900,
          cashback: 69,
          type: TransactionType.expense,
          category: TransactionCategoryType.groceries,
          date: DateTime.now(),
        ),
        TransactionModel(
          id: '2',
          merchant: 'Pizza Hut Sri Lanka',
          subtitle: '8:20 PM',
          amount: 3150,
          cashback: 31,
          type: TransactionType.expense,
          category: TransactionCategoryType.dining,
          date: DateTime.now(),
        ),
        TransactionModel(
          id: '3',
          merchant: 'Dialog Axiata',
          subtitle: 'Yesterday, 6:45 PM',
          amount: 3450,
          cashback: 35,
          type: TransactionType.expense,
          category: TransactionCategoryType.bills,
          date: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
    );
  }

  void addExpense({
    required double amount,
    required String merchant,
    required TransactionCategoryType category,
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
    );

    final newSpent = state.spentBudget + amount;
    final newAvailable = (state.availableBudget - amount).clamp(0.0, double.infinity);

    state = state.copyWith(
      transactions: [newTx, ...state.transactions],
      spentBudget: newSpent,
      availableBudget: newAvailable,
    );
  }

  void addIncome({
    required double amount,
    required String source,
    required TransactionCategoryType category,
    String? account,
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
    );

    final newAvailable = state.availableBudget + amount;

    state = state.copyWith(
      transactions: [newTx, ...state.transactions],
      availableBudget: newAvailable,
    );
  }
}

final transactionsProvider =
    NotifierProvider<TransactionsNotifier, TransactionsState>(
        TransactionsNotifier.new);
