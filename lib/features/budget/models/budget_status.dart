/// Represents the three states of a Zero-Based Budget in Dhare.
///
/// In Zero-Based Budgeting (ZBB):
/// - [balanced]: Total Income == Total Allocated (Unallocated == 0).
/// - [underallocated]: Total Income > Total Allocated (Unallocated > 0, money left to assign).
/// - [overallocated]: Total Income < Total Allocated (Unallocated < 0, allocations exceed income).
enum BudgetStatus {
  balanced,
  underallocated,
  overallocated;

  /// Human-readable title
  String get displayName {
    switch (this) {
      case BudgetStatus.balanced:
        return 'BALANCED';
      case BudgetStatus.underallocated:
        return 'UNDERALLOCATED';
      case BudgetStatus.overallocated:
        return 'OVERALLOCATED';
    }
  }

  /// Whether the budget has reached the zero-based goal of 0 unallocated funds
  bool get isBalanced => this == BudgetStatus.balanced;

  /// Whether income is greater than allocations
  bool get isUnderallocated => this == BudgetStatus.underallocated;

  /// Whether allocations exceed available income
  bool get isOverallocated => this == BudgetStatus.overallocated;
}
