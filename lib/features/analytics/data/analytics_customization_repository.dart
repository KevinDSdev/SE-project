import 'package:flutter/foundation.dart';

import '../../../core/services/app_preferences_service.dart';
import '../models/analytics_customization_preferences.dart';
import '../providers/analytics_provider.dart';
import 'analytics_customization_storage.dart';
import 'analytics_customization_storage_factory.dart';

/// Single source of persistence for the four Analytics Customization
/// preferences.
///
/// Preloads and caches the persisted record during startup so Riverpod
/// providers can read initial values synchronously while persisting updates
/// asynchronously through the platform storage backend (SQLite on Android,
/// IndexedDB on Flutter Web).
class AnalyticsCustomizationRepository {
  static AnalyticsCustomizationRepository _instance =
      AnalyticsCustomizationRepository();

  static AnalyticsCustomizationRepository get instance => _instance;

  final AnalyticsCustomizationStorage _storage;
  AnalyticsCustomizationPreferences _cachedPreferences =
      const AnalyticsCustomizationPreferences.defaults();
  bool _isInitialized = false;
  Future<void> _writeQueue = Future<void>.value();

  AnalyticsCustomizationRepository({AnalyticsCustomizationStorage? db})
    : _storage = db ?? createDefaultAnalyticsCustomizationStorage();

  bool get isInitialized => _isInitialized;

  /// Exposes the shared platform storage instance so sibling analytics
  /// repositories reuse the same open database connection.
  AnalyticsCustomizationStorage get storage => _storage;

  /// Synchronous access to the currently cached preferences for Riverpod
  /// `Notifier.build()` methods.
  AnalyticsCustomizationPreferences get currentPreferences =>
      _cachedPreferences;

  ChartVisualMode get mainChartStyle => _cachedPreferences.mainChartStyle;
  AnalyticsPeriod get defaultPeriod => _cachedPreferences.defaultPeriod;
  ChartVisualMode get subTrendChartStyle =>
      _cachedPreferences.subTrendChartStyle;
  ChartVisualMode get subCategoryChartStyle =>
      _cachedPreferences.subCategoryChartStyle;

  /// Initializes the platform storage backend, loads the existing preference
  /// record, or performs a safe one-time migration from legacy
  /// SharedPreferences values if no persisted record exists yet.
  ///
  /// Safe to call more than once.
  Future<AnalyticsCustomizationPreferences> init() async {
    await _storage.init();

    final existingRow = await _storage.getPreferences();
    if (existingRow != null) {
      _cachedPreferences = existingRow;
      _isInitialized = true;
      return _cachedPreferences;
    }

    // No persisted record exists yet: migrate any saved legacy
    // SharedPreferences values without modifying or deleting the original keys.
    await AppPreferencesService.init();
    final migrated = AnalyticsCustomizationPreferences(
      profileKey: AnalyticsCustomizationPreferences.defaultProfileKey,
      mainChartStyle: AnalyticsCustomizationPreferences.parseChartVisualMode(
        AppPreferencesService.getMainChartStyle(),
        AnalyticsCustomizationPreferences.defaultMainChartStyle,
      ),
      defaultPeriod: AnalyticsCustomizationPreferences.parseAnalyticsPeriod(
        AppPreferencesService.getDefaultPeriod(),
        AnalyticsCustomizationPreferences.defaultAnalyticsPeriod,
      ),
      subTrendChartStyle:
          AnalyticsCustomizationPreferences.parseChartVisualMode(
            AppPreferencesService.getSubTrendStyle(),
            AnalyticsCustomizationPreferences.defaultSubTrendChartStyle,
          ),
      subCategoryChartStyle:
          AnalyticsCustomizationPreferences.parseChartVisualMode(
            AppPreferencesService.getSubCategoryStyle(),
            AnalyticsCustomizationPreferences.defaultSubCategoryChartStyle,
          ),
      updatedAt: DateTime.now().toUtc(),
    );

    await _storage.savePreferencesAtomically(migrated);
    final persisted = await _storage.getPreferences() ?? migrated;
    _cachedPreferences = persisted;
    _isInitialized = true;
    return _cachedPreferences;
  }

