import 'package:flutter/material.dart';

/// Model representing a Fixed Monthly Bill in Dhare
class FixedBillModel {
  final String id;
  String title;
  String provider;
  double amount;
  String dueDate;
  String category;
  IconData icon;
  Color iconColor;
  Color iconBg;
  bool isPaid;

  FixedBillModel({
    required this.id,
    required this.title,
    this.provider = '',
    required this.amount,
    required this.dueDate,
    this.category = 'Other',
    required this.icon,
    this.iconColor = const Color(0xFF38BDF8),
    this.iconBg = Colors.white,
    this.isPaid = false,
  });

  FixedBillModel copyWith({
    String? id,
    String? title,
    String? provider,
    double? amount,
    String? dueDate,
    String? category,
    IconData? icon,
    Color? iconColor,
    Color? iconBg,
    bool? isPaid,
  }) {
    return FixedBillModel(
      id: id ?? this.id,
      title: title ?? this.title,
      provider: provider ?? this.provider,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      iconBg: iconBg ?? this.iconBg,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}

/// Result returned from EditFixedBillScreen
class FixedBillEditResult {
  final bool isDeleted;
  final FixedBillModel? updatedBill;

  FixedBillEditResult.updated(this.updatedBill)
      : isDeleted = false;

  FixedBillEditResult.deleted()
      : isDeleted = true,
        updatedBill = null;
}
