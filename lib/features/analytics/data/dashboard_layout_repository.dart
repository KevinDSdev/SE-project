import 'package:flutter/foundation.dart';

import '../../../core/services/app_preferences_service.dart';
import '../models/dashboard_layout_preferences.dart';
import 'analytics_customization_repository.dart';
import 'analytics_customization_storage.dart';

/// Single source of persistence for Set Dashboard Layout preferences
/// (ordered active Analytics Dashboard Card IDs).
///
/// Reuses the shared [AnalyticsCustomizationStorage] connection so Android
/// (SQLite) and Flutter Web (IndexedDB) operate on a single database without
/// opening duplicate connections.
class DashboardLayoutRepository {
  static DashboardLayoutRepository? _instance;

  static DashboardLayoutRepository get instance =>
      _instance ??= DashboardLayoutRepository();

  final AnalyticsCustomizationStorage _storage;
  DashboardLayoutPreferences _cachedLayout =
      const DashboardLayoutPreferences.defaults();
  bool _isInitialized = false;
  Future<void>? _pendingWrite;

  DashboardLayoutRepository({AnalyticsCustomizationStorage? storage})
    : _storage = storage ?? AnalyticsCustomizationRepository.instance.storage;

  bool get isInitialized => _isInitialized;

  /// Synchronous access to the currently cached layout for Riverpod
  /// `Notifier.build()` methods.
  DashboardLayoutPreferences get currentLayout => _cachedLayout;

  List<String> get activeCardIds => _cachedLayout.activeCardIds;

  List<String> get availableCardIds => _cachedLayout.availableCardIds;

  /// Initializes the shared storage backend (if not already open), loads the
  /// existing Dashboard Layout record, or performs a safe one-time migration
  /// from legacy SharedPreferences if no database record exists yet.
  ///
  /// Safe to call more than once.
  Future<DashboardLayoutPreferences> init() async {
    await _storage.init();

    final existingRow = await _storage.getDashboardLayout();
    if (existingRow != null) {
      _cachedLayout = existingRow;
      _isInitialized = true;
      return _cachedLayout;
    }

    // No persisted record exists yet: migrate legacy SharedPreferences values
    // once without modifying or deleting the original keys.
    await AppPreferencesService.init();
    final legacyIds = AppPreferencesService.getActiveWidgets();

    final List<String> initialActiveIds;
    if (legacyIds == null) {
      initialActiveIds = DashboardLayoutPreferences.defaultActiveCardIds;
    } else if (legacyIds.isEmpty) {
      initialActiveIds = const <String>[];
    } else {
      final sanitized = DashboardLayoutPreferences.sanitizeCardIds(legacyIds);
      initialActiveIds = sanitized.isNotEmpty
          ? sanitized
          : DashboardLayoutPreferences.defaultActiveCardIds;
    }

    final migrated = DashboardLayoutPreferences(
      profileKey: DashboardLayoutPreferences.defaultProfileKey,
      activeCardIds: initialActiveIds,
      updatedAt: DateTime.now().toUtc(),
    );

    await _storage.saveDashboardLayoutAtomically(migrated);
    final persisted = await _storage.getDashboardLayout() ?? migrated;
    _cachedLayout = persisted;
    _isInitialized = true;
    return _cachedLayout;
  }

  /// Atomically persists the ordered list of active Analytics Dashboard Card
  /// IDs and updates the in-memory cache only after the write succeeds.
  Future<DashboardLayoutPreferences> saveActiveCardIds(
    List<String> activeCardIds, {
    @visibleForTesting Future<void> Function(dynamic txn)? beforeCommitHook,
  }) {
    return _enqueueWrite(() async {
      final toSave = DashboardLayoutPreferences(
        profileKey: DashboardLayoutPreferences.defaultProfileKey,
        activeCardIds: activeCardIds,
        updatedAt: DateTime.now().toUtc(),
      );

      await _storage.saveDashboardLayoutAtomically(
        toSave,
        timestamp: toSave.updatedAt,
        beforeCommitHook: beforeCommitHook,
      );

      _cachedLayout = toSave;
      return _cachedLayout;
    });
  }

  /// Atomically resets the persisted Dashboard Layout to the default active
  /// Analytics Dashboard Cards and updates the cache only if the write
  /// succeeds.
  Future<DashboardLayoutPreferences> resetToDefaults({
    @visibleForTesting Future<void> Function(dynamic txn)? beforeCommitHook,
  }) {
    return saveActiveCardIds(
      DashboardLayoutPreferences.defaultActiveCardIds,
      beforeCommitHook: beforeCommitHook,
    );
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
  static void setInstanceForTesting(DashboardLayoutRepository repository) {
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
