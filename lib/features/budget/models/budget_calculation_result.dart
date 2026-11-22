import 'budget_status.dart';

/// Immutable model holding the result of a Zero-Based Budget calculation.
class BudgetCalculationResult {
  /// Total monthly income available to the budget.
  final double totalIncome;

  /// Total amount assigned across all budget categories (variable + fixed + savings).
  final double totalAllocated;

  /// Unallocated income remaining to be budgeted (Total Income - Total Allocated).
  final double unallocatedAmount;

  /// The resulting Zero-Based Budget status (BALANCED, UNDERALLOCATED, OVERALLOCATED).
  final BudgetStatus status;

  /// Breakdown: Total allocated toward variable expense categories.
  final double totalVariableAllocated;

  /// Breakdown: Total allocated toward fixed monthly bills.
  final double totalFixedAllocated;

  /// Breakdown: Total allocated toward savings / investment reserves.
  final double totalSavingsAllocated;

  /// Breakdown: Total money spent so far across all categories.
  final double totalSpent;

  /// Breakdown: Total money available remaining across all categories (Allocated - Spent).
  /// Note: This is separate from [unallocatedAmount].
  final double totalAvailable;

  /// True if the inputs were valid and the calculation succeeded without domain errors.
  final bool isValid;

  /// Detailed validation error messages, if any.
  final List<String> validationErrors;

  const BudgetCalculationResult({
    required this.totalIncome,
    required this.totalAllocated,
    required this.unallocatedAmount,
    required this.status,
    this.totalVariableAllocated = 0.0,
    this.totalFixedAllocated = 0.0,
    this.totalSavingsAllocated = 0.0,
    this.totalSpent = 0.0,
    this.totalAvailable = 0.0,
    this.isValid = true,
    this.validationErrors = const [],
  });

  /// Factory constructor for creating an invalid calculation result with errors.
  factory BudgetCalculationResult.invalid({
    required List<String> errors,
    double totalIncome = 0.0,
    double totalAllocated = 0.0,
  }) {
    final double unallocated = totalIncome - totalAllocated;
    BudgetStatus calculatedStatus;
    if (unallocated == 0.0) {
      calculatedStatus = BudgetStatus.balanced;
    } else if (unallocated > 0.0) {
      calculatedStatus = BudgetStatus.underallocated;
    } else {
      calculatedStatus = BudgetStatus.overallocated;
    }

    return BudgetCalculationResult(
      totalIncome: totalIncome,
      totalAllocated: totalAllocated,
      unallocatedAmount: unallocated,
      status: calculatedStatus,
      isValid: false,
      validationErrors: errors,
    );
  }

  BudgetCalculationResult copyWith({
    double? totalIncome,
    double? totalAllocated,
    double? unallocatedAmount,
    BudgetStatus? status,
    double? totalVariableAllocated,
    double? totalFixedAllocated,
    double? totalSavingsAllocated,
    double? totalSpent,
    double? totalAvailable,
    bool? isValid,
    List<String>? validationErrors,
  }) {
    return BudgetCalculationResult(
      totalIncome: totalIncome ?? this.totalIncome,
      totalAllocated: totalAllocated ?? this.totalAllocated,
      unallocatedAmount: unallocatedAmount ?? this.unallocatedAmount,
      status: status ?? this.status,
      totalVariableAllocated:
          totalVariableAllocated ?? this.totalVariableAllocated,
      totalFixedAllocated: totalFixedAllocated ?? this.totalFixedAllocated,
      totalSavingsAllocated:
          totalSavingsAllocated ?? this.totalSavingsAllocated,
      totalSpent: totalSpent ?? this.totalSpent,
      totalAvailable: totalAvailable ?? this.totalAvailable,
      isValid: isValid ?? this.isValid,
      validationErrors: validationErrors ?? this.validationErrors,
    );
  }

  @override
  String toString() {
    return 'BudgetCalculationResult('
        'income: $totalIncome, '
        'allocated: $totalAllocated, '
        'unallocated: $unallocatedAmount, '
        'status: ${status.displayName}, '
        'valid: $isValid)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetCalculationResult &&
          runtimeType == other.runtimeType &&
          totalIncome == other.totalIncome &&
          totalAllocated == other.totalAllocated &&
          unallocatedAmount == other.unallocatedAmount &&
          status == other.status &&
          totalVariableAllocated == other.totalVariableAllocated &&
          totalFixedAllocated == other.totalFixedAllocated &&
          totalSavingsAllocated == other.totalSavingsAllocated &&
          totalSpent == other.totalSpent &&
          totalAvailable == other.totalAvailable &&
          isValid == other.isValid;

  @override
  int get hashCode => Object.hash(
        totalIncome,
        totalAllocated,
        unallocatedAmount,
        status,
        totalVariableAllocated,
        totalFixedAllocated,
        totalSavingsAllocated,
        totalSpent,
        totalAvailable,
        isValid,
      );
}
