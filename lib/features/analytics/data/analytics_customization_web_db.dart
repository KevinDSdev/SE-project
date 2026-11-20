import 'package:idb_shim/idb_shim.dart';

import '../models/analytics_customization_preferences.dart';
import '../models/dashboard_layout_preferences.dart';
import '../models/report_export_preferences.dart';
import 'analytics_customization_storage.dart';

/// IndexedDB persistence helper for Analytics Customization, Dashboard Layout,
/// and Report Export preferences on Flutter Web.
class AnalyticsCustomizationWebDb implements AnalyticsCustomizationStorage {
  static const String defaultDatabaseName =
      'finpulse_analytics_customization_web';
  static const int databaseVersion = 4;
  static const String storeName = 'analytics_customization_preferences';
  static const String dashboardLayoutStoreName = 'dashboard_layout_preferences';
  static const String reportExportStoreName = 'report_export_preferences';
  static const String defaultProfileKey =
      AnalyticsCustomizationPreferences.defaultProfileKey;

  final IdbFactory _idbFactory;
  final String _databaseName;
  Database? _database;

  AnalyticsCustomizationWebDb({
    required this._idbFactory,
    this._databaseName = defaultDatabaseName,
  });

  @override
  bool get isOpen => _database != null;

  @override
  Future<Database> init() async {
    if (_database != null) {
      return _database!;
    }

    _database = await _idbFactory.open(
      _databaseName,
      version: databaseVersion,
      onUpgradeNeeded: (VersionChangeEvent event) {
        final db = event.database;
        if (!db.objectStoreNames.contains(storeName)) {
          db.createObjectStore(storeName, keyPath: 'profile_key');
        }
        if (!db.objectStoreNames.contains(dashboardLayoutStoreName)) {
          db.createObjectStore(
            dashboardLayoutStoreName,
            keyPath: 'profile_key',
          );
        }
        if (!db.objectStoreNames.contains(reportExportStoreName)) {
          db.createObjectStore(reportExportStoreName, keyPath: 'profile_key');
        }
      },
    );

    return _database!;
  }

  Future<Database> get database async => init();

  @override
  Future<AnalyticsCustomizationPreferences?> getPreferences({
    String profileKey = defaultProfileKey,
  }) async {
    final db = await database;
    final txn = db.transaction(storeName, idbModeReadOnly);
    final store = txn.objectStore(storeName);
    final raw = await store.getObject(profileKey);
    await txn.completed;

    if (raw is! Map) {
      return null;
    }

    final normalizedMap = <String, Object?>{
      for (final entry in raw.entries) entry.key.toString(): entry.value,
    };
    return AnalyticsCustomizationPreferences.fromMap(normalizedMap);
  }

  @override
  Future<void> savePreferencesAtomically(
    AnalyticsCustomizationPreferences preferences, {
    DateTime? timestamp,
    Future<void> Function(dynamic txn)? beforeCommitHook,
  }) async {
    final db = await database;
    final values = preferences.toMap(timestamp: timestamp);
    final txn = db.transaction(storeName, idbModeReadWrite);
    final store = txn.objectStore(storeName);

    try {
      await store.put(values);

      if (beforeCommitHook != null) {
        await beforeCommitHook(txn);
      }

      await txn.completed;
    } catch (_) {
      try {
        txn.abort();
      } catch (_) {
        // Transaction may already be aborted or inactive.
      }
      try {
        await txn.completed;
      } catch (_) {
        // Ignore the expected AbortError after aborting the transaction.
      }
      rethrow;
    }
  }

  @override
  Future<DashboardLayoutPreferences?> getDashboardLayout({
    String profileKey = defaultProfileKey,
  }) async {
    final db = await database;
    final txn = db.transaction(dashboardLayoutStoreName, idbModeReadOnly);
    final store = txn.objectStore(dashboardLayoutStoreName);
    final raw = await store.getObject(profileKey);
    await txn.completed;

    if (raw is! Map) {
      return null;
    }

    final normalizedMap = <String, Object?>{
      for (final entry in raw.entries) entry.key.toString(): entry.value,
    };
    return DashboardLayoutPreferences.fromMap(normalizedMap);
  }

  @override
  Future<void> saveDashboardLayoutAtomically(
    DashboardLayoutPreferences preferences, {
    DateTime? timestamp,
    Future<void> Function(dynamic txn)? beforeCommitHook,
  }) async {
    final db = await database;
    final values = preferences.toMap(timestamp: timestamp);
    final txn = db.transaction(dashboardLayoutStoreName, idbModeReadWrite);
    final store = txn.objectStore(dashboardLayoutStoreName);

    try {
      await store.put(values);

      if (beforeCommitHook != null) {
        await beforeCommitHook(txn);
      }

      await txn.completed;
    } catch (_) {
      try {
        txn.abort();
      } catch (_) {
        // Transaction may already be aborted or inactive.
      }
      try {
        await txn.completed;
      } catch (_) {
        // Ignore the expected AbortError after aborting the transaction.
      }
      rethrow;
    }
  }

  @override
  Future<ReportExportPreferences?> getReportExportPreferences({
    String profileKey = defaultProfileKey,
  }) async {
    final db = await database;
    final txn = db.transaction(reportExportStoreName, idbModeReadOnly);
    final store = txn.objectStore(reportExportStoreName);
    final raw = await store.getObject(profileKey);
    await txn.completed;

    if (raw is! Map) {
      return null;
    }

    final normalizedMap = <String, Object?>{
      for (final entry in raw.entries) entry.key.toString(): entry.value,
    };
    return ReportExportPreferences.fromMap(normalizedMap);
  }

  @override
  Future<void> saveReportExportPreferencesAtomically(
    ReportExportPreferences preferences, {
    DateTime? timestamp,
    Future<void> Function(dynamic txn)? beforeCommitHook,
  }) async {
    final db = await database;
    final values = preferences.toMap(timestamp: timestamp);
    final txn = db.transaction(reportExportStoreName, idbModeReadWrite);
    final store = txn.objectStore(reportExportStoreName);

    try {
      await store.put(values);

      if (beforeCommitHook != null) {
        await beforeCommitHook(txn);
      }

      await txn.completed;
    } catch (_) {
      try {
        txn.abort();
      } catch (_) {
        // Transaction may already be aborted or inactive.
      }
      try {
        await txn.completed;
      } catch (_) {
        // Ignore the expected AbortError after aborting the transaction.
      }
      rethrow;
    }
  }

  @override
  Future<void> close() async {
    _database?.close();
    _database = null;
  }

  /// Closes and deletes the IndexedDB database (primarily for tests).
  Future<void> deleteDatabase() async {
    await close();
    await _idbFactory.deleteDatabase(_databaseName);
  }
}
