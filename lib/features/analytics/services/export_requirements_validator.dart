/// Reusable validation service for Report Export requirements.
///
/// Ensures that before generating or sharing any financial report, at least
/// one valid analytics requirement module is selected.
class ExportRequirementsValidator {
  ExportRequirementsValidator._();

  /// The seven recognized and supported analytics requirement IDs.
  static const Set<String> supportedRequirementIds = {
    'trans_history', // Transaction History
    'inc_analysis', // Income Analysis
    'exp_analysis', // Expenses Analysis
    'goal_savings', // Goal Savings Analysis
    'inc_pred', // Income Prediction Analysis
    'exp_pred', // Expenses Prediction Analysis
    'debt_invest', // Debt, BNPL & Investments
  };

  /// The user-facing error message displayed when validation fails.
  static const String validationErrorMessage =
      'Please select at least one report section before generating your report.';

  /// Returns true if [selectedRequirements] contains at least one recognized
  /// valid requirement ID.
  ///
  /// Unknown, empty, or malformed requirement IDs are disregarded and do not
  /// satisfy the validation rule.
  static bool hasValidRequirements(Iterable<String>? selectedRequirements) {
    if (selectedRequirements == null) return false;
    for (final id in selectedRequirements) {
      if (supportedRequirementIds.contains(id.trim())) {
        return true;
      }
    }
    return false;
  }

  /// Returns the count of recognized valid requirement IDs present in
  /// [selectedRequirements].
  static int countValidRequirements(Iterable<String>? selectedRequirements) {
    if (selectedRequirements == null) return 0;
    return selectedRequirements
        .where((id) => supportedRequirementIds.contains(id.trim()))
        .length;
  }

  /// Validates [selectedRequirements].
  ///
  /// Returns `null` if valid (at least one valid requirement is selected), or
  /// [validationErrorMessage] if invalid.
  static String? validate(Iterable<String>? selectedRequirements) {
    if (!hasValidRequirements(selectedRequirements)) {
      return validationErrorMessage;
    }
    return null;
  }
}
