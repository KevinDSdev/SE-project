import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/analytics_customization_preferences.dart';
import '../models/dashboard_layout_preferences.dart';
import '../models/report_export_preferences.dart';
import 'analytics_customization_storage.dart';

/// SQLite database helper for Analytics Customization, Dashboard Layout, and
/// Report Export preferences.
class AnalyticsCustomizationDb implements AnalyticsCustomizationStorage {
  static const String databaseName = 'finpulse_analytics_customization.db';
  static const int databaseVersion = 4;
  static const String tableName = 'analytics_customization_preferences';
  static const String dashboardLayoutTableName = 'dashboard_layout_preferences';
  static const String reportExportTableName = 'report_export_preferences';
  static const String defaultProfileKey =
      AnalyticsCustomizationPreferences.defaultProfileKey;

  static const String createTableSql =
      '''
    CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      profile_key TEXT NOT NULL UNIQUE DEFAULT '$defaultProfileKey',
      main_chart_style TEXT NOT NULL DEFAULT 'bar'
        CHECK (main_chart_style IN ('bar', 'line', 'donut')),
      default_period TEXT NOT NULL DEFAULT 'monthly'
        CHECK (default_period IN ('weekly', 'monthly', 'yearly', 'custom')),
      sub_trend_chart_style TEXT NOT NULL DEFAULT 'line'
        CHECK (sub_trend_chart_style IN ('bar', 'line', 'donut')),
      sub_category_chart_style TEXT NOT NULL DEFAULT 'bar'
        CHECK (sub_category_chart_style IN ('bar', 'line', 'donut')),
      updated_at TEXT NOT NULL DEFAULT (datetime('now'))
    )
  ''';

  static const String createDashboardLayoutTableSql =
      '''
    CREATE TABLE IF NOT EXISTS $dashboardLayoutTableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      profile_key TEXT NOT NULL UNIQUE DEFAULT '$defaultProfileKey',
      active_card_ids TEXT NOT NULL,
      updated_at TEXT NOT NULL DEFAULT (datetime('now'))
    )
  ''';

  static const String createReportExportTableSql =
      '''
    CREATE TABLE IF NOT EXISTS $reportExportTableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      profile_key TEXT NOT NULL UNIQUE DEFAULT '$defaultProfileKey',
      report_format TEXT NOT NULL DEFAULT 'PDF Report'
        CHECK (report_format IN ('PDF Report', 'Excel (.XLSX)', 'Raw Data')),
      period_label TEXT NOT NULL DEFAULT 'October 2026',
      account_scope TEXT NOT NULL DEFAULT 'BOC',
      selected_requirements TEXT NOT NULL,
      start_date TEXT,
      end_date TEXT,
      updated_at TEXT NOT NULL DEFAULT (datetime('now'))
    )
  ''';

  final String? _customDatabasePath;
  final DatabaseFactory? _customDatabaseFactory;
  Database? _database;

  AnalyticsCustomizationDb({
    String? databasePath,
    DatabaseFactory? databaseFactory,
  }) : _customDatabasePath = databasePath,
       _customDatabaseFactory = databaseFactory;

  @override
  bool get isOpen => _database != null && _database!.isOpen;

  Future<String> _resolveDatabasePath() async {
    if (_customDatabasePath != null && _customDatabasePath.isNotEmpty) {
      return _customDatabasePath;
    }
    final factory = _customDatabaseFactory ?? databaseFactory;
    final dbDir = await factory.getDatabasesPath();
    return p.join(dbDir, databaseName);
  }

