import '../models/analytics_customization_preferences.dart';

/// Platform-agnostic persistence contract for Analytics Customization
/// preferences (SQLite on Android/mobile, IndexedDB on Flutter Web).
abstract class AnalyticsCustomizationStorage {
  bool get isOpen;

  Future<void> init();

  Future<AnalyticsCustomizationPreferences?> getPreferences({
    String profileKey = AnalyticsCustomizationPreferences.defaultProfileKey,
  });

  Future<void> savePreferencesAtomically(
    AnalyticsCustomizationPreferences preferences, {
    DateTime? timestamp,
    Future<void> Function(dynamic txn)? beforeCommitHook,
  });

  Future<void> close();
}