  /// Atomically persists all four Analytics Customization preferences in a
  /// single transaction and updates the in-memory cache only if the write
  /// succeeds.
  Future<AnalyticsCustomizationPreferences> saveAll(
    AnalyticsCustomizationPreferences preferences, {
    @visibleForTesting Future<void> Function(dynamic txn)? beforeCommitHook,
  }) {
    return _enqueueWrite(() async {
      final toSave = preferences.copyWith(
        profileKey: AnalyticsCustomizationPreferences.defaultProfileKey,
        updatedAt: DateTime.now().toUtc(),
      );

      await _storage.savePreferencesAtomically(
        toSave,
        timestamp: toSave.updatedAt,
        beforeCommitHook: beforeCommitHook,
      );

      _cachedPreferences = toSave;
      return _cachedPreferences;
    });
  }

  /// Persists an updated main dashboard chart style while preserving the other
  /// three preferences.
  Future<AnalyticsCustomizationPreferences> updateMainChartStyle(
    ChartVisualMode style,
  ) {
    return _enqueueWrite(() async {
      final updated = _cachedPreferences.copyWith(
        mainChartStyle: style,
        updatedAt: DateTime.now().toUtc(),
      );
      await _storage.savePreferencesAtomically(
        updated,
        timestamp: updated.updatedAt,
      );
      _cachedPreferences = updated;
      return _cachedPreferences;
    });
  }

  /// Persists an updated default analytics period while preserving the other
  /// three preferences.
  Future<AnalyticsCustomizationPreferences> updateDefaultPeriod(
    AnalyticsPeriod period,
  ) {
    return _enqueueWrite(() async {
      final updated = _cachedPreferences.copyWith(
        defaultPeriod: period,
        updatedAt: DateTime.now().toUtc(),
      );
      await _storage.savePreferencesAtomically(
        updated,
        timestamp: updated.updatedAt,
      );
      _cachedPreferences = updated;
      return _cachedPreferences;
    });
  }

  /// Persists an updated sub-dashboard overall trend chart style while
  /// preserving the other three preferences.
  Future<AnalyticsCustomizationPreferences> updateSubTrendChartStyle(
    ChartVisualMode style,
  ) {
    return _enqueueWrite(() async {
      final updated = _cachedPreferences.copyWith(
        subTrendChartStyle: style,
        updatedAt: DateTime.now().toUtc(),
      );
      await _storage.savePreferencesAtomically(
        updated,
        timestamp: updated.updatedAt,
      );
      _cachedPreferences = updated;
      return _cachedPreferences;
    });
  }

  /// Persists an updated sub-dashboard category breakdown chart style while
  /// preserving the other three preferences.
  Future<AnalyticsCustomizationPreferences> updateSubCategoryChartStyle(
    ChartVisualMode style,
  ) {
    return _enqueueWrite(() async {
      final updated = _cachedPreferences.copyWith(
        subCategoryChartStyle: style,
        updatedAt: DateTime.now().toUtc(),
      );
      await _storage.savePreferencesAtomically(
        updated,
        timestamp: updated.updatedAt,
      );
      _cachedPreferences = updated;
      return _cachedPreferences;
    });
  }

  /// Serializes database writes so concurrent provider updates never produce
  /// inconsistent persisted state.
  Future<T> _enqueueWrite<T>(Future<T> Function() action) {
    final next = _writeQueue.then((_) => action());
    _writeQueue = next.then((_) {}, onError: (_) {});
    return next;
  }

  Future<void> close() async {
    await _writeQueue;
    await _storage.close();
    _isInitialized = false;
  }

  @visibleForTesting
  static void setInstanceForTesting(
    AnalyticsCustomizationRepository repository,
  ) {
    _instance = repository;
  }

  @visibleForTesting
  static Future<void> resetInstanceForTesting() async {
    await _instance.close();
    _instance = AnalyticsCustomizationRepository();
  }
}
