import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:prot/core/services/app_preferences_service.dart';
import 'package:prot/features/analytics/data/analytics_customization_db.dart';
import 'package:prot/features/analytics/data/analytics_customization_repository.dart';
import 'package:prot/features/analytics/data/dashboard_layout_repository.dart';
import 'package:prot/features/analytics/models/analytics_customization_preferences.dart';
import 'package:prot/features/analytics/models/dashboard_layout_preferences.dart';
import 'package:prot/features/analytics/providers/analytics_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Directory tempDir;
  late String testDbPath;
  late AnalyticsCustomizationDb db;
  late DashboardLayoutRepository repository;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPreferencesService.init();
  });

  setUp(() async {
    await AppPreferencesService.clearAll();
    tempDir = await Directory.systemTemp.createTemp(
      'finpulse_dashboard_layout_test_',
    );
    testDbPath = p.join(tempDir.path, 'test_dashboard_layout.db');
    db = AnalyticsCustomizationDb(
      databasePath: testDbPath,
      databaseFactory: databaseFactoryFfi,
    );
    repository = DashboardLayoutRepository(storage: db);
  });

  tearDown(() async {
    await repository.close();
    await db.deleteDatabaseFile();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('DashboardLayout SQLite (v2)', () {
    test('fresh database creates both analytics_customization_preferences and dashboard_layout_preferences tables', () async {
      final database = await db.init();
      expect(database.isOpen, isTrue);

      final tables = await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table'",
      );
      final tableNames = tables.map((row) => row['name']).toSet();

      expect(tableNames, contains(AnalyticsCustomizationDb.tableName));
      expect(
        tableNames,
        contains(AnalyticsCustomizationDb.dashboardLayoutTableName),
      );

      final columns = await database.rawQuery(
        'PRAGMA table_info(${AnalyticsCustomizationDb.dashboardLayoutTableName})',
      );
      final columnNames = columns.map((row) => row['name']).toSet();
      expect(
        columnNames,
        containsAll(<String>[
          'id',
          'profile_key',
          'active_card_ids',
          'updated_at',
        ]),
      );
    });

    test('existing v1 database upgrades to v2 and preserves Analytics Customization preferences unchanged', () async {
      // Simulate an existing v1 database with saved Analytics Customization data.
      final v1Db = await databaseFactoryFfi.openDatabase(
        testDbPath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (database, version) async {
            await database.execute(AnalyticsCustomizationDb.createTableSql);
          },
        ),
      );

      const savedAnalyticsPrefs = AnalyticsCustomizationPreferences(
        mainChartStyle: ChartVisualMode.donut,
        defaultPeriod: AnalyticsPeriod.yearly,
        subTrendChartStyle: ChartVisualMode.bar,
        subCategoryChartStyle: ChartVisualMode.line,
      );
      await v1Db.insert(
        AnalyticsCustomizationDb.tableName,
        savedAnalyticsPrefs.toMap(),
      );
      await v1Db.close();

      // Reopen using v2 AnalyticsCustomizationDb.
      final upgradedDb = await db.init();
      expect(await upgradedDb.getVersion(), 2);

      // Existing Analytics Customization row survived unchanged.
      final analyticsRepo = AnalyticsCustomizationRepository(db: db);
      final loadedAnalytics = await analyticsRepo.init();
      expect(loadedAnalytics, equals(savedAnalyticsPrefs));

      // New dashboard_layout_preferences table exists and works.
      final layout = await repository.init();
      expect(
        layout.activeCardIds,
        equals(DashboardLayoutPreferences.defaultActiveCardIds),
      );
    });

    test('default Active Cards load correctly when no layout exists', () async {
      final loaded = await repository.init();

      expect(loaded.profileKey, 'default');
      expect(
        loaded.activeCardIds,
        equals(<String>[
          'active_income',
          'active_expenses',
          'active_savings',
          'active_trend',
        ]),
      );
      expect(
        loaded.availableCardIds,
        equals(DashboardLayoutPreferences.defaultAvailableCardIds),
      );
    });

    test('custom Active Cards and order persist after reopening', () async {
      await repository.init();
      const customOrder = <String>[
        'avail_anomaly',
        'active_savings',
        'avail_inc_analytics',
        'active_income',
      ];

      await repository.saveActiveCardIds(customOrder);
      await repository.close();

      final reopenedDb = AnalyticsCustomizationDb(
        databasePath: testDbPath,
        databaseFactory: databaseFactoryFfi,
      );
      final reopenedRepo = DashboardLayoutRepository(storage: reopenedDb);
      addTearDown(reopenedRepo.close);

      final loaded = await reopenedRepo.init();
      expect(loaded.activeCardIds, equals(customOrder));
      expect(loaded.availableCardIds, hasLength(6));
      expect(loaded.availableCardIds, isNot(contains('avail_anomaly')));
      expect(loaded.availableCardIds, contains('active_trend'));
    });

    test('empty Active Cards persist after reopening without reverting to defaults', () async {
      await repository.init();
      await repository.saveActiveCardIds(const <String>[]);
      await repository.close();

      final reopenedDb = AnalyticsCustomizationDb(
        databasePath: testDbPath,
        databaseFactory: databaseFactoryFfi,
      );
      final reopenedRepo = DashboardLayoutRepository(storage: reopenedDb);
      addTearDown(reopenedRepo.close);

      final loaded = await reopenedRepo.init();
      expect(loaded.activeCardIds, isEmpty);
      expect(
        loaded.availableCardIds,
        equals(DashboardLayoutPreferences.allKnownCardIds),
      );
    });

    test('repeated saves update one record rather than create duplicates', () async {
      await repository.init();
      await repository.saveActiveCardIds(const <String>['active_income']);
      await repository.saveActiveCardIds(const <String>[
        'avail_exp_pred',
        'active_expenses',
      ]);
      await repository.saveActiveCardIds(const <String>['active_trend']);

      final rawDb = await db.database;
      final countResult = await rawDb.rawQuery(
        'SELECT COUNT(*) AS count FROM ${AnalyticsCustomizationDb.dashboardLayoutTableName}',
      );
      expect(countResult.first['count'], 1);

      final persisted = await db.getDashboardLayout();
      expect(persisted?.activeCardIds, equals(<String>['active_trend']));
    });

    test('legacy SharedPreferences migrate once, sanitize unknown/duplicate IDs, and never overwrite existing DB records', () async {
      await AppPreferencesService.saveActiveWidgets(const <String>[
        'avail_goal_analytics',
        'unknown_legacy_card',
        'active_savings',
        'avail_goal_analytics',
        'another_invalid_id',
      ]);

      final migrated = await repository.init();
      expect(
        migrated.activeCardIds,
        equals(<String>['avail_goal_analytics', 'active_savings']),
      );

      // Modify SharedPreferences with conflicting data and re-initialize.
      await AppPreferencesService.saveActiveWidgets(const <String>[
        'active_income',
      ]);

      final secondInit = await repository.init();
      expect(
        secondInit.activeCardIds,
        equals(<String>['avail_goal_analytics', 'active_savings']),
      );
    });

    test('unrelated SharedPreferences values remain unchanged after migration and saves', () async {
      await AppPreferencesService.saveAccentColor(0xFF9353D3);
      await AppPreferencesService.saveDarkMode(false);
      await AppPreferencesService.saveMainChartStyle('donut');
      await AppPreferencesService.saveActiveWidgets(const <String>[
        'active_income',
        'avail_anomaly',
      ]);

      await repository.init();
      await repository.saveActiveCardIds(const <String>['active_expenses']);

      expect(AppPreferencesService.getAccentColor(), 0xFF9353D3);
      expect(AppPreferencesService.getDarkMode(), isFalse);
      expect(AppPreferencesService.getMainChartStyle(), 'donut');
      expect(
        AppPreferencesService.getActiveWidgets(),
        equals(<String>['active_income', 'avail_anomaly']),
      );
    });

    test('failed writes roll back and leave previous cache and database record unchanged', () async {
      await repository.init();
      const initialIds = <String>['active_income', 'active_trend'];
      await repository.saveActiveCardIds(initialIds);

      await expectLater(
        () => repository.saveActiveCardIds(
          const <String>['avail_anomaly'],
          beforeCommitHook: (txn) async {
            throw StateError('Simulated SQLite failure before commit');
          },
        ),
        throwsStateError,
      );

      expect(repository.activeCardIds, equals(initialIds));
      final persisted = await db.getDashboardLayout();
      expect(persisted?.activeCardIds, equals(initialIds));
    });

    test('Riverpod dashboardWidgetsProvider ignores invalid IDs and derives available cards', () async {
      await repository.init();
      await repository.saveActiveCardIds(const <String>[
        'avail_inc_pred',
        'not_a_real_card',
        'active_expenses',
        'avail_inc_pred',
      ]);

      final container = ProviderContainer(
        overrides: [
          dashboardLayoutRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(dashboardWidgetsProvider);
      expect(
        state.activeWidgets.map((c) => c.id).toList(),
        equals(<String>['avail_inc_pred', 'active_expenses']),
      );
      expect(state.availableWidgets, hasLength(8));
      expect(
        state.availableWidgets.map((c) => c.id),
        isNot(contains('avail_inc_pred')),
      );
      expect(
        state.availableWidgets.map((c) => c.id),
        isNot(contains('active_expenses')),
      );
    });
  });
}
