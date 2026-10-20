enum TransactionType { expense, income }

enum TransactionCategoryType {
  // Expense categories
  dining,
  groceries,
  transport,
  shopping,
  bills,
  savings,

  // Income categories
  salary,
  freelance,
  dividends,
  rental,
  rewards,
  transfers,
}

class TransactionModel {
  final String id;
  final String merchant;
  final String subtitle;
  final double amount;
  final double cashback;
  final TransactionType type;
  final TransactionCategoryType category;
  final DateTime date;
  final String? account;

  TransactionModel({
    required this.id,
    required this.merchant,
    required this.subtitle,
    required this.amount,
    this.cashback = 0.0,
    required this.type,
    required this.category,
    required this.date,
    this.account,
  });
}
