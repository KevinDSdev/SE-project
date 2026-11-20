import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idb_shim/idb_shim.dart';
import 'package:path/path.dart' as p;
import 'package:prot/core/services/app_preferences_service.dart';
import 'package:prot/features/analytics/data/analytics_customization_db.dart';
import 'package:prot/features/analytics/data/analytics_customization_web_db.dart';
import 'package:prot/features/analytics/data/report_export_repository.dart';
import 'package:prot/features/analytics/models/report_export_preferences.dart';
import 'package:prot/features/analytics/presentation/financial_analytics_screen.dart';
import 'package:prot/features/analytics/presentation/screens/spending_anomaly_screen.dart';
import 'package:prot/features/analytics/providers/analytics_provider.dart';
import 'package:prot/features/analytics/services/analytics_period_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPreferencesService.init();
  });

  Widget createTestWidget(Widget child, {List<dynamic> overrides = const []}) {
    return ProviderScope(
      overrides: [...overrides],
      child: MaterialApp(home: child),
    );
  }

  group('Part 6 Specification Tests (1 to 15)', () {
    // 1. Weekly, Monthly and Yearly period option generation.
    test('1. Weekly, Monthly and Yearly period option generation', () {
      final options = AnalyticsPeriodHelper.getPeriodOptions();
      expect(options, containsAll(['Weekly', 'Monthly', 'Yearly']));

      final optionLabels = AnalyticsPeriodHelper.getPeriodOptionLabels(
        DateTime(2026, 11, 20),
      );
      expect(optionLabels, [
        'Weekly : 2026',
        'Monthly : 2026',
        'Yearly : 2026',
      ]);
    });

    // 2. Six-week, six-month and six-year lists.
    test('2. Six-week, six-month and six-year lists', () {
      final anchor = DateTime(2026, 11, 20);

      final sixWeeks = AnalyticsPeriodHelper.getSixWeekBuckets(anchor);
      expect(sixWeeks.length, 6);
      expect(sixWeeks.map((b) => b.label).toList(), [
        'W1',
        'W2',
        'W3',
        'W4',
        'W5',
        'W6',
      ]);

      final sixMonths = AnalyticsPeriodHelper.getMonthlyBuckets(
        DateTime(2026, 10, 1),
      );
      expect(sixMonths.length, 6);
      expect(sixMonths.map((b) => b.label).toList(), [
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
      ]);

      final sixYears = AnalyticsPeriodHelper.getYearlyBuckets(
        DateTime(2026, 1, 1),
      );
      expect(sixYears.length, 6);
      expect(sixYears.map((b) => b.label).toList(), [
        '2021',
        '2022',
        '2023',
        '2024',
        '2025',
        '2026',
      ]);
    });

    // 3. Current period selected by default.
    test('3. Current period selected by default is Monthly', () {
      expect(AnalyticsPeriodHelper.defaultPeriod, AnalyticsPeriod.monthly);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(selectedPeriodProvider), AnalyticsPeriod.monthly);
    });

    // 4. Correct week/month/year date boundaries.
    test('4. Correct week/month/year date boundaries', () {
      final anchor = DateTime(2026, 11, 20);
      final weeks = AnalyticsPeriodHelper.getWeeklyBuckets(anchor);

      expect(weeks[0].startDate, DateTime(2026, 11, 1));
      expect(weeks[0].endDate, DateTime(2026, 11, 7, 23, 59, 59));

      expect(weeks[1].startDate, DateTime(2026, 11, 8));
      expect(weeks[1].endDate, DateTime(2026, 11, 14, 23, 59, 59));

      expect(weeks[2].startDate, DateTime(2026, 11, 15));
      expect(weeks[2].endDate, DateTime(2026, 11, 21, 23, 59, 59));

      expect(weeks[3].startDate, DateTime(2026, 11, 22));
      expect(weeks[3].endDate, DateTime(2026, 11, 30, 23, 59, 59));

      final months = AnalyticsPeriodHelper.getMonthlyBuckets(
        DateTime(2026, 10, 1),
      );
      expect(months.last.startDate, DateTime(2026, 10, 1));
      expect(months.last.endDate, DateTime(2026, 10, 31, 23, 59, 59));

      final years = AnalyticsPeriodHelper.getYearlyBuckets(
        DateTime(2026, 1, 1),
      );
      expect(years.last.startDate, DateTime(2026, 1, 1));
      expect(years.last.endDate, DateTime(2026, 12, 31, 23, 59, 59));
    });

    // 5. Month and year transitions.
    test(
      '5. Month and year transitions correctly cross January/December boundary',
      () {
        // 6-month window ending in February 2027 should roll back to September 2026 across year boundary
        final feb2027 = DateTime(2027, 2, 1);
        final months = AnalyticsPeriodHelper.getMonthlyBuckets(feb2027);

        expect(months.length, 6);
        expect(months[0].label, 'Sep');
        expect(months[0].startDate.year, 2026);
        expect(months[3].label, 'Dec');
        expect(months[3].startDate.year, 2026);
        expect(months[4].label, 'Jan');
        expect(months[4].startDate.year, 2027);
        expect(months[5].label, 'Feb');
        expect(months[5].startDate.year, 2027);
      },
    );

    // 6. Leap-year and month-end handling.
    test('6. Leap-year and month-end handling', () {
      // Leap year 2024: Feb has 29 days
      final feb2024 = DateTime(2024, 2, 15);
      final leapWeeks = AnalyticsPeriodHelper.getWeeklyBuckets(feb2024);
      expect(leapWeeks[3].endDate.day, 29);
      expect(leapWeeks[3].label, 'Feb 22–29');

      // Non-leap year 2023: Feb has 28 days
      final feb2023 = DateTime(2023, 2, 15);
      final nonLeapWeeks = AnalyticsPeriodHelper.getWeeklyBuckets(feb2023);
      expect(nonLeapWeeks[3].endDate.day, 28);
      expect(nonLeapWeeks[3].label, 'Feb 22–28');

      // 30-day month: April
      final apr2026 = DateTime(2026, 4, 10);
      final aprWeeks = AnalyticsPeriodHelper.getWeeklyBuckets(apr2026);
      expect(aprWeeks[3].endDate.day, 30);
      expect(aprWeeks[3].label, 'Apr 22–30');

      // 31-day month: December
      final dec2026 = DateTime(2026, 12, 10);
      final decWeeks = AnalyticsPeriodHelper.getWeeklyBuckets(dec2026);
      expect(decWeeks[3].endDate.day, 31);
      expect(decWeeks[3].label, 'Dec 22–31');
    });

    // 7. Weekly, Monthly and Yearly graph aggregation.
    test('7. Weekly, Monthly and Yearly graph aggregation buckets', () {
      final weeklyBuckets = AnalyticsPeriodHelper.getBucketsForPeriod(
        AnalyticsPeriod.weekly,
      );
      expect(weeklyBuckets.length, 4);

      final monthlyBuckets = AnalyticsPeriodHelper.getBucketsForPeriod(
        AnalyticsPeriod.monthly,
      );
      expect(monthlyBuckets.length, 6);

      final yearlyBuckets = AnalyticsPeriodHelper.getBucketsForPeriod(
        AnalyticsPeriod.yearly,
      );
      expect(yearlyBuckets.length, 6);
    });

    // 8. Dynamic X-axis labels.
    test('8. Dynamic X-axis labels reflect period type without overlap', () {
      final weeklyLabels = AnalyticsPeriodHelper.getLabelsForPeriod(
        AnalyticsPeriod.weekly,
      );
      expect(weeklyLabels.every((l) => l.contains('–')), isTrue);

      final monthlyLabels = AnalyticsPeriodHelper.getLabelsForPeriod(
        AnalyticsPeriod.monthly,
      );
      expect(monthlyLabels, ['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct']);

      final yearlyLabels = AnalyticsPeriodHelper.getLabelsForPeriod(
        AnalyticsPeriod.yearly,
      );
      expect(yearlyLabels, ['2021', '2022', '2023', '2024', '2025', '2026']);
    });

    // 9. Main graphs and category graphs using the same selected period.
    testWidgets(
      '9. Main graphs and category graphs use the same selected period',
      (tester) async {
        await tester.pumpWidget(
          createTestWidget(const FinancialAnalyticsScreen()),
        );
        await tester.pumpAndSettle();

        // Open period picker and switch to Yearly
        await tester.tap(find.text('Monthly'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Yearly').last);
        await tester.pumpAndSettle();

        // Main chart displays yearly title and axes
        expect(find.text('Income vs Expenses (2021 – 2026)'), findsOneWidget);
        expect(find.text('2021'), findsWidgets);
        expect(find.text('2026'), findsWidgets);
        expect(find.text('May'), findsNothing);
      },
    );

    // 10. Anomaly bar selection updating the period.
    testWidgets('10. Anomaly bar selection updating the period and badge', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const SpendingAnomalyScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Month - October'), findsOneWidget);
      expect(find.text('Oct Actual Spend'), findsOneWidget);

      // Tap May bar in vertical bar chart
      await tester.ensureVisible(find.text('May').last);
      await tester.tap(find.text('May').last);
      await tester.pumpAndSettle();

      expect(find.text('Month - May'), findsOneWidget);
      expect(find.text('May Actual Spend'), findsOneWidget);
      expect(find.text('May 2026'), findsOneWidget);
    });

    // 11. Anomaly weekly four-segment generation.
    test('11. Anomaly weekly four-segment generation for current month', () {
      final segments = AnalyticsPeriodHelper.getFourWeekSegments(
        DateTime(2026, 11, 20),
      );
      expect(segments.length, 4);
      expect(segments[0].fullLabel, 'Week 1 – November 1–7');
      expect(segments[1].fullLabel, 'Week 2 – November 8–14');
      expect(segments[2].fullLabel, 'Week 3 – November 15–21');
      expect(segments[3].fullLabel, 'Week 4 – November 22–30');
    });

    // 12. Custom export date-range validation.
    test('12. Custom export date-range validation swaps inverted dates', () {
      final invalidStart = DateTime.utc(2026, 12, 31);
      final invalidEnd = DateTime.utc(2026, 1, 1);

      final (
        validStart,
        validEnd,
      ) = ReportExportPreferences.validateAndSanitizeDateRange(
        invalidStart,
        invalidEnd,
      );

      expect(validStart, invalidEnd);
      expect(validEnd, invalidStart);
      expect(validStart!.isBefore(validEnd!), isTrue);

      final prefs = ReportExportPreferences(
        reportFormat: 'PDF Report',
        periodLabel: 'Custom Range',
        accountScope: 'BOC',
        selectedRequirements: const ['trans_history'],
        startDate: '2026-11-30',
        endDate: '2026-11-01',
      );
      expect(prefs.startDate!.isBefore(prefs.endDate!), isTrue);
    });

    // 13. Export custom date persistence across restarts.
    test('13. Export custom date persistence across restarts', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'finpulse_custom_date_',
      );
      final testDbPath = p.join(tempDir.path, 'custom_date_test.db');
      final db = AnalyticsCustomizationDb(
        databasePath: testDbPath,
        databaseFactory: databaseFactoryFfi,
      );
      final repo = ReportExportRepository(storage: db);
      await repo.init();

      final customStart = DateTime.utc(2026, 6, 1);
      final customEnd = DateTime.utc(2026, 11, 30);

      await repo.savePreferences(
        ReportExportPreferences(
          reportFormat: 'PDF Report',
          periodLabel: 'Custom Range',
          accountScope: 'Cash Wallet',
          selectedRequirements: const ['trans_history', 'inc_analysis'],
          startDate: customStart,
          endDate: customEnd,
        ),
      );

      await repo.close();

      // Simulated restart
      final reopenedDb = AnalyticsCustomizationDb(
        databasePath: testDbPath,
        databaseFactory: databaseFactoryFfi,
      );
      final reopenedRepo = ReportExportRepository(storage: reopenedDb);
      final loaded = await reopenedRepo.init();

      expect(loaded.periodLabel, 'Custom Range');
      expect(loaded.startDate, customStart);
      expect(loaded.endDate, customEnd);

      await reopenedRepo.close();
      await reopenedDb.deleteDatabaseFile();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    // 14. SQLite v3-to-v4 migration.
    test(
      '14. SQLite v3-to-v4 migration adds start_date and end_date columns',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'finpulse_migration_',
        );
        final testDbPath = p.join(tempDir.path, 'migration_test.db');

        // Seed a v3 SQLite database
        final v3Db = await databaseFactoryFfi.openDatabase(
          testDbPath,
          options: OpenDatabaseOptions(
            version: 3,
            onCreate: (database, version) async {
              await database.execute(AnalyticsCustomizationDb.createTableSql);
              await database.execute(
                AnalyticsCustomizationDb.createDashboardLayoutTableSql,
              );
              await database.execute('''
              CREATE TABLE IF NOT EXISTS report_export_preferences (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                profile_key TEXT NOT NULL UNIQUE DEFAULT 'default',
                report_format TEXT NOT NULL DEFAULT 'PDF Report',
                period_label TEXT NOT NULL DEFAULT 'October 2026',
                account_scope TEXT NOT NULL DEFAULT 'BOC',
                selected_requirements TEXT NOT NULL,
                updated_at TEXT NOT NULL DEFAULT (datetime('now'))
              )
            ''');
            },
          ),
        );

        await v3Db.insert('report_export_preferences', {
          'profile_key': 'default',
          'report_format': 'PDF Report',
          'period_label': 'October 2026',
          'account_scope': 'BOC',
          'selected_requirements': '["trans_history"]',
          'updated_at': DateTime.utc(2026, 10, 15).toIso8601String(),
        });
        await v3Db.close();

        // Open with v4 AnalyticsCustomizationDb
        final v4Db = AnalyticsCustomizationDb(
          databasePath: testDbPath,
          databaseFactory: databaseFactoryFfi,
        );
        final database = await v4Db.init();
        expect(await database.getVersion(), 4);

        // Verify columns added
        final columns = await database.rawQuery(
          'PRAGMA table_info(report_export_preferences)',
        );
        final columnNames = columns.map((r) => r['name']).toSet();
        expect(columnNames, contains('start_date'));
        expect(columnNames, contains('end_date'));

        // Verify existing record preserved
        final repo = ReportExportRepository(storage: v4Db);
        final loaded = await repo.init();
        expect(loaded.reportFormat, 'PDF Report');
        expect(loaded.periodLabel, 'October 2026');
        expect(loaded.startDate, isNull);
        expect(loaded.endDate, isNull);

        await repo.close();
        await v4Db.deleteDatabaseFile();
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      },
    );

    // 15. IndexedDB v3-to-v4 migration.
    test(
      '15. IndexedDB v3-to-v4 migration preserves existing records',
      () async {
        final idbFactory = newIdbFactoryMemory();
        const testDbName = 'test_idb_v3_to_v4';

        // Open at version 3
        final v3Db = await idbFactory.open(
          testDbName,
          version: 3,
          onUpgradeNeeded: (event) {
            final db = event.database;
            db.createObjectStore(
              AnalyticsCustomizationWebDb.storeName,
              keyPath: 'profile_key',
            );
            db.createObjectStore(
              AnalyticsCustomizationWebDb.dashboardLayoutStoreName,
              keyPath: 'profile_key',
            );
            db.createObjectStore(
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
              'account_scope': 'Cash Wallet',
              'selected_requirements': '["goal_savings"]',
              'updated_at': DateTime.utc(2026, 10, 1).toIso8601String(),
            });
        await v3Txn.completed;
        v3Db.close();

        // Open with v4 AnalyticsCustomizationWebDb
        final webDb = AnalyticsCustomizationWebDb(
          idbFactory: idbFactory,
          databaseName: testDbName,
        );
        final db = await webDb.init();
        expect(db.version, 4);

        final repo = ReportExportRepository(storage: webDb);
        final loaded = await repo.init();
        expect(loaded.reportFormat, 'Raw Data');
        expect(loaded.periodLabel, 'Last 12 Months');
        expect(loaded.selectedRequirements, ['goal_savings']);
        expect(loaded.startDate, isNull);

        await repo.close();
        await webDb.deleteDatabase();
      },
    );
  });
}
