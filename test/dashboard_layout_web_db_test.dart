import 'package:flutter_test/flutter_test.dart';
import 'package:idb_shim/idb_shim.dart';
import 'package:prot/core/services/app_preferences_service.dart';
import 'package:prot/features/analytics/data/analytics_customization_repository.dart';
import 'package:prot/features/analytics/data/analytics_customization_web_db.dart';
import 'package:prot/features/analytics/data/dashboard_layout_repository.dart';
import 'package:prot/features/analytics/models/analytics_customization_preferences.dart';
import 'package:prot/features/analytics/models/dashboard_layout_preferences.dart';
import 'package:prot/features/analytics/providers/analytics_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late IdbFactory idbFactory;
  late String testDbName;
  late AnalyticsCustomizationWebDb webDb;
  late DashboardLayoutRepository repository;
  var dbCounter = 0;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPreferencesService.init();
  });

  setUp(() async {
    await AppPreferencesService.clearAll();
    idbFactory = newIdbFactoryMemory();
    testDbName = 'test_finpulse_dashboard_layout_web_${dbCounter++}';
    webDb = AnalyticsCustomizationWebDb(
      idbFactory: idbFactory,
      databaseName: testDbName,
    );
    repository = DashboardLayoutRepository(storage: webDb);
  });

  tearDown(() async {
    await repository.close();
    await webDb.deleteDatabase();
  });

  group('DashboardLayout IndexedDB (v2)', () {
    test('version 2 creates both object stores', () async {
      final db = await webDb.init();
      expect(webDb.isOpen, isTrue);
      expect(
        db.objectStoreNames,
        contains(AnalyticsCustomizationWebDb.storeName),
      );
      expect(
        db.objectStoreNames,
        contains(AnalyticsCustomizationWebDb.dashboardLayoutStoreName),
      );
    });

    test('upgrading from v1 to v2 keeps existing Analytics Customization data intact', () async {
      // Create a v1 IndexedDB with an existing Analytics Customization record.
      final v1Db = await idbFactory.open(
        testDbName,
        version: 1,
        onUpgradeNeeded: (VersionChangeEvent event) {
          event.database.createObjectStore(
            AnalyticsCustomizationWebDb.storeName,
            keyPath: 'profile_key',
          );
        },
      );

      const savedAnalytics = AnalyticsCustomizationPreferences(
        mainChartStyle: ChartVisualMode.line,
        defaultPeriod: AnalyticsPeriod.weekly,
        subTrendChartStyle: ChartVisualMode.donut,
        subCategoryChartStyle: ChartVisualMode.bar,
      );
      final txn = v1Db.transaction(
        AnalyticsCustomizationWebDb.storeName,
        idbModeReadWrite,
      );
      await txn
          .objectStore(AnalyticsCustomizationWebDb.storeName)
          .put(savedAnalytics.toMap());
      await txn.completed;
      v1Db.close();

      // Reopen as v2 via AnalyticsCustomizationWebDb.
      final analyticsRepo = AnalyticsCustomizationRepository(db: webDb);
      final loadedAnalytics = await analyticsRepo.init();
      expect(loadedAnalytics, equals(savedAnalytics));

      final layout = await repository.init();
      expect(
        layout.activeCardIds,
        equals(DashboardLayoutPreferences.defaultActiveCardIds),
      );
    });

    test('custom layouts and ordering persist after reopening', () async {
      await repository.init();
      const customOrder = <String>[
        'avail_exp_analytics',
        'active_trend',
        'active_income',
      ];
      await repository.saveActiveCardIds(customOrder);
      await repository.close();

      final reopenedDb = AnalyticsCustomizationWebDb(
        idbFactory: idbFactory,
        databaseName: testDbName,
      );
      final reopenedRepo = DashboardLayoutRepository(storage: reopenedDb);
      addTearDown(reopenedRepo.close);

      final loaded = await reopenedRepo.init();
      expect(loaded.activeCardIds, equals(customOrder));
      expect(loaded.availableCardIds, hasLength(7));
    });

    test('empty Active Cards persist after reopening', () async {
      await repository.init();
      await repository.saveActiveCardIds(const <String>[]);
      await repository.close();

      final reopenedDb = AnalyticsCustomizationWebDb(
        idbFactory: idbFactory,
        databaseName: testDbName,
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

    test(
      'repeated saves update in place without creating duplicates',
      () async {
        await repository.init();
        await repository.saveActiveCardIds(const <String>['active_income']);
        await repository.saveActiveCardIds(const <String>[
          'active_savings',
          'avail_anomaly',
        ]);

        final db = await webDb.database;
        final txn = db.transaction(
          AnalyticsCustomizationWebDb.dashboardLayoutStoreName,
          idbModeReadOnly,
        );
        final allKeys = await txn
            .objectStore(AnalyticsCustomizationWebDb.dashboardLayoutStoreName)
            .getAllKeys();
        await txn.completed;

        expect(allKeys, hasLength(1));
        expect(allKeys.first, AnalyticsCustomizationWebDb.defaultProfileKey);

        final loaded = await webDb.getDashboardLayout();
        expect(
          loaded?.activeCardIds,
          equals(<String>['active_savings', 'avail_anomaly']),
        );
      },
    );

    test('legacy migration works once without overwriting saved IndexedDB records', () async {
      await AppPreferencesService.saveAccentColor(0xFF38BDF8);
      await AppPreferencesService.saveActiveWidgets(const <String>[
        'avail_inc_analytics',
        'invalid_card_id',
        'active_expenses',
        'avail_inc_analytics',
      ]);

      final migrated = await repository.init();
      expect(
        migrated.activeCardIds,
        equals(<String>['avail_inc_analytics', 'active_expenses']),
      );

      // Update legacy SharedPreferences and re-init; IndexedDB record must win.
      await AppPreferencesService.saveActiveWidgets(const <String>[
        'active_income',
      ]);
      final reloaded = await repository.init();
      expect(
        reloaded.activeCardIds,
        equals(<String>['avail_inc_analytics', 'active_expenses']),
      );
      expect(AppPreferencesService.getAccentColor(), 0xFF38BDF8);
    });

    test(
      'failed writes abort transaction and preserve previous saved state',
      () async {
        await repository.init();
        const initialIds = <String>['active_income', 'active_savings'];
        await repository.saveActiveCardIds(initialIds);

        await expectLater(
          () => repository.saveActiveCardIds(
            const <String>['avail_anomaly'],
            beforeCommitHook: (txn) async {
              throw StateError('Simulated IndexedDB failure');
            },
          ),
          throwsStateError,
        );

        expect(repository.activeCardIds, equals(initialIds));
        final persisted = await webDb.getDashboardLayout();
        expect(persisted?.activeCardIds, equals(initialIds));
      },
    );
  });
}
