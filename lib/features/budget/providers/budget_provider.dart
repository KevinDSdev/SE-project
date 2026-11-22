import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/budget_calculation_result.dart';
import '../models/budget_category_model.dart';
import '../models/fixed_bill_model.dart';
import '../services/zero_based_budget_calculator.dart';

/// State representation of the user's active monthly budget.
class MonthlyBudgetState {
  final double monthlyIncome;
  final double baselineSavings;
  final List<BudgetCategoryModel> variableCategories;
  final List<FixedBillModel> fixedBills;
  final BudgetCalculationResult calculation;

  const MonthlyBudgetState({
    required this.monthlyIncome,
    this.baselineSavings = 25000.0,
    required this.variableCategories,
    required this.fixedBills,
    required this.calculation,
  });

  MonthlyBudgetState copyWith({
    double? monthlyIncome,
    double? baselineSavings,
    List<BudgetCategoryModel>? variableCategories,
    List<FixedBillModel>? fixedBills,
    BudgetCalculationResult? calculation,
  }) {
    return MonthlyBudgetState(
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      baselineSavings: baselineSavings ?? this.baselineSavings,
      variableCategories: variableCategories ?? this.variableCategories,
      fixedBills: fixedBills ?? this.fixedBills,
      calculation: calculation ?? this.calculation,
    );
  }
}

/// Riverpod Notifier managing the active monthly budget and its Zero-Based calculations.
class BudgetNotifier extends Notifier<MonthlyBudgetState> {
  static List<BudgetCategoryModel> get initialVariableCategories => [
        BudgetCategoryModel(
          id: 'food_groceries',
          name: 'Food & Groceries',
          group: 'Needs (Variable)',
          icon: Icons.shopping_basket_rounded,
          color: const Color(0xFFF59E0B),
          iconBg: Colors.white,
          assignedAmount: 65000,
          spentAmount: 20000,
          description: 'Assigned to variable monthly household supplies.',
        ),
        BudgetCategoryModel(
          id: 'dining_takeout',
          name: 'Dining & Takeout',
          group: 'Wants',
          icon: Icons.restaurant_rounded,
          color: const Color(0xFFE11D48),
          iconBg: const Color(0xFFE11D48),
          assignedAmount: 35000,
          spentAmount: 12000,
          description: 'Dining out, cafes, takeaways and fast food.',
        ),
        BudgetCategoryModel(
          id: 'travel_transport',
          name: 'Travel & Transport',
          group: 'Needs (Variable)',
          icon: Icons.directions_bus_rounded,
          color: const Color(0xFF2563EB),
          iconBg: Colors.white,
          assignedAmount: 30000,
          spentAmount: 10000,
          description: 'Daily commute, fuel, public transit and ride-shares.',
        ),
      ];

  static List<FixedBillModel> get initialFixedBills => [
        FixedBillModel(
          id: 'apartment_rent',
          title: 'Apartment Rent',
          amount: 120000,
          provider: 'Mr. Sandun (Landlord)',
          dueDate: 'Day 1 of every month',
          category: 'Rent',
          icon: Icons.apartment_rounded,
          iconColor: const Color(0xFF334155),
          iconBg: Colors.white,
          isPaid: false,
        ),
        FixedBillModel(
          id: 'ceb_bills',
          title: 'CEB Electricity & Water',
          amount: 45000,
          provider: 'CEB / NWSDB',
          dueDate: 'Day 10 of every month',
          category: 'Electricity',
          icon: Icons.bolt_rounded,
          iconColor: const Color(0xFFDC2626),
          iconBg: const Color(0xFFFEF08A),
          isPaid: false,
        ),
        FixedBillModel(
          id: 'dialog_insurance',
          title: 'Dialog & Insurance',
          amount: 25000,
          provider: 'Dialog Axiata & Ceylinco',
          dueDate: 'Day 15 of every month',
          category: 'Internet',
          icon: Icons.change_history_rounded,
          iconColor: const Color(0xFFE11D48),
          iconBg: Colors.white,
          isPaid: false,
        ),
      ];

