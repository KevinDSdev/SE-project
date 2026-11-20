import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idb_shim/idb_shim.dart';
import 'package:prot/core/services/app_preferences_service.dart';
import 'package:prot/features/analytics/data/analytics_customization_repository.dart';
import 'package:prot/features/analytics/data/analytics_customization_web_db.dart';
import 'package:prot/features/analytics/models/analytics_customization_preferences.dart';
import 'package:prot/features/analytics/providers/analytics_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late IdbFactory idbFactory;
  late String testDbName;
  late AnalyticsCustomizationWebDb webDb;
  late AnalyticsCustomizationRepository repository;
  var dbCounter = 0;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPreferencesService.init();
  });

  setUp(() async {
    await AppPreferencesService.clearAll();
    idbFactory = newIdbFactoryMemory();
    testDbName = 'test_finpulse_analytics_web_${dbCounter++}';
    webDb = AnalyticsCustomizationWebDb(
      idbFactory: idbFactory,
      databaseName: testDbName,
    );
    repository = AnalyticsCustomizationRepository(db: webDb);
  });

  tearDown(() async {
    await repository.close();
    await webDb.deleteDatabase();
  });

  group('AnalyticsCustomizationWebDb (IndexedDB)', () {
    test(
      'initializes IndexedDB and creates preferences object store',
      () async {
        final db = await webDb.init();
        expect(webDb.isOpen, isTrue);
        expect(
          db.objectStoreNames,
          contains(AnalyticsCustomizationWebDb.storeName),
        );
      },
    );

    test('provides default values when no preferences were saved', () async {
      final loaded = await repository.init();

      expect(loaded.profileKey, 'default');
      expect(loaded.mainChartStyle, ChartVisualMode.bar);
      expect(loaded.defaultPeriod, AnalyticsPeriod.monthly);
      expect(loaded.subTrendChartStyle, ChartVisualMode.line);
      expect(loaded.subCategoryChartStyle, ChartVisualMode.bar);
    });

    test(
      'saves and reads all four settings accurately across reopen',
      () async {
        await repository.init();
        const customPrefs = AnalyticsCustomizationPreferences(
          mainChartStyle: ChartVisualMode.donut,
          defaultPeriod: AnalyticsPeriod.yearly,
          subTrendChartStyle: ChartVisualMode.bar,
          subCategoryChartStyle: ChartVisualMode.line,
        );

        await repository.saveAll(customPrefs);

        // Simulate browser refresh / close and reopen using the same IndexedDB.
        await repository.close();
        final reopenedDb = AnalyticsCustomizationWebDb(
          idbFactory: idbFactory,
          databaseName: testDbName,
        );
        final reopenedRepo = AnalyticsCustomizationRepository(db: reopenedDb);
        addTearDown(reopenedRepo.close);

        final loaded = await reopenedRepo.init();
        expect(loaded.profileKey, 'default');
        expect(loaded.mainChartStyle, ChartVisualMode.donut);
        expect(loaded.defaultPeriod, AnalyticsPeriod.yearly);
        expect(loaded.subTrendChartStyle, ChartVisualMode.bar);
        expect(loaded.subCategoryChartStyle, ChartVisualMode.line);
        expect(loaded.updatedAt, isNotNull);
      },
    );

    test(
      'updates existing preferences in place without duplicating records',
      () async {
        await webDb.init();
        await webDb.savePreferencesAtomically(
          const AnalyticsCustomizationPreferences(
            mainChartStyle: ChartVisualMode.bar,
            defaultPeriod: AnalyticsPeriod.weekly,
            subTrendChartStyle: ChartVisualMode.line,
            subCategoryChartStyle: ChartVisualMode.bar,
          ),
        );

        await webDb.savePreferencesAtomically(
          const AnalyticsCustomizationPreferences(
            mainChartStyle: ChartVisualMode.line,
            defaultPeriod: AnalyticsPeriod.custom,
            subTrendChartStyle: ChartVisualMode.donut,
            subCategoryChartStyle: ChartVisualMode.donut,
          ),
        );

        final db = await webDb.database;
        final txn = db.transaction(
          AnalyticsCustomizationWebDb.storeName,
          idbModeReadOnly,
        );
        final allKeys = await txn
            .objectStore(AnalyticsCustomizationWebDb.storeName)
            .getAllKeys();
        await txn.completed;

        expect(allKeys, hasLength(1));
        expect(allKeys.first, AnalyticsCustomizationWebDb.defaultProfileKey);

        final loaded = await webDb.getPreferences();
        expect(loaded, isNotNull);
        expect(loaded!.mainChartStyle, ChartVisualMode.line);
        expect(loaded.defaultPeriod, AnalyticsPeriod.custom);
        expect(loaded.subTrendChartStyle, ChartVisualMode.donut);
        expect(loaded.subCategoryChartStyle, ChartVisualMode.donut);
      },
    );

    test('migrates SharedPreferences once without overwriting saved IndexedDB values', () async {
      await AppPreferencesService.saveAccentColor(0xFF38BDF8);
      await AppPreferencesService.saveMainChartStyle('donut');
      await AppPreferencesService.saveDefaultPeriod('yearly');
      await AppPreferencesService.saveSubTrendStyle('invalid_value');
      await AppPreferencesService.saveSubCategoryStyle('line');

      final migrated = await repository.init();
      expect(migrated.mainChartStyle, ChartVisualMode.donut);
      expect(migrated.defaultPeriod, AnalyticsPeriod.yearly);
      expect(migrated.subTrendChartStyle, ChartVisualMode.line); // fallback
      expect(migrated.subCategoryChartStyle, ChartVisualMode.line);

      // Update legacy SharedPreferences with conflicting values and re-init.
      await AppPreferencesService.saveMainChartStyle('bar');
      await AppPreferencesService.saveDefaultPeriod('weekly');

      final reloaded = await repository.init();
      expect(reloaded, equals(migrated));
      expect(AppPreferencesService.getAccentColor(), 0xFF38BDF8);
    });

    test(
      'rolls back transaction on error without leaving partial updates',
      () async {
        await repository.init();
        const initialPrefs = AnalyticsCustomizationPreferences(
          mainChartStyle: ChartVisualMode.bar,
          defaultPeriod: AnalyticsPeriod.monthly,
          subTrendChartStyle: ChartVisualMode.line,
          subCategoryChartStyle: ChartVisualMode.bar,
        );
        await repository.saveAll(initialPrefs);

        const attemptedPrefs = AnalyticsCustomizationPreferences(
          mainChartStyle: ChartVisualMode.donut,
          defaultPeriod: AnalyticsPeriod.yearly,
          subTrendChartStyle: ChartVisualMode.bar,
          subCategoryChartStyle: ChartVisualMode.donut,
        );

        await expectLater(
          () => repository.saveAll(
            attemptedPrefs,
            beforeCommitHook: (txn) async {
              throw StateError('Simulated IndexedDB transaction failure');
            },
          ),
          throwsStateError,
        );

        expect(repository.currentPreferences, equals(initialPrefs));
        final persisted = await webDb.getPreferences();
        expect(persisted, equals(initialPrefs));
      },
    );

    test('Riverpod providers persist period changes from Financial Analytics to IndexedDB', () async {
      await repository.init();

      final container = ProviderContainer(
        overrides: [
          analyticsCustomizationRepositoryProvider.overrideWithValue(
            repository,
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(selectedPeriodProvider), AnalyticsPeriod.monthly);

      // Simulates tapping Weekly on FinancialAnalyticsScreen (temporary selection).
      container
          .read(selectedPeriodProvider.notifier)
          .setPeriod(AnalyticsPeriod.weekly);
      expect(container.read(selectedPeriodProvider), AnalyticsPeriod.weekly);
      // Temporary selection must NOT overwrite the saved default in the repository!
      expect(repository.defaultPeriod, AnalyticsPeriod.monthly);

      // Saved default period updates persist to IndexedDB.
      await container
          .read(savedDefaultPeriodProvider.notifier)
          .setDefaultPeriod(AnalyticsPeriod.weekly);

      // Close and reopen to verify persistence across refresh.
      await repository.close();
      await repository.init();

      expect(repository.defaultPeriod, AnalyticsPeriod.weekly);
    });
  });
}
