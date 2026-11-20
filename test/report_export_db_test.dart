import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:prot/core/services/app_preferences_service.dart';
import 'package:prot/features/analytics/data/analytics_customization_db.dart';
import 'package:prot/features/analytics/data/analytics_customization_repository.dart';
import 'package:prot/features/analytics/data/dashboard_layout_repository.dart';
import 'package:prot/features/analytics/data/report_export_repository.dart';
import 'package:prot/features/analytics/models/analytics_customization_preferences.dart';
import 'package:prot/features/analytics/models/dashboard_layout_preferences.dart';
import 'package:prot/features/analytics/models/report_export_preferences.dart';
import 'package:prot/features/analytics/presentation/screens/report_export_screen.dart';
import 'package:prot/features/analytics/presentation/screens/select_export_requirement_screen.dart';
import 'package:prot/features/analytics/providers/analytics_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Directory tempDir;
  late String testDbPath;
  late AnalyticsCustomizationDb db;
  late ReportExportRepository repository;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPreferencesService.init();
  });

  setUp(() async {
    await AppPreferencesService.clearAll();
    tempDir = await Directory.systemTemp.createTemp(
      'finpulse_report_export_test_',
    );
    testDbPath = p.join(tempDir.path, 'test_report_export.db');
    db = AnalyticsCustomizationDb(
      databasePath: testDbPath,
      databaseFactory: databaseFactoryFfi,
    );
    repository = ReportExportRepository(storage: db);
  });

  tearDown(() async {
    await repository.close();
    await db.deleteDatabaseFile();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<ReportExportRepository> reopenRepository() async {
    await repository.close();
    final reopenedDb = AnalyticsCustomizationDb(
      databasePath: testDbPath,
      databaseFactory: databaseFactoryFfi,
    );
    final reopenedRepo = ReportExportRepository(storage: reopenedDb);
    addTearDown(reopenedRepo.close);
    await reopenedRepo.init();
    return reopenedRepo;
  }

  group('ReportExport SQLite (v3)', () {
    test('fresh database creates all three tables with expected columns', () async {
      final database = await db.init();
      expect(database.isOpen, isTrue);
      expect(await database.getVersion(), 3);

      final tables = await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table'",
      );
      final tableNames = tables.map((row) => row['name']).toSet();

      expect(tableNames, contains(AnalyticsCustomizationDb.tableName));
      expect(
        tableNames,
        contains(AnalyticsCustomizationDb.dashboardLayoutTableName),
      );
      expect(
        tableNames,
        contains(AnalyticsCustomizationDb.reportExportTableName),
      );

      final columns = await database.rawQuery(
        'PRAGMA table_info(${AnalyticsCustomizationDb.reportExportTableName})',
      );
      final columnNames = columns.map((row) => row['name']).toSet();
      expect(
        columnNames,
        containsAll(<String>[
          'id',
          'profile_key',
          'report_format',
          'period_label',
          'account_scope',
          'selected_requirements',
          'updated_at',
        ]),
      );
    });

    test('v2-to-v3 migration preserves existing analytics customization and dashboard layout records', () async {
      // Seed a v2 database with existing records in both v1 & v2 tables.
      final v2Db = await databaseFactoryFfi.openDatabase(
        testDbPath,
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: (database, version) async {
            await database.execute(AnalyticsCustomizationDb.createTableSql);
            await database.execute(
              AnalyticsCustomizationDb.createDashboardLayoutTableSql,
            );
          },
        ),
      );

      const savedAnalytics = AnalyticsCustomizationPreferences(
        mainChartStyle: ChartVisualMode.donut,
        defaultPeriod: AnalyticsPeriod.yearly,
        subTrendChartStyle: ChartVisualMode.bar,
        subCategoryChartStyle: ChartVisualMode.line,
      );
      final savedLayout = DashboardLayoutPreferences(
        activeCardIds: const ['active_trend', 'avail_anomaly'],
      );

      await v2Db.insert(
        AnalyticsCustomizationDb.tableName,
        savedAnalytics.toMap(),
      );
      await v2Db.insert(
        AnalyticsCustomizationDb.dashboardLayoutTableName,
        savedLayout.toMap(),
      );
      await v2Db.close();

      // Reopen with v3 AnalyticsCustomizationDb.
      final upgradedDb = await db.init();
      expect(await upgradedDb.getVersion(), 3);

      final analyticsRepo = AnalyticsCustomizationRepository(db: db);
      final loadedAnalytics = await analyticsRepo.init();
      expect(loadedAnalytics, equals(savedAnalytics));

      final layoutRepo = DashboardLayoutRepository(storage: db);
      final loadedLayout = await layoutRepo.init();
      expect(loadedLayout.activeCardIds, equals(savedLayout.activeCardIds));

      // Report export defaults are loaded when no record exists yet.
      final loadedExport = await repository.init();
      expect(loadedExport, equals(const ReportExportPreferences.defaults()));
    });

    test('saves and loads all supported report formats', () async {
      await repository.init();

      for (final format in ReportExportPreferences.supportedFormats) {
        await repository.savePreferences(
          repository.currentPreferences.copyWith(reportFormat: format),
        );

        final loaded = await db.getReportExportPreferences();
        expect(loaded, isNotNull);
        expect(loaded!.reportFormat, equals(format));
      }
    });

    test('saves and restores all supported period labels', () async {
      await repository.init();

      for (final period in ReportExportPreferences.supportedPeriods) {
        await repository.savePreferences(
          repository.currentPreferences.copyWith(periodLabel: period),
        );

        final loaded = await db.getReportExportPreferences();
        expect(loaded, isNotNull);
        expect(loaded!.periodLabel, equals(period));
      }
    });

    test('saves and restores all supported account selections', () async {
      await repository.init();

      for (final account in ReportExportPreferences.supportedAccounts) {
        await repository.savePreferences(
          repository.currentPreferences.copyWith(accountScope: account),
        );

        final loaded = await db.getReportExportPreferences();
        expect(loaded, isNotNull);
        expect(loaded!.accountScope, equals(account));
      }
    });

    test('saves and restores selected analytics requirements', () async {
      await repository.init();
      const customSelection = <String>[
        'exp_analysis',
        'inc_pred',
        'debt_invest',
      ];

      await repository.savePreferences(
        repository.currentPreferences.copyWith(
          selectedRequirements: customSelection,
        ),
      );

      final reopenedRepo = await reopenRepository();
      expect(
        reopenedRepo.currentPreferences.selectedRequirements,
        equals(customSelection),
      );
    });

    test('preserves an intentionally empty requirements list', () async {
      await repository.init();
      await repository.savePreferences(
        repository.currentPreferences.copyWith(
          selectedRequirements: const <String>[],
        ),
      );

      final reopenedRepo = await reopenRepository();
      expect(reopenedRepo.currentPreferences.selectedRequirements, isEmpty);
    });

    test(
      'sanitizes invalid values, duplicates, and unknown requirement IDs',
      () async {
        final sanitized = ReportExportPreferences.fromMap({
          'profile_key': '   ',
          'report_format': 'Unsupported Format',
          'period_label': 'Invalid Period',
          'account_scope': 'Unknown Bank',
          'selected_requirements':
              '["inc_analysis","unknown_module","inc_analysis","debt_invest"]',
          'updated_at': '2026-10-20T12:30:00.000Z',
        });

        expect(
          sanitized.profileKey,
          equals(ReportExportPreferences.defaultProfileKey),
        );
        expect(
          sanitized.reportFormat,
          equals(ExportPreferencesState.defaultFormat),
        );
        expect(
          sanitized.periodLabel,
          equals(ExportPreferencesState.defaultPeriod),
        );
        expect(
          sanitized.accountScope,
          equals(ExportPreferencesState.defaultAccount),
        );
        expect(
          sanitized.selectedRequirements,
          equals(const ['inc_analysis', 'debt_invest']),
        );
        expect(sanitized.updatedAt?.isUtc, isTrue);

        // Malformed JSON falls back to defaults.
        final malformed = ReportExportPreferences.fromMap({
          'selected_requirements': '{not-valid-json',
        });
        expect(
          malformed.selectedRequirements,
          equals(ExportPreferencesState.defaultSelectedRequirements),
        );
      },
    );

    test('atomic write rolls back SQLite transaction and preserves cached state on failure', () async {
      await repository.init();
      final initial = ReportExportPreferences(
        reportFormat: 'Excel (.XLSX)',
        periodLabel: 'September 2026',
        accountScope: 'Commercial Bank',
        selectedRequirements: const ['trans_history', 'exp_analysis'],
      );
      await repository.savePreferences(initial);

      final failedUpdate = ReportExportPreferences(
        reportFormat: 'Raw Data',
        periodLabel: 'Last 12 Months',
        accountScope: 'Cash Wallet',
        selectedRequirements: const ['debt_invest'],
      );

      await expectLater(
        repository.savePreferences(
          failedUpdate,
          beforeCommitHook: (_) async {
            throw StateError('Simulated SQLite failure before commit');
          },
        ),
        throwsA(isA<StateError>()),
      );

      // Cache was not updated on failed save.
      expect(repository.currentPreferences, equals(initial));

      // Persisted SQLite row rolled back and still holds initial values.
      final persisted = await db.getReportExportPreferences();
      expect(persisted, equals(initial));
    });
  });

  group('ExportPreferencesNotifier & UI persistence (SQLite)', () {
    test('Select All, Deselect All, and individual updates persist across simulated restart', () async {
      await repository.init();
      final container = ProviderContainer(
        overrides: [
          reportExportRepositoryProvider.overrideWithValue(repository),
        ],
      );

      final notifier = container.read(exportPreferencesProvider.notifier);

      // Verify defaults match ExportPreferencesState.
      final initial = container.read(exportPreferencesProvider);
      expect(initial.format, ExportPreferencesState.defaultFormat);
      expect(initial.period, ExportPreferencesState.defaultPeriod);
      expect(initial.account, ExportPreferencesState.defaultAccount);
      expect(
        initial.selectedRequirements,
        equals(ExportPreferencesState.defaultSelectedRequirements.toSet()),
      );

      // Update format, period, account, and Select All.
      await notifier.setFormat('Excel (.XLSX)');
      await notifier.setPeriod('Q3 2026 (Jul - Sep)');
      await notifier.setAccount('Hatton National Bank');
      await notifier.selectAll(ReportExportPreferences.allRequirementIds);

      expect(
        container.read(exportPreferencesProvider).selectedRequirements,
        equals(ReportExportPreferences.allRequirementIds.toSet()),
      );

      // Simulate app restart.
      container.dispose();
      final reopenedAfterSelectAll = await reopenRepository();
      final restartedContainer1 = ProviderContainer(
        overrides: [
          reportExportRepositoryProvider.overrideWithValue(
            reopenedAfterSelectAll,
          ),
        ],
      );
      addTearDown(restartedContainer1.dispose);

      final restored1 = restartedContainer1.read(exportPreferencesProvider);
      expect(restored1.format, 'Excel (.XLSX)');
      expect(restored1.period, 'Q3 2026 (Jul - Sep)');
      expect(restored1.account, 'Hatton National Bank');
      expect(
        restored1.selectedRequirements,
        equals(ReportExportPreferences.allRequirementIds.toSet()),
      );

      // Deselect All persists empty requirements list across another restart.
      await restartedContainer1
          .read(exportPreferencesProvider.notifier)
          .selectAll(ReportExportPreferences.allRequirementIds);
      expect(
        restartedContainer1
            .read(exportPreferencesProvider)
            .selectedRequirements,
        isEmpty,
      );

      await reopenedAfterSelectAll.close();
      final reopenedAfterDeselectAll = AnalyticsCustomizationDb(
        databasePath: testDbPath,
        databaseFactory: databaseFactoryFfi,
      );
      final finalRepo = ReportExportRepository(
        storage: reopenedAfterDeselectAll,
      );
      addTearDown(finalRepo.close);
      await finalRepo.init();

      final restartedContainer2 = ProviderContainer(
        overrides: [
          reportExportRepositoryProvider.overrideWithValue(finalRepo),
        ],
      );
      addTearDown(restartedContainer2.dispose);

      final restored2 = restartedContainer2.read(exportPreferencesProvider);
      expect(restored2.selectedRequirements, isEmpty);
      expect(restored2.format, 'Excel (.XLSX)');
    });

    testWidgets(
      'ReportExportScreen and SelectExportRequirementScreen restore persisted selections after restart',
      (WidgetTester tester) async {
        late ReportExportRepository restartedRepo;
        await tester.runAsync(() async {
          await repository.init();
          await repository.savePreferences(
            ReportExportPreferences(
              reportFormat: 'Raw Data',
              periodLabel: 'Year-to-Date 2026',
              accountScope: 'All Accounts (Consolidated)',
              selectedRequirements: const ['trans_history', 'debt_invest'],
            ),
          );

          // Simulate full restart with fresh DB + Repository.
          await repository.close();
          final restartedDb = AnalyticsCustomizationDb(
            databasePath: testDbPath,
            databaseFactory: databaseFactoryFfi,
          );
          restartedRepo = ReportExportRepository(storage: restartedDb);
          await restartedRepo.init();
        });

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              reportExportRepositoryProvider.overrideWithValue(restartedRepo),
            ],
            child: const MaterialApp(home: ReportExportScreen()),
          ),
        );

        expect(find.text('Year-to-Date 2026'), findsOneWidget);
        expect(find.text('All Accounts (Consolidated)'), findsOneWidget);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              reportExportRepositoryProvider.overrideWithValue(restartedRepo),
            ],
            child: const MaterialApp(home: SelectExportRequirementScreen()),
          ),
        );

        expect(find.text('2 of 7 modules selected'), findsOneWidget);

        await tester.runAsync(() async {
          await restartedRepo.close();
        });
      },
    );
  });
}
