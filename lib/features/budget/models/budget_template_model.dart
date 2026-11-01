import 'package:flutter/material.dart';

/// Represents a category allocation inside a budget template.
class BudgetTemplateCategory {
  final String name;
  final double assignedAmount;
  final int percentage;
  final IconData icon;
  final Color iconColor;
  final Color barColor;

  const BudgetTemplateCategory({
    required this.name,
    required this.assignedAmount,
    required this.percentage,
    required this.icon,
    required this.iconColor,
    required this.barColor,
  });
}

/// Represents a budget template (Essential, Student, Family, Custom).
class BudgetTemplate {
  final String id;
  final String name;
  final String description;
  final String focusText;
  final double availableAmount;
  final double assignedAmount;
  final List<BudgetTemplateCategory> categories;
  final IconData icon;
  final Color iconColor;

  const BudgetTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.focusText,
    required this.availableAmount,
    required this.assignedAmount,
    required this.categories,
    required this.icon,
    required this.iconColor,
  });
}

/// Standard predefined templates matching Dhare Screens 07, 07A, 07B, 07C, 07D.
class PredefinedBudgetTemplates {
  static const essential = BudgetTemplate(
    id: 'essential',
    name: 'Essential Budget',
    description: 'Balanced framework for daily necessities.',
    focusText: 'Focus: Bills, Groceries, Transport & Savings',
    availableAmount: 100000,
    assignedAmount: 100000,
    icon: Icons.shopping_cart_rounded,
    iconColor: Color(0xFFEF4444),
    categories: [
      BudgetTemplateCategory(
        name: 'Bills & Utilities',
        assignedAmount: 30000,
        percentage: 30,
        icon: Icons.bolt_rounded,
        iconColor: Color(0xFFEAB308),
        barColor: Color(0xFF38BDF8),
      ),
      BudgetTemplateCategory(
        name: 'Groceries',
        assignedAmount: 25000,
        percentage: 25,
        icon: Icons.shopping_basket_rounded,
        iconColor: Color(0xFFF97316),
        barColor: Color(0xFFF59E0B),
      ),
      BudgetTemplateCategory(
        name: 'Transport',
        assignedAmount: 15000,
        percentage: 15,
        icon: Icons.directions_bus_filled_rounded,
        iconColor: Color(0xFF0284C7),
        barColor: Color(0xFF10B981),
      ),
      BudgetTemplateCategory(
        name: 'Savings',
        assignedAmount: 20000,
        percentage: 20,
        icon: Icons.savings_rounded,
        iconColor: Color(0xFF0D9488),
        barColor: Color(0xFF98E836),
      ),
      BudgetTemplateCategory(
        name: 'Miscellaneous',
        assignedAmount: 10000,
        percentage: 10,
        icon: Icons.inventory_2_rounded,
        iconColor: Color(0xFFD97706),
        barColor: Color(0xFFA855F7),
      ),
    ],
  );

  static const student = BudgetTemplate(
    id: 'student',
    name: 'Student Budget',
    description: 'Optimized for campus life and study costs.',
    focusText: 'Focus: Education, Food, Transport & Personal',
    availableAmount: 100000,
    assignedAmount: 100000,
    icon: Icons.school_rounded,
    iconColor: Color(0xFFEAB308),
    categories: [
      BudgetTemplateCategory(
        name: 'Education & Courses',
        assignedAmount: 30000,
        percentage: 30,
        icon: Icons.school_rounded,
        iconColor: Color(0xFFEAB308),
        barColor: Color(0xFF38BDF8),
      ),
      BudgetTemplateCategory(
        name: 'Food & Meals',
        assignedAmount: 25000,
        percentage: 25,
        icon: Icons.restaurant_rounded,
        iconColor: Color(0xFFEF4444),
        barColor: Color(0xFFF59E0B),
      ),
      BudgetTemplateCategory(
        name: 'Travel & Transport',
        assignedAmount: 15000,
        percentage: 15,
        icon: Icons.directions_bus_filled_rounded,
        iconColor: Color(0xFF0284C7),
        barColor: Color(0xFF38BDF8),
      ),
      BudgetTemplateCategory(
        name: 'Emergency Savings',
        assignedAmount: 20000,
        percentage: 20,
        icon: Icons.savings_rounded,
        iconColor: Color(0xFF0D9488),
        barColor: Color(0xFF98E836),
      ),
      BudgetTemplateCategory(
        name: 'Personal Expenses',
        assignedAmount: 10000,
        percentage: 10,
        icon: Icons.account_balance_wallet_rounded,
        iconColor: Color(0xFFD97706),
        barColor: Color(0xFFA855F7),
      ),
    ],
  );

  static const family = BudgetTemplate(
    id: 'family',
    name: 'Family Budget',
    description: 'Comprehensive plan for multi-member homes.',
    focusText: 'Focus: Household Bills, Groceries, Family & Savings',
    availableAmount: 100000,
    assignedAmount: 100000,
    icon: Icons.groups_rounded,
    iconColor: Color(0xFFEC4899),
    categories: [
      BudgetTemplateCategory(
        name: 'Household Bills',
        assignedAmount: 25000,
        percentage: 25,
        icon: Icons.home_rounded,
        iconColor: Color(0xFFEA580C),
        barColor: Color(0xFF38BDF8),
      ),
      BudgetTemplateCategory(
        name: 'Groceries & Food',
        assignedAmount: 25000,
        percentage: 25,
        icon: Icons.shopping_basket_rounded,
        iconColor: Color(0xFFF97316),
        barColor: Color(0xFFF59E0B),
      ),
      BudgetTemplateCategory(
        name: 'Family Savings',
        assignedAmount: 20000,
        percentage: 20,
        icon: Icons.savings_rounded,
        iconColor: Color(0xFF0D9488),
        barColor: Color(0xFF10B981),
      ),
      BudgetTemplateCategory(
        name: 'Education & Kids',
        assignedAmount: 15000,
        percentage: 15,
        icon: Icons.school_rounded,
        iconColor: Color(0xFF6366F1),
        barColor: Color(0xFFA855F7),
      ),
      BudgetTemplateCategory(
        name: 'Transport',
        assignedAmount: 10000,
        percentage: 10,
        icon: Icons.directions_car_rounded,
        iconColor: Color(0xFFEF4444),
        barColor: Color(0xFFA855F7),
      ),
      BudgetTemplateCategory(
        name: 'Health & Personal',
        assignedAmount: 5000,
        percentage: 5,
        icon: Icons.favorite_rounded,
        iconColor: Color(0xFFEF4444),
        barColor: Color(0xFFF43F5E),
      ),
    ],
  );

  static const custom = BudgetTemplate(
    id: 'custom',
    name: 'Custom Budget',
    description: 'Blank canvas with zero predefined caps.',
    focusText: 'Start with 100% user-defined categories',
    availableAmount: 100000,
    assignedAmount: 0,
    icon: Icons.tune_rounded,
    iconColor: Color(0xFF0EA5E9),
    categories: [],
  );

  static const List<BudgetTemplate> all = [
    essential,
    student,
    family,
    custom,
  ];
}
