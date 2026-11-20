import '../models/analytics_customization_preferences.dart';
import '../models/dashboard_layout_preferences.dart';
import '../models/report_export_preferences.dart';

/// Platform-agnostic persistence contract for Analytics Customization,
/// Dashboard Layout, and Report Export preferences (SQLite on Android/mobile,
/// IndexedDB on Flutter Web).
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

  Future<DashboardLayoutPreferences?> getDashboardLayout({
    String profileKey = DashboardLayoutPreferences.defaultProfileKey,
  });

  Future<void> saveDashboardLayoutAtomically(
    DashboardLayoutPreferences preferences, {
    DateTime? timestamp,
    Future<void> Function(dynamic txn)? beforeCommitHook,
  });

  Future<ReportExportPreferences?> getReportExportPreferences({
    String profileKey = ReportExportPreferences.defaultProfileKey,
  });

  Future<void> saveReportExportPreferencesAtomically(
    ReportExportPreferences preferences, {
    DateTime? timestamp,
    Future<void> Function(dynamic txn)? beforeCommitHook,
  });

  Future<void> close();
}