  /// Opens (or returns the already-open) SQLite database and ensures the
  /// `analytics_customization_preferences` table exists.
  @override
  Future<Database> init() async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }

    final dbPath = await _resolveDatabasePath();
    final factory = _customDatabaseFactory ?? databaseFactory;

    _database = await factory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: databaseVersion,
        onCreate: (db, version) async {
          await db.execute(createTableSql);
          await db.execute(createDashboardLayoutTableSql);
          await db.execute(createReportExportTableSql);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute(createDashboardLayoutTableSql);
          }
          if (oldVersion < 3) {
            await db.execute(createReportExportTableSql);
          } else if (oldVersion < 4) {
            await db.execute(
              'ALTER TABLE $reportExportTableName ADD COLUMN start_date TEXT;',
            );
            await db.execute(
              'ALTER TABLE $reportExportTableName ADD COLUMN end_date TEXT;',
            );
          }
        },
      ),
    );

    return _database!;
  }

  Future<Database> get database async => init();

  /// Reads the stored preferences row for [profileKey], or returns `null` if
  /// no row has been saved yet.
  @override
  Future<AnalyticsCustomizationPreferences?> getPreferences({
    String profileKey = defaultProfileKey,
  }) async {
    final db = await database;
    final rows = await db.query(
      tableName,
      where: 'profile_key = ?',
      whereArgs: [profileKey],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }
    return AnalyticsCustomizationPreferences.fromMap(rows.first);
  }

  /// Inserts a new preferences row into SQLite.
  Future<int> insertPreferences(
    AnalyticsCustomizationPreferences preferences, {
    DateTime? timestamp,
  }) async {
    final db = await database;
    return db.insert(
      tableName,
      preferences.toMap(timestamp: timestamp),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  /// Updates an existing preferences row matching `preferences.profileKey`.
  Future<int> updatePreferences(
    AnalyticsCustomizationPreferences preferences, {
    DateTime? timestamp,
  }) async {
    final db = await database;
    final values = preferences.toMap(timestamp: timestamp)
      ..remove('profile_key');

    return db.update(
      tableName,
      values,
      where: 'profile_key = ?',
      whereArgs: [preferences.profileKey],
    );
  }

  /// Atomically inserts or updates all four Analytics Customization
  /// preferences inside a single SQLite transaction.
  ///
  /// If an error occurs inside the transaction (for example via
  /// [beforeCommitHook] in tests), SQLite rolls back the entire transaction so
  /// no partial update is committed.
  @override
  Future<void> savePreferencesAtomically(
    AnalyticsCustomizationPreferences preferences, {
    DateTime? timestamp,
    Future<void> Function(dynamic txn)? beforeCommitHook,
  }) async {
    final db = await database;
    final values = preferences.toMap(timestamp: timestamp);

    await db.transaction((txn) async {
      final existing = await txn.query(
        tableName,
        columns: ['id'],
        where: 'profile_key = ?',
        whereArgs: [preferences.profileKey],
        limit: 1,
      );

      if (existing.isEmpty) {
        await txn.insert(
          tableName,
          values,
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      } else {
        final updateValues = Map<String, Object?>.from(values)
          ..remove('profile_key');
        await txn.update(
          tableName,
          updateValues,
          where: 'profile_key = ?',
          whereArgs: [preferences.profileKey],
        );
      }

      if (beforeCommitHook != null) {
        await beforeCommitHook(txn);
      }
    });
  }

  /// Reads the stored Dashboard Layout row for [profileKey], or returns `null`
  /// if no row has been saved yet.
  @override
  Future<DashboardLayoutPreferences?> getDashboardLayout({
    String profileKey = defaultProfileKey,
  }) async {
    final db = await database;
    final rows = await db.query(
      dashboardLayoutTableName,
      where: 'profile_key = ?',
      whereArgs: [profileKey],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }
    return DashboardLayoutPreferences.fromMap(rows.first);
  }

  /// Atomically inserts or updates the Dashboard Layout preferences row inside
  /// a single SQLite transaction.
  @override
  Future<void> saveDashboardLayoutAtomically(
    DashboardLayoutPreferences preferences, {
    DateTime? timestamp,
    Future<void> Function(dynamic txn)? beforeCommitHook,
  }) async {
    final db = await database;
    final values = preferences.toMap(timestamp: timestamp);

    await db.transaction((txn) async {
      final existing = await txn.query(
        dashboardLayoutTableName,
        columns: ['id'],
        where: 'profile_key = ?',
        whereArgs: [preferences.profileKey],
        limit: 1,
      );

      if (existing.isEmpty) {
        await txn.insert(
          dashboardLayoutTableName,
          values,
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      } else {
        final updateValues = Map<String, Object?>.from(values)
          ..remove('profile_key');
        await txn.update(
          dashboardLayoutTableName,
          updateValues,
          where: 'profile_key = ?',
          whereArgs: [preferences.profileKey],
        );
      }

      if (beforeCommitHook != null) {
        await beforeCommitHook(txn);
      }
    });
  }

  /// Reads the stored Report Export configuration row for [profileKey], or
  /// returns `null` if no row has been saved yet.
  @override
  Future<ReportExportPreferences?> getReportExportPreferences({
    String profileKey = defaultProfileKey,
  }) async {
    final db = await database;
    final rows = await db.query(
      reportExportTableName,
      where: 'profile_key = ?',
      whereArgs: [profileKey],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }
    return ReportExportPreferences.fromMap(rows.first);
  }

  /// Atomically inserts or updates the Report Export preferences row inside a
  /// single SQLite transaction.
  @override
  Future<void> saveReportExportPreferencesAtomically(
    ReportExportPreferences preferences, {
    DateTime? timestamp,
    Future<void> Function(dynamic txn)? beforeCommitHook,
  }) async {
    final db = await database;
    final values = preferences.toMap(timestamp: timestamp);

    await db.transaction((txn) async {
      final existing = await txn.query(
        reportExportTableName,
        columns: ['id'],
        where: 'profile_key = ?',
        whereArgs: [preferences.profileKey],
        limit: 1,
      );

      if (existing.isEmpty) {
        await txn.insert(
          reportExportTableName,
          values,
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      } else {
        final updateValues = Map<String, Object?>.from(values)
          ..remove('profile_key');
        await txn.update(
          reportExportTableName,
          updateValues,
          where: 'profile_key = ?',
          whereArgs: [preferences.profileKey],
        );
      }

      if (beforeCommitHook != null) {
        await beforeCommitHook(txn);
      }
    });
  }

  /// Closes the database connection cleanly.
  @override
  Future<void> close() async {
    if (_database != null) {
      if (_database!.isOpen) {
        await _database!.close();
      }
      _database = null;
    }
  }

  /// Closes and deletes the underlying database file (primarily for tests).
  Future<void> deleteDatabaseFile() async {
    await close();
    final dbPath = await _resolveDatabasePath();
    final factory = _customDatabaseFactory ?? databaseFactory;
    await factory.deleteDatabase(dbPath);
  }
}
