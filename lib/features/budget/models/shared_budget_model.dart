import 'package:flutter/material.dart';

/// Represents a shared budget category with assigned, available, and used amounts.
class SharedBudgetCategory {
  final String id;
  String name;
  double assignedAmount;
  double availableAmount;
  double usedAmount;
  IconData icon;
  Color iconColor;
  Color barColor;

  SharedBudgetCategory({
    required this.id,
    required this.name,
    required this.assignedAmount,
    required this.availableAmount,
    required this.usedAmount,
    this.icon = Icons.category_rounded,
    this.iconColor = const Color(0xFF38BDF8),
    this.barColor = const Color(0xFF38BDF8),
  });

  SharedBudgetCategory copyWith({
    String? id,
    String? name,
    double? assignedAmount,
    double? availableAmount,
    double? usedAmount,
    IconData? icon,
    Color? iconColor,
    Color? barColor,
  }) {
    return SharedBudgetCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      assignedAmount: assignedAmount ?? this.assignedAmount,
      availableAmount: availableAmount ?? this.availableAmount,
      usedAmount: usedAmount ?? this.usedAmount,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      barColor: barColor ?? this.barColor,
    );
  }
}

/// Represents a member in a shared budget group.
class SharedBudgetMember {
  final String id;
  final String name;
  final String role; // 'Owner' or 'Active Member'
  final String joinDate; // 'Created Oct 2026' or 'Joined Oct 15'
  final String badgeText; // 'OWNER' or 'MEMBER'
  final Color badgeColor;
  final String avatarInitials;
  final Color avatarColor;

  SharedBudgetMember({
    required this.id,
    required this.name,
    required this.role,
    required this.joinDate,
    required this.badgeText,
    required this.badgeColor,
    required this.avatarInitials,
    required this.avatarColor,
  });

  SharedBudgetMember copyWith({
    String? id,
    String? name,
    String? role,
    String? joinDate,
    String? badgeText,
    Color? badgeColor,
    String? avatarInitials,
    Color? avatarColor,
  }) {
    return SharedBudgetMember(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      joinDate: joinDate ?? this.joinDate,
      badgeText: badgeText ?? this.badgeText,
      badgeColor: badgeColor ?? this.badgeColor,
      avatarInitials: avatarInitials ?? this.avatarInitials,
      avatarColor: avatarColor ?? this.avatarColor,
    );
  }
}

/// Represents the complete Shared Budget entity matching Screen 06A, 06B, 06C.
class SharedBudget {
  final String id;
  String name;
  String goal;
  String period;
  double totalSharedFunds;
  double totalUsed;
  double totalAvailable;
  List<SharedBudgetCategory> categories;
  List<SharedBudgetMember> members;

  SharedBudget({
    required this.id,
    required this.name,
    required this.goal,
    required this.period,
    required this.totalSharedFunds,
    required this.totalUsed,
    required this.totalAvailable,
    required this.categories,
    required this.members,
  });

  SharedBudget copyWith({
    String? id,
    String? name,
    String? goal,
    String? period,
    double? totalSharedFunds,
    double? totalUsed,
    double? totalAvailable,
    List<SharedBudgetCategory>? categories,
    List<SharedBudgetMember>? members,
  }) {
    return SharedBudget(
      id: id ?? this.id,
      name: name ?? this.name,
      goal: goal ?? this.goal,
      period: period ?? this.period,
      totalSharedFunds: totalSharedFunds ?? this.totalSharedFunds,
      totalUsed: totalUsed ?? this.totalUsed,
      totalAvailable: totalAvailable ?? this.totalAvailable,
      categories: categories ??
          this.categories.map((c) => c.copyWith()).toList(),
      members: members ??
          this.members.map((m) => m.copyWith()).toList(),
    );
  }
}
