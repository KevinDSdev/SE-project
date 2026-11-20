import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:prot/core/services/app_preferences_service.dart';
import 'package:prot/features/analytics/data/analytics_customization_db.dart';
import 'package:prot/features/analytics/data/analytics_customization_storage.dart';
import 'package:prot/features/analytics/data/report_export_repository.dart';
import 'package:prot/features/analytics/models/report_export_preferences.dart';
import 'package:prot/features/analytics/presentation/screens/report_export_screen.dart';
import 'package:prot/features/analytics/providers/analytics_provider.dart';
import 'package:prot/features/analytics/services/analytics_period_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPreferencesService.init();
    AnalyticsPeriodHelper.resetClockForTesting();
  });

  tearDown(() {
    AnalyticsPeriodHelper.resetClockForTesting();
  });

  Widget createTestWidget(Widget child, {List<dynamic> overrides = const []}) {
    return ProviderScope(
      overrides: [...overrides],
      child: MaterialApp(home: child),
    );
  }

  group('Dynamic Report Export Period Tests', () {
    // 1. Six latest calendar weeks with Monday-to-Sunday boundaries
    test('1. Generates latest six calendar weeks ending with current week', () {
      final anchor = DateTime(2026, 11, 20); // Friday
      final weeks = AnalyticsPeriodHelper.getExportWeeklyBuckets(anchor);

      expect(weeks.length, 6);
      // All weeks start on Monday (weekday 1) and end on Sunday (weekday 7)
      for (final w in weeks) {
        expect(w.startDate.weekday, DateTime.monday);
        expect(w.endDate.weekday, DateTime.sunday);
        expect(w.endDate.hour, 23);
        expect(w.endDate.minute, 59);
        expect(w.endDate.second, 59);
      }

      // Latest week is the current week containing Nov 20, 2026
      expect(weeks.last.startDate, DateTime(2026, 11, 16));
      expect(weeks.last.endDate, DateTime(2026, 11, 22, 23, 59, 59));
      expect(weeks.last.label, 'Nov 16 – Nov 22, 2026');
      expect(weeks.last.fullLabel, contains('Current Week'));
    });

    // 2. Week boundaries crossing months and years
    test('2. Week boundaries correctly cross month and year boundaries', () {
      // Month boundary: Nov 20, 2026 -> 3 weeks back crosses into October
      final anchor = DateTime(2026, 11, 20);
      final weeks = AnalyticsPeriodHelper.getExportWeeklyBuckets(anchor);

      // Week starting Oct 26, 2026 ends Nov 1, 2026
      final crossMonthWeek = weeks.firstWhere(
        (w) => w.startDate.month != w.endDate.month,
      );
      expect(crossMonthWeek.startDate, DateTime(2026, 10, 26));
      expect(crossMonthWeek.endDate, DateTime(2026, 11, 1, 23, 59, 59));
      expect(crossMonthWeek.label, 'Oct 26 – Nov 1, 2026');

      // Year boundary: January 1, 2027 (Friday)
      final newYearAnchor = DateTime(2027, 1, 1);
      final newYearWeeks = AnalyticsPeriodHelper.getExportWeeklyBuckets(
        newYearAnchor,
      );

      final crossYearWeek = newYearWeeks.firstWhere(
        (w) => w.startDate.year != w.endDate.year,
      );
      expect(crossYearWeek.startDate, DateTime(2026, 12, 28));
      expect(crossYearWeek.endDate, DateTime(2027, 1, 3, 23, 59, 59));
      expect(crossYearWeek.label, 'Dec 28, 2026 – Jan 3, 2027');
    });

    // 3. Six latest calendar months dynamically generated
    test('3. Generates latest six calendar months dynamically', () {
      final anchor = DateTime(2026, 11, 20);
      final months = AnalyticsPeriodHelper.getExportMonthlyBuckets(anchor);

      expect(months.length, 6);
      expect(months.map((m) => m.label).toList(), [
        'June 2026',
        'July 2026',
        'August 2026',
        'September 2026',
        'October 2026',
        'November 2026',
      ]);

      expect(months.last.fullLabel, contains('Current Month'));
      expect(months.last.startDate, DateTime(2026, 11, 1));
      expect(months.last.endDate, DateTime(2026, 11, 30, 23, 59, 59));
    });

    // 4. Six latest calendar years dynamically generated
    test('4. Generates latest six calendar years dynamically', () {
      final anchor = DateTime(2026, 11, 20);
      final years = AnalyticsPeriodHelper.getExportYearlyBuckets(anchor);

      expect(years.length, 6);
      expect(years.map((y) => y.label).toList(), [
        '2021',
        '2022',
        '2023',
        '2024',
        '2025',
        '2026',
      ]);

      expect(years.last.fullLabel, contains('Current Year'));
      expect(years.last.startDate, DateTime(2026, 1, 1));
      expect(years.last.endDate, DateTime(2026, 12, 31, 23, 59, 59));
    });

    // 5. Automatic rollover using controlled test dates
    test('5. Automatic date rollover when clock advances', () {
      // Step A: Baseline clock at Nov 16, 2026
      AnalyticsPeriodHelper.setClockForTesting(() => DateTime(2026, 11, 16));

      // Previously selected week 5 weeks ago: Oct 12 – Oct 18, 2026
      final initialWeeks = AnalyticsPeriodHelper.getExportWeeklyBuckets();
      final oldestWeek = initialWeeks.first.label; // Oct 12 – Oct 18, 2026

      var rollover = AnalyticsPeriodHelper.resolveExportPeriodRollover(
        periodType: 'Weekly',
        periodLabel: oldestWeek,
      );
      // Still in 6-week window
      expect(rollover.periodLabel, oldestWeek);

      // Step B: Advance clock by 1 week to Nov 23, 2026
      AnalyticsPeriodHelper.setClockForTesting(() => DateTime(2026, 11, 23));
      final advancedWeeks = AnalyticsPeriodHelper.getExportWeeklyBuckets();
      expect(advancedWeeks.last.label, 'Nov 23 – Nov 29, 2026');
      expect(advancedWeeks.any((w) => w.label == oldestWeek), isFalse);

      // Rolled over: should automatically select current week
      rollover = AnalyticsPeriodHelper.resolveExportPeriodRollover(
        periodType: 'Weekly',
        periodLabel: oldestWeek,
      );
      expect(rollover.periodLabel, 'Nov 23 – Nov 29, 2026');
      expect(rollover.startDate, DateTime(2026, 11, 23));
      expect(rollover.endDate, DateTime(2026, 11, 29, 23, 59, 59));

      // Step C: Month rollover
      AnalyticsPeriodHelper.setClockForTesting(() => DateTime(2026, 11, 1));
      var monthRollover = AnalyticsPeriodHelper.resolveExportPeriodRollover(
        periodType: 'Monthly',
        periodLabel: 'May 2026', // older than 6 months
      );
      expect(
        monthRollover.periodLabel,
        'November 2026',
      ); // auto-select current month
    });

    // 6. Current period selected by default
    test(
      '6. Current period selected by default when switching period type',
      () {
        AnalyticsPeriodHelper.setClockForTesting(() => DateTime(2026, 11, 20));

        final weekly = AnalyticsPeriodHelper.resolveExportPeriodRollover(
          periodType: 'Weekly',
          periodLabel: null,
        );
        expect(weekly.periodLabel, 'Nov 16 – Nov 22, 2026');

        final monthly = AnalyticsPeriodHelper.resolveExportPeriodRollover(
          periodType: 'Monthly',
          periodLabel: null,
        );
        expect(monthly.periodLabel, 'November 2026');

        final yearly = AnalyticsPeriodHelper.resolveExportPeriodRollover(
          periodType: 'Yearly',
          periodLabel: null,
        );
        expect(yearly.periodLabel, '2026');
      },
    );

    // 7. Custom date-range saving and restoration in SQLite v4
    test('7. Custom date-range saving and restoration in SQLite v4', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'finpulse_export_test_',
      );
      final testDbPath = p.join(tempDir.path, 'export_test.db');
      final db = AnalyticsCustomizationDb(
        databasePath: testDbPath,
        databaseFactory: databaseFactoryFfi,
      );
      final repo = ReportExportRepository(storage: db);
      await repo.init();

      final customStart = DateTime.utc(2026, 7, 1);
      final customEnd = DateTime.utc(2026, 10, 31);

      await repo.savePreferences(
        ReportExportPreferences(
          reportFormat: 'Excel (.XLSX)',
          periodLabel: 'Custom Range',
          accountScope: 'Commercial Bank',
          selectedRequirements: const ['trans_history', 'exp_analysis'],
          startDate: customStart,
          endDate: customEnd,
        ),
      );

      await repo.close();

      // Reopen repository
      final reopenedDb = AnalyticsCustomizationDb(
        databasePath: testDbPath,
        databaseFactory: databaseFactoryFfi,
      );
      final reopenedRepo = ReportExportRepository(storage: reopenedDb);
      final loaded = await reopenedRepo.init();

      expect(loaded.reportFormat, 'Excel (.XLSX)');
      expect(loaded.periodLabel, 'Custom Range');
      expect(loaded.accountScope, 'Commercial Bank');
      expect(loaded.startDate, customStart);
      expect(loaded.endDate, customEnd);
      expect(loaded.selectedRequirements, ['trans_history', 'exp_analysis']);

      await reopenedRepo.close();
      await reopenedDb.deleteDatabaseFile();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    // 8. Supported periods list contains exactly four options
    test('8. Supported periods list contains exactly four options', () {
      expect(ReportExportPreferences.supportedPeriods, [
        'Weekly',
        'Monthly',
        'Yearly',
        'Custom',
      ]);
      expect(
        ReportExportPreferences.supportedPeriods.contains('October 2026'),
        isFalse,
      );
      expect(
        ReportExportPreferences.supportedPeriods.contains('Last 12 Months'),
        isFalse,
      );
    });

    // 9. UI renders 4 compact period tabs and allows switching
    testWidgets(
      '9. ReportExportScreen renders redesigned 4-way period tabs and switches types',
      (tester) async {
        AnalyticsPeriodHelper.setClockForTesting(() => DateTime(2026, 11, 20));

        final memRepo = ReportExportRepository(
          storage: _FakeReportExportStorage(),
        );
        await memRepo.init();

        await tester.pumpWidget(
          createTestWidget(
            const ReportExportScreen(),
            overrides: [
              reportExportRepositoryProvider.overrideWithValue(memRepo),
            ],
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // 4 options are rendered
        expect(find.text('Weekly'), findsOneWidget);
        expect(find.text('Monthly'), findsOneWidget);
        expect(find.text('Yearly'), findsOneWidget);
        expect(find.text('Custom'), findsOneWidget);

        // Required labels are preserved
        expect(find.text('Time Period'), findsOneWidget);
        expect(find.text('Accounts'), findsOneWidget);
        expect(find.text('PDF Report'), findsOneWidget);
        expect(find.text('Generate & Download Report'), findsOneWidget);

        // Tap Weekly tab
        await tester.tap(find.text('Weekly'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Verify weekly calendar week card is shown
        expect(find.text('CALENDAR WEEK (MONDAY – SUNDAY)'), findsOneWidget);
        expect(find.text('Nov 16 – Nov 22, 2026'), findsOneWidget);

        // Tap Yearly tab
        await tester.tap(find.text('Yearly'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('CALENDAR YEAR'), findsOneWidget);
        expect(find.text('2026'), findsOneWidget);
      },
    );
  });
}

class _FakeReportExportStorage implements AnalyticsCustomizationStorage {
  ReportExportPreferences? _prefs;

  @override
  bool get isOpen => true;

  @override
  Future<void> init() async {}

  @override
  Future<ReportExportPreferences?> getReportExportPreferences({
    String profileKey = ReportExportPreferences.defaultProfileKey,
  }) async => _prefs;

  @override
  Future<void> saveReportExportPreferencesAtomically(
    ReportExportPreferences preferences, {
    DateTime? timestamp,
    Future<void> Function(dynamic txn)? beforeCommitHook,
  }) async {
    _prefs = preferences;
  }

  @override
  Future<void> close() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