  static MonthlyBudgetState createInitialState() {
    const income = 450000.0;
    const savings = 25000.0;
    final categories = initialVariableCategories;
    final bills = initialFixedBills;

    final calculation = ZeroBasedBudgetCalculator.calculate(
      monthlyIncome: income,
      variableCategories: categories,
      fixedBills: bills,
      baselineSavings: savings,
    );

    return MonthlyBudgetState(
      monthlyIncome: income,
      baselineSavings: savings,
      variableCategories: categories,
      fixedBills: bills,
      calculation: calculation,
    );
  }

  @override
  MonthlyBudgetState build() => createInitialState();

  /// Helper to trigger recalculation whenever budget inputs change.
  void _recalculate({
    double? income,
    double? savings,
    List<BudgetCategoryModel>? categories,
    List<FixedBillModel>? bills,
  }) {
    final activeIncome = income ?? state.monthlyIncome;
    final activeSavings = savings ?? state.baselineSavings;
    final activeCategories = categories ?? state.variableCategories;
    final activeBills = bills ?? state.fixedBills;

    final calculation = ZeroBasedBudgetCalculator.calculate(
      monthlyIncome: activeIncome,
      variableCategories: activeCategories,
      fixedBills: activeBills,
      baselineSavings: activeSavings,
    );

    state = state.copyWith(
      monthlyIncome: activeIncome,
      baselineSavings: activeSavings,
      variableCategories: activeCategories,
      fixedBills: activeBills,
      calculation: calculation,
    );
  }

  /// Updates the user's total available monthly income and recalculates.
  void setMonthlyIncome(double income) {
    _recalculate(income: income);
  }

  /// Updates baseline savings reserve and recalculates.
  void setBaselineSavings(double savings) {
    _recalculate(savings: savings);
  }

  /// Adds a new budget category and recalculates.
  void addCategory(BudgetCategoryModel category) {
    final updated = [...state.variableCategories, category];
    _recalculate(categories: updated);
  }

  /// Updates an existing category allocation and recalculates.
  void updateCategory(BudgetCategoryModel category) {
    final updated = state.variableCategories.map((c) {
      return c.id == category.id ? category : c;
    }).toList();
    _recalculate(categories: updated);
  }

  /// Deletes a category and recalculates.
  void deleteCategory(String categoryId) {
    final updated = state.variableCategories
        .where((c) => c.id != categoryId)
        .toList();
    _recalculate(categories: updated);
  }

  /// Adds a new fixed monthly bill and recalculates.
  void addFixedBill(FixedBillModel bill) {
    final updated = [...state.fixedBills, bill];
    _recalculate(bills: updated);
  }

  /// Updates an existing fixed monthly bill and recalculates.
  void updateFixedBill(FixedBillModel bill) {
    final updated = state.fixedBills.map((b) {
      return b.id == bill.id ? bill : b;
    }).toList();
    _recalculate(bills: updated);
  }

  /// Deletes a fixed bill and recalculates.
  void deleteFixedBill(String billId) {
    final updated = state.fixedBills.where((b) => b.id != billId).toList();
    _recalculate(bills: updated);
  }

  /// Toggles the paid status of a bill and updates spent/available tracking.
  void toggleBillPaid(String billId) {
    final updated = state.fixedBills.map((b) {
      if (b.id == billId) {
        return b.copyWith(isPaid: !b.isPaid);
      }
      return b;
    }).toList();
    _recalculate(bills: updated);
  }

  /// Resets state back to the Figma default baseline.
  void resetToBaseline() {
    state = createInitialState();
  }
}

final budgetProvider =
    NotifierProvider<BudgetNotifier, MonthlyBudgetState>(BudgetNotifier.new);
