import 'package:flutter/foundation.dart';

import '../models/report_export_preferences.dart';
import 'analytics_customization_repository.dart';
import 'analytics_customization_storage.dart';

/// Single source of persistence for Report Export configuration preferences
/// (latest selected format, period, account scope, and analytics requirements).
///
/// Reuses the shared [AnalyticsCustomizationStorage] connection so Android
/// (SQLite) and Flutter Web (IndexedDB) operate on a single database without
/// opening duplicate connections.
class ReportExportRepository {
  static ReportExportRepository? _instance;

  static ReportExportRepository get instance =>
      _instance ??= ReportExportRepository();

  final AnalyticsCustomizationStorage _storage;
  ReportExportPreferences _cachedPreferences =
      const ReportExportPreferences.defaults();
  bool _isInitialized = false;
  Future<void>? _pendingWrite;

  ReportExportRepository({AnalyticsCustomizationStorage? storage})
    : _storage = storage ?? AnalyticsCustomizationRepository.instance.storage;

  bool get isInitialized => _isInitialized;

  /// Synchronous access to the currently cached export configuration for
  /// Riverpod `Notifier.build()` methods.
  ReportExportPreferences get currentPreferences => _cachedPreferences;

  /// Initializes the shared storage backend (if not already open) and loads
  /// any saved Report Export configuration.
  ///
  /// If a saved record exists, it is restored without overwriting it.
  /// If no saved record exists, the existing default export configuration is
  /// used. Safe to call more than once.
  Future<ReportExportPreferences> init() async {
    await _storage.init();

    final existingRow = await _storage.getReportExportPreferences();
    if (existingRow != null) {
      _cachedPreferences = existingRow;
    } else {
      _cachedPreferences = const ReportExportPreferences.defaults();
    }

    _isInitialized = true;
    return _cachedPreferences;
  }

  /// Atomically persists the Report Export configuration and updates the
  /// in-memory cache only after the write succeeds.
  Future<ReportExportPreferences> savePreferences(
    ReportExportPreferences preferences, {
    @visibleForTesting Future<void> Function(dynamic txn)? beforeCommitHook,
  }) {
    return _enqueueWrite(() async {
      final toSave = preferences.copyWith(
        profileKey: ReportExportPreferences.defaultProfileKey,
        updatedAt: DateTime.now().toUtc(),
      );

      await _storage.saveReportExportPreferencesAtomically(
        toSave,
        timestamp: toSave.updatedAt,
        beforeCommitHook: beforeCommitHook,
      );

      _cachedPreferences = toSave;
      return _cachedPreferences;
    });
  }

  /// Serializes database writes so concurrent updates never produce
  /// inconsistent persisted state.
  Future<T> _enqueueWrite<T>(Future<T> Function() action) {
    final previous = _pendingWrite;
    final Future<T> next = previous == null
        ? action()
        : previous.then((_) => action());
    final tracked = next.then((_) {}, onError: (_) {});
    _pendingWrite = tracked;
    tracked.whenComplete(() {
      if (identical(_pendingWrite, tracked)) {
        _pendingWrite = null;
      }
    });
    return next;
  }

  Future<void> close() async {
    final pending = _pendingWrite;
    if (pending != null) {
      await pending;
    }
    await _storage.close();
    _isInitialized = false;
  }

  @visibleForTesting
  static void setInstanceForTesting(ReportExportRepository repository) {
    _instance = repository;
  }

  @visibleForTesting
  static Future<void> resetInstanceForTesting() async {
    if (_instance != null) {
      await _instance!.close();
      _instance = null;
    }
  }
}
