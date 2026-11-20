import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idb_shim/idb_shim.dart';
import 'package:prot/core/services/app_preferences_service.dart';
import 'package:prot/features/analytics/data/analytics_customization_repository.dart';
import 'package:prot/features/analytics/data/analytics_customization_web_db.dart';
import 'package:prot/features/analytics/data/dashboard_layout_repository.dart';
import 'package:prot/features/analytics/data/report_export_repository.dart';
import 'package:prot/features/analytics/models/analytics_customization_preferences.dart';
import 'package:prot/features/analytics/models/dashboard_layout_preferences.dart';
import 'package:prot/features/analytics/models/report_export_preferences.dart';
import 'package:prot/features/analytics/providers/analytics_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late IdbFactory idbFactory;
  late String testDbName;
  late AnalyticsCustomizationWebDb webDb;
  late ReportExportRepository repository;
  var dbCounter = 0;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPreferencesService.init();
  });

  setUp(() async {
    await AppPreferencesService.clearAll();
    idbFactory = newIdbFactoryMemory();
    testDbName = 'test_finpulse_report_export_web_${dbCounter++}';
    webDb = AnalyticsCustomizationWebDb(
      idbFactory: idbFactory,
      databaseName: testDbName,
    );
    repository = ReportExportRepository(storage: webDb);
  });

  tearDown(() async {
    await repository.close();
    await webDb.deleteDatabase();
  });

  Future<ReportExportRepository> reopenRepository() async {
    await repository.close();
    final reopenedDb = AnalyticsCustomizationWebDb(
      idbFactory: idbFactory,
      databaseName: testDbName,
    );
    final reopenedRepo = ReportExportRepository(storage: reopenedDb);
    addTearDown(reopenedRepo.close);
    await reopenedRepo.init();
    return reopenedRepo;
  }

  group('ReportExport IndexedDB (v4)', () {
    test('fresh version 4 database creates all three object stores', () async {
      final db = await webDb.init();
      expect(webDb.isOpen, isTrue);
      expect(db.version, 4);
      expect(
        db.objectStoreNames,
        contains(AnalyticsCustomizationWebDb.storeName),
      );
      expect(
        db.objectStoreNames,
        contains(AnalyticsCustomizationWebDb.dashboardLayoutStoreName),
      );
      expect(
        db.objectStoreNames,
        contains(AnalyticsCustomizationWebDb.reportExportStoreName),
      );
    });

    test('v2-to-v4 migration preserves existing analytics customization and dashboard layout records', () async {
      // Seed a v2 IndexedDB database with both existing stores populated.
      final v2Db = await idbFactory.open(
        testDbName,
        version: 2,
        onUpgradeNeeded: (VersionChangeEvent event) {
          final database = event.database;
          database.createObjectStore(
            AnalyticsCustomizationWebDb.storeName,
            keyPath: 'profile_key',
          );
          database.createObjectStore(
            AnalyticsCustomizationWebDb.dashboardLayoutStoreName,
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
      final savedLayout = DashboardLayoutPreferences(
        activeCardIds: const ['active_savings', 'avail_inc_analytics'],
      );

      final analyticsTxn = v2Db.transaction(
        AnalyticsCustomizationWebDb.storeName,
        idbModeReadWrite,
      );
      await analyticsTxn
          .objectStore(AnalyticsCustomizationWebDb.storeName)
          .put(savedAnalytics.toMap());
      await analyticsTxn.completed;

      final layoutTxn = v2Db.transaction(
        AnalyticsCustomizationWebDb.dashboardLayoutStoreName,
        idbModeReadWrite,
      );
      await layoutTxn
          .objectStore(AnalyticsCustomizationWebDb.dashboardLayoutStoreName)
          .put(savedLayout.toMap());
      await layoutTxn.completed;
      v2Db.close();

      // Reopen with v4 AnalyticsCustomizationWebDb.
      final upgradedDb = await webDb.init();
      expect(upgradedDb.version, 4);

      final analyticsRepo = AnalyticsCustomizationRepository(db: webDb);
      final loadedAnalytics = await analyticsRepo.init();
      expect(loadedAnalytics, equals(savedAnalytics));

      final layoutRepo = DashboardLayoutRepository(storage: webDb);
      final loadedLayout = await layoutRepo.init();
      expect(loadedLayout.activeCardIds, equals(savedLayout.activeCardIds));

      // Report export defaults are loaded when no record exists yet.
      final loadedExport = await repository.init();
      expect(loadedExport, equals(const ReportExportPreferences.defaults()));
    });

    test('v3-to-v4 migration preserves existing report export records and persists custom dates', () async {
      // Seed a v3 database with existing report export store
      final v3Db = await idbFactory.open(
        testDbName,
        version: 3,
        onUpgradeNeeded: (VersionChangeEvent event) {
          final database = event.database;
          database.createObjectStore(
            AnalyticsCustomizationWebDb.storeName,
            keyPath: 'profile_key',
          );
          database.createObjectStore(
            AnalyticsCustomizationWebDb.dashboardLayoutStoreName,
            keyPath: 'profile_key',
          );
          database.createObjectStore(
            AnalyticsCustomizationWebDb.reportExportStoreName,
            keyPath: 'profile_key',
          );
        },
      );

      final v3Txn = v3Db.transaction(
        AnalyticsCustomizationWebDb.reportExportStoreName,
        idbModeReadWrite,
      );
      await v3Txn
          .objectStore(AnalyticsCustomizationWebDb.reportExportStoreName)
          .put({
            'profile_key': 'default',
            'report_format': 'Raw Data',
            'period_label': 'Last 12 Months',
            'account_scope': 'Hatton National Bank',
            'selected_requirements': '["goal_savings"]',
            'updated_at': DateTime.utc(2026, 10, 1).toIso8601String(),
          });
      await v3Txn.completed;
      v3Db.close();

      // Upgrade to v4 AnalyticsCustomizationWebDb
      final upgradedDb = await webDb.init();
      expect(upgradedDb.version, 4);

      final loadedExport = await repository.init();
      expect(loadedExport.reportFormat, 'Raw Data');
      expect(loadedExport.periodLabel, 'Last 12 Months');
      expect(loadedExport.accountScope, 'Hatton National Bank');
      expect(loadedExport.selectedRequirements, ['goal_savings']);
      expect(loadedExport.startDate, isNull);
      expect(loadedExport.endDate, isNull);

      // Save custom dates and verify persistence
      final customStart = DateTime.utc(2026, 5, 1);
      final customEnd = DateTime.utc(2026, 10, 31);
      await repository.savePreferences(
        loadedExport.copyWith(
          periodLabel: 'Custom Range',
          startDate: customStart,
          endDate: customEnd,
        ),
      );

      final restartedRepo = await reopenRepository();
      expect(restartedRepo.currentPreferences.periodLabel, 'Custom Range');
      expect(restartedRepo.currentPreferences.startDate, customStart);
      expect(restartedRepo.currentPreferences.endDate, customEnd);
    });

    test(
      'saves and restores all formats, periods, accounts, and requirements',
      () async {
        await repository.init();

        for (final format in ReportExportPreferences.supportedFormats) {
          await repository.savePreferences(
            repository.currentPreferences.copyWith(reportFormat: format),
          );
          expect(
            (await webDb.getReportExportPreferences())?.reportFormat,
            equals(format),
          );
        }

        for (final period in ReportExportPreferences.supportedPeriods) {
          await repository.savePreferences(
            repository.currentPreferences.copyWith(periodLabel: period),
          );
          expect(
            (await webDb.getReportExportPreferences())?.periodLabel,
            equals(period),
          );
        }

        for (final account in ReportExportPreferences.supportedAccounts) {
          await repository.savePreferences(
            repository.currentPreferences.copyWith(accountScope: account),
          );
          expect(
            (await webDb.getReportExportPreferences())?.accountScope,
            equals(account),
          );
        }

        const customSelection = <String>[
          'trans_history',
          'goal_savings',
          'exp_pred',
        ];
        await repository.savePreferences(
          ReportExportPreferences(
            reportFormat: 'Raw Data',
            periodLabel: 'Last 12 Months',
            accountScope: 'Cash Wallet',
            selectedRequirements: customSelection,
          ),
        );

        final reopenedRepo = await reopenRepository();
        expect(reopenedRepo.currentPreferences.reportFormat, 'Raw Data');
        expect(reopenedRepo.currentPreferences.periodLabel, 'Last 12 Months');
        expect(reopenedRepo.currentPreferences.accountScope, 'Cash Wallet');
        expect(
          reopenedRepo.currentPreferences.selectedRequirements,
          equals(customSelection),
        );
      },
    );

    test('Select All, Deselect All, and empty requirements list persist across restart', () async {
      await repository.init();
      final container = ProviderContainer(
        overrides: [
          reportExportRepositoryProvider.overrideWithValue(repository),
        ],
      );

      final notifier = container.read(exportPreferencesProvider.notifier);

      // Select All.
      await notifier.selectAll(ReportExportPreferences.allRequirementIds);
      expect(
        container.read(exportPreferencesProvider).selectedRequirements,
        equals(ReportExportPreferences.allRequirementIds.toSet()),
      );

      // Deselect All.
      await notifier.selectAll(ReportExportPreferences.allRequirementIds);
      expect(
        container.read(exportPreferencesProvider).selectedRequirements,
        isEmpty,
      );

      container.dispose();
      final reopenedRepo = await reopenRepository();
      final restartedContainer = ProviderContainer(
        overrides: [
          reportExportRepositoryProvider.overrideWithValue(reopenedRepo),
        ],
      );
      addTearDown(restartedContainer.dispose);

      expect(
        restartedContainer.read(exportPreferencesProvider).selectedRequirements,
        isEmpty,
      );
    });

    test(
      'invalid stored values and unknown requirement IDs are sanitized on load',
      () async {
        final db = await webDb.init();
        final txn = db.transaction(
          AnalyticsCustomizationWebDb.reportExportStoreName,
          idbModeReadWrite,
        );
        await txn
            .objectStore(AnalyticsCustomizationWebDb.reportExportStoreName)
            .put({
              'profile_key': ReportExportPreferences.defaultProfileKey,
              'report_format': 'DOCX',
              'period_label': 'Invalid Range',
              'account_scope': 'NonExistent Bank',
              'selected_requirements':
                  '["exp_analysis","bogus_id","exp_analysis","goal_savings"]',
              'updated_at': '2026-10-20T12:00:00.000Z',
            });
        await txn.completed;

        final loaded = await repository.init();
        expect(loaded.reportFormat, ExportPreferencesState.defaultFormat);
        expect(loaded.periodLabel, ExportPreferencesState.defaultPeriod);
        expect(loaded.accountScope, ExportPreferencesState.defaultAccount);
        expect(
          loaded.selectedRequirements,
          equals(const ['exp_analysis', 'goal_savings']),
        );
      },
    );

    test('atomic write aborts IndexedDB transaction and preserves cached state on failure', () async {
      await repository.init();
      final initial = ReportExportPreferences(
        reportFormat: 'Excel (.XLSX)',
        periodLabel: 'September 2026',
        accountScope: 'Commercial Bank',
        selectedRequirements: const ['inc_analysis'],
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
            throw StateError('Simulated IndexedDB failure before commit');
          },
        ),
        throwsA(isA<StateError>()),
      );

      expect(repository.currentPreferences, equals(initial));

      final persisted = await webDb.getReportExportPreferences();
      expect(persisted, equals(initial));
    });
  });
}
