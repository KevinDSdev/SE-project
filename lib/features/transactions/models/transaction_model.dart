enum TransactionType { expense, income }

enum TransactionCategoryType {
  // Expense categories
  dining,
  groceries,
  transport,
  shopping,
  bills,
  housing,
  savings,
  entertainment,

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
  final String? note;
  final String? receiptFileName;
  final int? receiptItemCount;
  final int? receiptMatchPercent;
  final String? receiptImagePath;

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
    this.note,
    this.receiptFileName,
    this.receiptItemCount,
    this.receiptMatchPercent,
    this.receiptImagePath,
  });

  TransactionModel copyWith({
    String? id,
    String? merchant,
    String? subtitle,
    double? amount,
    double? cashback,
    TransactionType? type,
    TransactionCategoryType? category,
    DateTime? date,
    String? account,
    String? note,
    String? receiptFileName,
    int? receiptItemCount,
    int? receiptMatchPercent,
    String? receiptImagePath,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      merchant: merchant ?? this.merchant,
      subtitle: subtitle ?? this.subtitle,
      amount: amount ?? this.amount,
      cashback: cashback ?? this.cashback,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      account: account ?? this.account,
      note: note ?? this.note,
      receiptFileName: receiptFileName ?? this.receiptFileName,
      receiptItemCount: receiptItemCount ?? this.receiptItemCount,
      receiptMatchPercent: receiptMatchPercent ?? this.receiptMatchPercent,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
    );
  }
}
