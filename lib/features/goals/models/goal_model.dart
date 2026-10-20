import 'package:flutter/material.dart';

class GoalModel {
  final String id;
  final String title;
  final String subtitle;
  final double currentAmount;
  final double targetAmount;
  final double monthlyContribution;
  final Color color;
  final Color iconBg;
  final IconData icon;
  final String? badgeText;
  final bool isAutoSaving;

  const GoalModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.currentAmount,
    required this.targetAmount,
    required this.monthlyContribution,
    required this.color,
    required this.iconBg,
    required this.icon,
    this.badgeText,
    this.isAutoSaving = false,
  });

  double get progress => (currentAmount / targetAmount).clamp(0.0, 1.0);
  int get percentage => ((currentAmount / targetAmount) * 100).round();

  GoalModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    double? currentAmount,
    double? targetAmount,
    double? monthlyContribution,
    Color? color,
    Color? iconBg,
    IconData? icon,
    String? badgeText,
    bool? isAutoSaving,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      currentAmount: currentAmount ?? this.currentAmount,
      targetAmount: targetAmount ?? this.targetAmount,
      monthlyContribution: monthlyContribution ?? this.monthlyContribution,
      color: color ?? this.color,
      iconBg: iconBg ?? this.iconBg,
      icon: icon ?? this.icon,
      badgeText: badgeText ?? this.badgeText,
      isAutoSaving: isAutoSaving ?? this.isAutoSaving,
    );
  }
}
