import '../models/budget_calculation_result.dart';
import '../models/budget_category_model.dart';
import '../models/budget_status.dart';
import '../models/fixed_bill_model.dart';

/// Pure domain calculation engine for Zero-Based Budgeting (ZBB) in Dhare.
///
/// Fundamental principle:
///   Unallocated Amount = Total Monthly Income - Total Allocated Amount
///
/// Goal of Zero-Based Budgeting:
///   Total Monthly Income == Total Allocated Amount (Unallocated == 0)
class ZeroBasedBudgetCalculator {
  /// Epsilon threshold for floating-point balance comparisons (1/10th of a cent).
  static const double _monetaryEpsilon = 0.001;

  /// Rounds a monetary value to standard two decimal places (minor currency units)
  /// to eliminate IEEE 754 floating-point inaccuracies.
  static double roundCurrency(double value) {
    if (value.isNaN || value.isInfinite) return 0.0;
    return (value * 100.0).roundToDouble() / 100.0;
  }

  /// Determines the [BudgetStatus] based on the unallocated amount.
  ///
  /// - [BudgetStatus.balanced]: unallocated amount is effectively zero.
  /// - [BudgetStatus.underallocated]: income exceeds allocations (unallocated > 0).
  /// - [BudgetStatus.overallocated]: allocations exceed income (unallocated < 0).
  static BudgetStatus determineStatus(double unallocatedAmount) {
    final rounded = roundCurrency(unallocatedAmount);
    if (rounded.abs() < _monetaryEpsilon) {
      return BudgetStatus.balanced;
    } else if (rounded > 0) {
      return BudgetStatus.underallocated;
    } else {
      return BudgetStatus.overallocated;
    }
  }

  /// Calculates Zero-Based Budgeting metrics from domain models:
  /// - [monthlyIncome]: The user's total available monthly income.
  /// - [variableCategories]: List of variable expense categories (each with assigned & spent amounts).
  /// - [fixedBills]: List of fixed monthly bills.
  /// - [baselineSavings]: Amount set aside for savings/investments from onboarding or goals.
  /// - [additionalAllocations]: Any additional manual category amounts.
  static BudgetCalculationResult calculate({
    required double monthlyIncome,
    List<BudgetCategoryModel> variableCategories = const [],
    List<FixedBillModel> fixedBills = const [],
    double baselineSavings = 0.0,
    List<double> additionalAllocations = const [],
  }) {
    final List<String> errors = [];

    // 1. Validate Monthly Income
    if (monthlyIncome.isNaN || monthlyIncome.isInfinite) {
      errors.add('Monthly income must be a valid numeric amount.');
    } else if (monthlyIncome < 0) {
      errors.add('Monthly income cannot be negative.');
    }

    // 2. Validate Baseline Savings
    if (baselineSavings.isNaN || baselineSavings.isInfinite) {
      errors.add('Baseline savings must be a valid numeric amount.');
    } else if (baselineSavings < 0) {
      errors.add('Baseline savings cannot be negative.');
    }

    // 3. Process & Validate Variable Categories
    double totalVariableAllocated = 0.0;
    double totalVariableSpent = 0.0;
    double totalVariableAvailable = 0.0;

    for (final cat in variableCategories) {
      if (cat.assignedAmount.isNaN || cat.assignedAmount.isInfinite) {
        errors.add('Assigned amount for category "${cat.name}" is invalid.');
      } else if (cat.assignedAmount < 0) {
        errors.add('Assigned amount for category "${cat.name}" cannot be negative.');
      } else {
        totalVariableAllocated += cat.assignedAmount;
      }

      if (cat.spentAmount.isNaN || cat.spentAmount.isInfinite) {
        errors.add('Spent amount for category "${cat.name}" is invalid.');
      } else if (cat.spentAmount < 0) {
        errors.add('Spent amount for category "${cat.name}" cannot be negative.');
      } else {
        totalVariableSpent += cat.spentAmount;
        // Category available amount = Allocated - Spent (clamped to 0)
        final catAvailable = (cat.assignedAmount - cat.spentAmount).clamp(0.0, double.infinity);
        totalVariableAvailable += catAvailable;
      }
    }

    // 4. Process & Validate Fixed Bills
    double totalFixedAllocated = 0.0;
    double totalFixedSpent = 0.0;
    double totalFixedAvailable = 0.0;

    for (final bill in fixedBills) {
      if (bill.amount.isNaN || bill.amount.isInfinite) {
        errors.add('Amount for fixed bill "${bill.title}" is invalid.');
      } else if (bill.amount < 0) {
        errors.add('Amount for fixed bill "${bill.title}" cannot be negative.');
      } else {
        totalFixedAllocated += bill.amount;
        if (bill.isPaid) {
          totalFixedSpent += bill.amount;
        } else {
          totalFixedAvailable += bill.amount;
        }
      }
    }

    // 5. Process & Validate Additional Allocations
    double totalAdditional = 0.0;
    for (int i = 0; i < additionalAllocations.length; i++) {
      final alloc = additionalAllocations[i];
      if (alloc.isNaN || alloc.isInfinite) {
        errors.add('Additional allocation #$i is invalid.');
      } else if (alloc < 0) {
        errors.add('Additional allocation #$i cannot be negative.');
      } else {
        totalAdditional += alloc;
      }
    }

    // If validation failed, return invalid result
    if (errors.isNotEmpty) {
      return BudgetCalculationResult.invalid(
        errors: errors,
        totalIncome: roundCurrency(monthlyIncome < 0 ? 0 : monthlyIncome),
        totalAllocated: roundCurrency(
          (totalVariableAllocated > 0 ? totalVariableAllocated : 0) +
              (totalFixedAllocated > 0 ? totalFixedAllocated : 0) +
              (baselineSavings > 0 ? baselineSavings : 0) +
              (totalAdditional > 0 ? totalAdditional : 0),
        ),
      );
    }

    // Perform clean rounded calculations
    final roundedIncome = roundCurrency(monthlyIncome);
    final roundedVariable = roundCurrency(totalVariableAllocated);
    final roundedFixed = roundCurrency(totalFixedAllocated);
    final roundedSavings = roundCurrency(baselineSavings + totalAdditional);

    final roundedAllocated = roundCurrency(
      roundedVariable + roundedFixed + roundedSavings,
    );

    final roundedUnallocated = roundCurrency(roundedIncome - roundedAllocated);
    final status = determineStatus(roundedUnallocated);

    final totalSpent = roundCurrency(totalVariableSpent + totalFixedSpent);
    final totalAvailable = roundCurrency(totalVariableAvailable + totalFixedAvailable);

    return BudgetCalculationResult(
      totalIncome: roundedIncome,
      totalAllocated: roundedAllocated,
      unallocatedAmount: roundedUnallocated,
      status: status,
      totalVariableAllocated: roundedVariable,
      totalFixedAllocated: roundedFixed,
      totalSavingsAllocated: roundedSavings,
      totalSpent: totalSpent,
      totalAvailable: totalAvailable,
      isValid: true,
      validationErrors: const [],
    );
  }

