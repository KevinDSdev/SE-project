import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:prot/core/services/app_preferences_service.dart';
import 'package:prot/features/analytics/data/analytics_customization_db.dart';
import 'package:prot/features/analytics/data/analytics_customization_repository.dart';
import 'package:prot/features/analytics/models/analytics_customization_preferences.dart';
import 'package:prot/features/analytics/providers/analytics_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Directory tempDir;
  late String testDbPath;
  late AnalyticsCustomizationDb db;
  late AnalyticsCustomizationRepository repository;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPreferencesService.init();
  });

  setUp(() async {
    await AppPreferencesService.clearAll();
    tempDir = await Directory.systemTemp.createTemp('finpulse_analytics_test_');
    testDbPath = p.join(tempDir.path, 'test_analytics_customization.db');
    db = AnalyticsCustomizationDb(
      databasePath: testDbPath,
      databaseFactory: databaseFactoryFfi,
    );
    repository = AnalyticsCustomizationRepository(db: db);
  });

  tearDown(() async {
    await repository.close();
    await db.deleteDatabaseFile();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('AnalyticsCustomizationDb', () {
    test('1 & 2. initializes database and creates analytics_customization_preferences table', () async {
      final database = await db.init();
      expect(database.isOpen, isTrue);
      expect(db.isOpen, isTrue);

      final tables = await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
        [AnalyticsCustomizationDb.tableName],
      );
      expect(tables, hasLength(1));

      final columns = await database.rawQuery(
        'PRAGMA table_info(${AnalyticsCustomizationDb.tableName})',
      );
      final columnNames = columns.map((row) => row['name']).toSet();
      expect(
        columnNames,
        containsAll(<String>[
          'id',
          'profile_key',
          'main_chart_style',
          'default_period',
          'sub_trend_chart_style',
          'sub_category_chart_style',
          'updated_at',
        ]),
      );
    });

    test(
      '3. provides correct default values when no preferences were saved',
      () async {
        final loaded = await repository.init();

        expect(loaded.profileKey, 'default');
        expect(loaded.mainChartStyle, ChartVisualMode.bar);
        expect(loaded.defaultPeriod, AnalyticsPeriod.monthly);
        expect(loaded.subTrendChartStyle, ChartVisualMode.line);
        expect(loaded.subCategoryChartStyle, ChartVisualMode.bar);
      },
    );

    test('4 & 5. saves and reads all four settings accurately', () async {
      await db.init();
      const customPrefs = AnalyticsCustomizationPreferences(
        mainChartStyle: ChartVisualMode.donut,
        defaultPeriod: AnalyticsPeriod.yearly,
        subTrendChartStyle: ChartVisualMode.bar,
        subCategoryChartStyle: ChartVisualMode.line,
      );

      await db.savePreferencesAtomically(customPrefs);
      final loaded = await db.getPreferences();

      expect(loaded, isNotNull);
      expect(loaded!.profileKey, 'default');
      expect(loaded.mainChartStyle, ChartVisualMode.donut);
      expect(loaded.defaultPeriod, AnalyticsPeriod.yearly);
      expect(loaded.subTrendChartStyle, ChartVisualMode.bar);
      expect(loaded.subCategoryChartStyle, ChartVisualMode.line);
      expect(loaded.updatedAt, isNotNull);
    });

    test(
      '6. updates existing preferences in place without duplicating rows',
      () async {
        await db.init();
        await db.insertPreferences(
          const AnalyticsCustomizationPreferences(
            mainChartStyle: ChartVisualMode.bar,
            defaultPeriod: AnalyticsPeriod.weekly,
            subTrendChartStyle: ChartVisualMode.line,
            subCategoryChartStyle: ChartVisualMode.bar,
          ),
        );

        const updatedPrefs = AnalyticsCustomizationPreferences(
          mainChartStyle: ChartVisualMode.line,
          defaultPeriod: AnalyticsPeriod.custom,
          subTrendChartStyle: ChartVisualMode.donut,
          subCategoryChartStyle: ChartVisualMode.donut,
        );
        final affectedRows = await db.updatePreferences(updatedPrefs);
        expect(affectedRows, 1);

        final loaded = await db.getPreferences();
        expect(loaded, isNotNull);
        expect(loaded!.mainChartStyle, ChartVisualMode.line);
        expect(loaded.defaultPeriod, AnalyticsPeriod.custom);
        expect(loaded.subTrendChartStyle, ChartVisualMode.donut);
        expect(loaded.subCategoryChartStyle, ChartVisualMode.donut);

        final rawDb = await db.database;
        final countResult = await rawDb.rawQuery(
          'SELECT COUNT(*) AS count FROM ${AnalyticsCustomizationDb.tableName}',
        );
        expect(countResult.first['count'], 1);
      },
    );

    test('7. rejects invalid values via CHECK constraints and falls back safely in fromMap', () async {
      final rawDb = await db.init();

      await expectLater(
        () => rawDb.insert(AnalyticsCustomizationDb.tableName, {
          'profile_key': 'default',
          'main_chart_style': 'invalid_style',
          'default_period': 'monthly',
          'sub_trend_chart_style': 'line',
          'sub_category_chart_style': 'bar',
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }),
        throwsA(isA<DatabaseException>()),
      );

      await expectLater(
        () => rawDb.insert(AnalyticsCustomizationDb.tableName, {
          'profile_key': 'default',
          'main_chart_style': 'bar',
          'default_period': 'invalid_period',
          'sub_trend_chart_style': 'line',
          'sub_category_chart_style': 'bar',
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }),
        throwsA(isA<DatabaseException>()),
      );

      final parsed = AnalyticsCustomizationPreferences.fromMap({
        'profile_key': '',
        'main_chart_style': 'unexpected',
        'default_period': 12345,
        'sub_trend_chart_style': null,
        'sub_category_chart_style': 'unknown',
        'updated_at': 'not-a-date',
      });

      expect(parsed.profileKey, 'default');
      expect(parsed.mainChartStyle, ChartVisualMode.bar);
      expect(parsed.defaultPeriod, AnalyticsPeriod.monthly);
      expect(parsed.subTrendChartStyle, ChartVisualMode.line);
      expect(parsed.subCategoryChartStyle, ChartVisualMode.bar);
      expect(parsed.updatedAt, isNull);
    });
  });

  group('AnalyticsCustomizationRepository migration & atomicity', () {
    test('8. migrates existing SharedPreferences values and validates invalid ones', () async {
      await AppPreferencesService.saveMainChartStyle('donut');
      await AppPreferencesService.saveDefaultPeriod('yearly');
      await AppPreferencesService.saveSubTrendStyle('invalid_value');
      await AppPreferencesService.saveSubCategoryStyle('line');

      final migrated = await repository.init();

      expect(migrated.mainChartStyle, ChartVisualMode.donut);
      expect(migrated.defaultPeriod, AnalyticsPeriod.yearly);
      expect(migrated.subTrendChartStyle, ChartVisualMode.line); // fallback
      expect(migrated.subCategoryChartStyle, ChartVisualMode.line);

      // Confirm persisted into SQLite.
      final fromDb = await db.getPreferences();
      expect(fromDb, equals(migrated));
    });

    test('9. migration does not overwrite an existing SQLite row and is safe to run repeatedly', () async {
      await db.init();
      const sqlitePrefs = AnalyticsCustomizationPreferences(
        mainChartStyle: ChartVisualMode.line,
        defaultPeriod: AnalyticsPeriod.weekly,
        subTrendChartStyle: ChartVisualMode.donut,
        subCategoryChartStyle: ChartVisualMode.bar,
      );
      await db.savePreferencesAtomically(sqlitePrefs);

      // Put conflicting legacy values in SharedPreferences.
      await AppPreferencesService.saveMainChartStyle('donut');
      await AppPreferencesService.saveDefaultPeriod('custom');
      await AppPreferencesService.saveSubTrendStyle('bar');
      await AppPreferencesService.saveSubCategoryStyle('line');

      final firstInit = await repository.init();
      final secondInit = await repository.init();

      expect(firstInit, equals(sqlitePrefs));
      expect(secondInit, equals(sqlitePrefs));
    });

    test('10. unrelated SharedPreferences settings and legacy analytics keys remain untouched', () async {
      await AppPreferencesService.saveAccentColor(0xFF38BDF8);
      await AppPreferencesService.saveDarkMode(false);
      await AppPreferencesService.saveActiveWidgets([
        'active_income',
        'active_expenses',
      ]);
      await AppPreferencesService.saveMainChartStyle('line');
      await AppPreferencesService.saveDefaultPeriod('weekly');
      await AppPreferencesService.saveSubTrendStyle('bar');
      await AppPreferencesService.saveSubCategoryStyle('donut');

      await repository.init();

      // Unrelated settings untouched.
      expect(AppPreferencesService.getAccentColor(), 0xFF38BDF8);
      expect(AppPreferencesService.getDarkMode(), isFalse);
      expect(
        AppPreferencesService.getActiveWidgets(),
        equals(['active_income', 'active_expenses']),
      );

      // Legacy analytics keys preserved (not deleted).
      expect(AppPreferencesService.getMainChartStyle(), 'line');
      expect(AppPreferencesService.getDefaultPeriod(), 'weekly');
      expect(AppPreferencesService.getSubTrendStyle(), 'bar');
      expect(AppPreferencesService.getSubCategoryStyle(), 'donut');
    });

    test('11. atomic saving rolls back on error and does not leave partially updated preferences', () async {
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
            throw StateError('Simulated transaction failure before commit');
          },
        ),
        throwsStateError,
      );

      // Both in-memory cache and SQLite database must still have initialPrefs.
      expect(repository.currentPreferences, equals(initialPrefs));
      final persisted = await db.getPreferences();
      expect(persisted, equals(initialPrefs));
    });

    test('Riverpod providers read from SQLite cache and persist period updates', () async {
      await AppPreferencesService.saveMainChartStyle('line');
      await AppPreferencesService.saveDefaultPeriod('yearly');
      await AppPreferencesService.saveSubTrendStyle('donut');
      await AppPreferencesService.saveSubCategoryStyle('bar');

      await repository.init();

      final container = ProviderContainer(
        overrides: [
          analyticsCustomizationRepositoryProvider.overrideWithValue(
            repository,
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(mainChartStyleProvider), ChartVisualMode.line);
      expect(container.read(selectedPeriodProvider), AnalyticsPeriod.yearly);
      expect(container.read(subTrendChartStyleProvider), ChartVisualMode.donut);
      expect(
        container.read(subCategoryChartStyleProvider),
        ChartVisualMode.bar,
      );

      // Simulates tapping Weekly on FinancialAnalyticsScreen (temporary in-memory selection).
      container
          .read(selectedPeriodProvider.notifier)
          .setPeriod(AnalyticsPeriod.weekly);
      expect(container.read(selectedPeriodProvider), AnalyticsPeriod.weekly);
      // Temporary period selection must NOT overwrite the saved default in the repository!
      expect(repository.defaultPeriod, AnalyticsPeriod.yearly);

      // Saved default period updates persist to SQLite.
      await container
          .read(savedDefaultPeriodProvider.notifier)
          .setDefaultPeriod(AnalyticsPeriod.weekly);

      // Wait for queued SQLite persistence to finish.
      await repository.close();
      await repository.init();

      expect(repository.defaultPeriod, AnalyticsPeriod.weekly);
      // Confirm SharedPreferences was NOT overwritten by the new SQLite write.
      expect(AppPreferencesService.getDefaultPeriod(), 'yearly');
    });
  });
}
