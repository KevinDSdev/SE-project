import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prot/features/budget/models/budget_category_model.dart';
import 'package:prot/features/budget/models/budget_status.dart';
import 'package:prot/features/budget/models/fixed_bill_model.dart';
import 'package:prot/features/budget/services/zero_based_budget_calculator.dart';

void main() {
  group('ZeroBasedBudgetCalculator – Standard Scenarios from Requirements', () {
    test('Scenario 1: Balanced Budget (Income 100,000, Allocated 100,000)', () {
      final result = ZeroBasedBudgetCalculator.calculateFromRaw(
        monthlyIncome: 100000,
        allocations: [25000, 15000, 10000, 20000, 10000, 20000],
      );

      expect(result.isValid, isTrue);
      expect(result.totalIncome, equals(100000.0));
      expect(result.totalAllocated, equals(100000.0));
      expect(result.unallocatedAmount, equals(0.0));
      expect(result.status, equals(BudgetStatus.balanced));
      expect(result.status.displayName, equals('BALANCED'));
      expect(result.status.isBalanced, isTrue);
    });

    test('Scenario 2: Underallocated Budget (Income 100,000, Allocated 90,000)', () {
      final result = ZeroBasedBudgetCalculator.calculateFromRaw(
        monthlyIncome: 100000,
        allocations: [25000, 15000, 10000, 20000, 10000, 10000],
      );

      expect(result.isValid, isTrue);
      expect(result.totalIncome, equals(100000.0));
      expect(result.totalAllocated, equals(90000.0));
      expect(result.unallocatedAmount, equals(10000.0));
      expect(result.status, equals(BudgetStatus.underallocated));
      expect(result.status.displayName, equals('UNDERALLOCATED'));
      expect(result.status.isUnderallocated, isTrue);
    });

    test('Scenario 3: Overallocated Budget (Income 100,000, Allocated 110,000)', () {
      final result = ZeroBasedBudgetCalculator.calculateFromRaw(
        monthlyIncome: 100000,
        allocations: [30000, 20000, 15000, 25000, 10000, 10000],
      );

      expect(result.isValid, isTrue);
      expect(result.totalIncome, equals(100000.0));
      expect(result.totalAllocated, equals(110000.0));
      expect(result.unallocatedAmount, equals(-10000.0));
      expect(result.status, equals(BudgetStatus.overallocated));
      expect(result.status.displayName, equals('OVERALLOCATED'));
      expect(result.status.isOverallocated, isTrue);
    });

    test('Scenario 4: No Allocations (Income 100,000, Allocated 0)', () {
      final result = ZeroBasedBudgetCalculator.calculateFromRaw(
        monthlyIncome: 100000,
        allocations: [],
      );

      expect(result.isValid, isTrue);
      expect(result.totalIncome, equals(100000.0));
      expect(result.totalAllocated, equals(0.0));
      expect(result.unallocatedAmount, equals(100000.0));
      expect(result.status, equals(BudgetStatus.underallocated));
    });

    test('Scenario 5: Zero Income and Zero Allocations (0 - 0 = 0)', () {
      final result = ZeroBasedBudgetCalculator.calculateFromRaw(
        monthlyIncome: 0,
        allocations: [],
      );

      expect(result.isValid, isTrue);
      expect(result.totalIncome, equals(0.0));
      expect(result.totalAllocated, equals(0.0));
      expect(result.unallocatedAmount, equals(0.0));
      expect(result.status, equals(BudgetStatus.balanced));
    });

    test('Scenario 6: Decimal Monetary Precision (100000.50 - 100000.25 = 0.25)', () {
      final result = ZeroBasedBudgetCalculator.calculateFromRaw(
        monthlyIncome: 100000.50,
        allocations: [50000.10, 50000.15],
      );

      expect(result.isValid, isTrue);
      expect(result.totalIncome, equals(100000.50));
      expect(result.totalAllocated, equals(100000.25));
      expect(result.unallocatedAmount, equals(0.25));
      expect(result.status, equals(BudgetStatus.underallocated));
    });

    test('Monetary Rounding eliminates IEEE 754 floating-point inaccuracies', () {
      // 0.1 + 0.2 in raw IEEE 754 is 0.30000000000000004
      final result = ZeroBasedBudgetCalculator.calculateFromRaw(
        monthlyIncome: 0.30,
        allocations: [0.10, 0.20],
      );

      expect(result.totalIncome, equals(0.30));
      expect(result.totalAllocated, equals(0.30));
      expect(result.unallocatedAmount, equals(0.0));
      expect(result.status, equals(BudgetStatus.balanced));
    });
  });

  group('ZeroBasedBudgetCalculator – Input Validation and Edge Cases', () {
    test('Negative monthly income is rejected with validation error', () {
      final result = ZeroBasedBudgetCalculator.calculateFromRaw(
        monthlyIncome: -50000,
        allocations: [10000],
      );

      expect(result.isValid, isFalse);
      expect(result.validationErrors, contains('Monthly income cannot be negative.'));
    });

    test('Negative allocation amount is rejected with validation error', () {
      final result = ZeroBasedBudgetCalculator.calculateFromRaw(
        monthlyIncome: 50000,
        allocations: [10000, -2000],
      );

      expect(result.isValid, isFalse);
      expect(result.validationErrors.any((e) => e.contains('cannot be negative')), isTrue);
    });

    test('NaN and Infinite values are rejected gracefully', () {
      final nanResult = ZeroBasedBudgetCalculator.calculateFromRaw(
        monthlyIncome: double.nan,
        allocations: [1000],
      );

      expect(nanResult.isValid, isFalse);
      expect(nanResult.validationErrors.any((e) => e.contains('valid numeric')), isTrue);

      final infResult = ZeroBasedBudgetCalculator.calculateFromRaw(
        monthlyIncome: 50000,
        allocations: [double.infinity],
      );

      expect(infResult.isValid, isFalse);
    });
  });

  group('ZeroBasedBudgetCalculator – Domain Models Integration', () {
    late List<BudgetCategoryModel> sampleCategories;
    late List<FixedBillModel> sampleBills;

    setUp(() {
      sampleCategories = [
        BudgetCategoryModel(
          id: 'food',
          name: 'Food & Groceries',
          group: 'Needs',
          icon: Icons.shopping_basket,
          color: Colors.amber,
          assignedAmount: 65000,
          spentAmount: 20000,
        ),
        BudgetCategoryModel(
          id: 'dining',
          name: 'Dining & Takeout',
          group: 'Wants',
          icon: Icons.restaurant,
          color: Colors.red,
          assignedAmount: 35000,
          spentAmount: 12000,
        ),
        BudgetCategoryModel(
          id: 'transport',
          name: 'Travel & Transport',
          group: 'Needs',
          icon: Icons.directions_bus,
          color: Colors.blue,
          assignedAmount: 30000,
          spentAmount: 10000,
        ),
      ];

      sampleBills = [
        FixedBillModel(
          id: 'rent',
          title: 'Apartment Rent',
          amount: 120000,
          dueDate: '1st',
          icon: Icons.apartment,
          isPaid: true,
        ),
        FixedBillModel(
          id: 'ceb',
          title: 'CEB Electricity & Water',
          amount: 45000,
          dueDate: '10th',
          icon: Icons.bolt,
          isPaid: false,
        ),
        FixedBillModel(
          id: 'dialog',
          title: 'Dialog & Insurance',
          amount: 25000,
          dueDate: '15th',
          icon: Icons.wifi,
          isPaid: false,
        ),
      ];
    });

    test('Dhare Screen 01 Baseline Calculation matches exactly', () {
      // Income: 450,000
      // Variable: 65,000 + 35,000 + 30,000 = 130,000
      // Fixed: 120,000 + 45,000 + 25,000 = 190,000
      // Baseline Savings: 25,000
      // Total Allocated: 345,000
      // Expected Unallocated: 105,000
      final result = ZeroBasedBudgetCalculator.calculate(
        monthlyIncome: 450000,
        variableCategories: sampleCategories,
        fixedBills: sampleBills,
        baselineSavings: 25000,
      );

      expect(result.isValid, isTrue);
      expect(result.totalIncome, equals(450000.0));
      expect(result.totalVariableAllocated, equals(130000.0));
      expect(result.totalFixedAllocated, equals(190000.0));
      expect(result.totalSavingsAllocated, equals(25000.0));
      expect(result.totalAllocated, equals(345000.0));
      expect(result.unallocatedAmount, equals(105000.0));
      expect(result.status, equals(BudgetStatus.underallocated));
    });

    test('Maintains strict separation between Allocated, Spent, and Available amounts', () {
      final result = ZeroBasedBudgetCalculator.calculate(
        monthlyIncome: 450000,
        variableCategories: sampleCategories,
        fixedBills: sampleBills,
        baselineSavings: 25000,
      );

      // Variable spent: 20,000 + 12,000 + 10,000 = 42,000
      // Fixed bill spent (rent isPaid == true): 120,000
      // Total spent = 162,000
      expect(result.totalSpent, equals(162000.0));

      // Variable available: (65k-20k) + (35k-12k) + (30k-10k) = 45k + 23k + 20k = 88,000
      // Fixed available (unpaid bills): 45k + 25k = 70,000
      // Total available = 158,000
      expect(result.totalAvailable, equals(158000.0));

      // Distinct from unallocatedAmount (which is remaining income to be assigned)
      expect(result.unallocatedAmount, equals(105000.0));
      expect(result.unallocatedAmount != result.totalAvailable, isTrue);
    });

    test('Handles category creation and recalculates totals correctly', () {
      final updatedCategories = List<BudgetCategoryModel>.from(sampleCategories);
      updatedCategories.add(
        BudgetCategoryModel(
          id: 'education',
          name: 'Education',
          group: 'Needs',
          icon: Icons.school,
          color: Colors.purple,
          assignedAmount: 105000,
          spentAmount: 0,
        ),
      );

      final result = ZeroBasedBudgetCalculator.calculate(
        monthlyIncome: 450000,
        variableCategories: updatedCategories,
        fixedBills: sampleBills,
        baselineSavings: 25000,
      );

      // Total Allocated: 345,000 + 105,000 = 450,000
      // Unallocated: 0 -> BALANCED
      expect(result.totalAllocated, equals(450000.0));
      expect(result.unallocatedAmount, equals(0.0));
      expect(result.status, equals(BudgetStatus.balanced));
    });

    test('Handles category editing (changing assigned amount) and recalculates', () {
      final updatedCategories = sampleCategories.map((c) {
        if (c.id == 'food') {
          return c.copyWith(assignedAmount: 75000); // +10,000
        }
        return c;
      }).toList();

      final result = ZeroBasedBudgetCalculator.calculate(
        monthlyIncome: 450000,
        variableCategories: updatedCategories,
        fixedBills: sampleBills,
        baselineSavings: 25000,
      );

      expect(result.totalVariableAllocated, equals(140000.0));
      expect(result.totalAllocated, equals(355000.0));
      expect(result.unallocatedAmount, equals(95000.0));
      expect(result.status, equals(BudgetStatus.underallocated));
    });

    test('Handles category deletion and recalculates', () {
      final updatedCategories = sampleCategories.where((c) => c.id != 'food').toList();

      final result = ZeroBasedBudgetCalculator.calculate(
        monthlyIncome: 450000,
        variableCategories: updatedCategories,
        fixedBills: sampleBills,
        baselineSavings: 25000,
      );

      // Variable allocated: 35k + 30k = 65,000
      expect(result.totalVariableAllocated, equals(65000.0));
      expect(result.totalAllocated, equals(280000.0));
      expect(result.unallocatedAmount, equals(170000.0));
    });

    test('Handles monthly income update and recalculates', () {
      final result = ZeroBasedBudgetCalculator.calculate(
        monthlyIncome: 300000, // Reduced from 450,000
        variableCategories: sampleCategories, // 130,000
        fixedBills: sampleBills,             // 190,000
        baselineSavings: 25000,              // 25,000
      );

      // Total Allocated: 345,000
      // Income: 300,000
      // Unallocated: 300,000 - 345,000 = -45,000 -> OVERALLOCATED
      expect(result.totalAllocated, equals(345000.0));
      expect(result.unallocatedAmount, equals(-45000.0));
      expect(result.status, equals(BudgetStatus.overallocated));
    });
  });
}
