import 'package:flutter/material.dart';

/// Model representing a budget category in Dhare
class BudgetCategoryModel {
  final String id;
  String name;
  String group;
  IconData icon;
  Color color;
  Color iconBg;
  double assignedAmount;
  double spentAmount;
  String description;

  BudgetCategoryModel({
    required this.id,
    required this.name,
    required this.group,
    required this.icon,
    required this.color,
    this.iconBg = Colors.white,
    required this.assignedAmount,
    this.spentAmount = 0.0,
    this.description = '',
  });

  double get availableAmount => (assignedAmount - spentAmount).clamp(0.0, double.infinity);

  double get progress => assignedAmount > 0 ? (spentAmount / assignedAmount).clamp(0.0, 1.0) : 0.0;

  BudgetCategoryModel copyWith({
    String? id,
    String? name,
    String? group,
    IconData? icon,
    Color? color,
    Color? iconBg,
    double? assignedAmount,
    double? spentAmount,
    String? description,
  }) {
    return BudgetCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      group: group ?? this.group,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      iconBg: iconBg ?? this.iconBg,
      assignedAmount: assignedAmount ?? this.assignedAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      description: description ?? this.description,
    );
  }
}

/// Result returned from EditBudgetCategoryScreen
class CategoryEditResult {
  final bool isDeleted;
  final BudgetCategoryModel? updatedCategory;

  CategoryEditResult.updated(this.updatedCategory) : isDeleted = false;
  CategoryEditResult.deleted() : isDeleted = true, updatedCategory = null;
}