  /// Convenience calculation method directly from raw numbers.
  /// Useful for quick calculations and algorithmic verification.
  static BudgetCalculationResult calculateFromRaw({
    required double monthlyIncome,
    required List<double> allocations,
  }) {
    final List<String> errors = [];

    if (monthlyIncome.isNaN || monthlyIncome.isInfinite) {
      errors.add('Monthly income must be a valid numeric amount.');
    } else if (monthlyIncome < 0) {
      errors.add('Monthly income cannot be negative.');
    }

    double totalAllocated = 0.0;
    for (int i = 0; i < allocations.length; i++) {
      final val = allocations[i];
      if (val.isNaN || val.isInfinite) {
        errors.add('Allocation at index $i is invalid.');
      } else if (val < 0) {
        errors.add('Allocation at index $i cannot be negative ($val).');
      } else {
        totalAllocated += val;
      }
    }

    if (errors.isNotEmpty) {
      return BudgetCalculationResult.invalid(
        errors: errors,
        totalIncome: roundCurrency(monthlyIncome < 0 ? 0 : monthlyIncome),
        totalAllocated: roundCurrency(totalAllocated < 0 ? 0 : totalAllocated),
      );
    }

    final roundedIncome = roundCurrency(monthlyIncome);
    final roundedAllocated = roundCurrency(totalAllocated);
    final roundedUnallocated = roundCurrency(roundedIncome - roundedAllocated);
    final status = determineStatus(roundedUnallocated);

    return BudgetCalculationResult(
      totalIncome: roundedIncome,
      totalAllocated: roundedAllocated,
      unallocatedAmount: roundedUnallocated,
      status: status,
      totalVariableAllocated: roundedAllocated,
      totalFixedAllocated: 0.0,
      totalSavingsAllocated: 0.0,
      totalSpent: 0.0,
      totalAvailable: roundedAllocated,
      isValid: true,
      validationErrors: const [],
    );
  }
}
