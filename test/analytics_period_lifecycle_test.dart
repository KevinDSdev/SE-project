import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:prot/core/services/app_preferences_service.dart';
import 'package:prot/features/analytics/data/analytics_customization_db.dart';
import 'package:prot/features/analytics/data/analytics_customization_repository.dart';
import 'package:prot/features/analytics/models/analytics_customization_preferences.dart';
import 'package:prot/features/analytics/presentation/financial_analytics_screen.dart';
import 'package:prot/features/analytics/presentation/screens/expense_analytics_screen.dart';
import 'package:prot/features/analytics/presentation/screens/goal_savings_analytics_screen.dart';
import 'package:prot/features/analytics/presentation/screens/income_analytics_screen.dart';
import 'package:prot/features/analytics/providers/analytics_provider.dart';
import 'package:prot/features/auth/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Directory tempDir;
  late String testDbPath;
  late AnalyticsCustomizationDb db;
  late AnalyticsCustomizationRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPreferencesService.init();

    tempDir = await Directory.systemTemp.createTemp('finpulse_lifecycle_test_');
    testDbPath = p.join(tempDir.path, 'lifecycle_test.db');
    db = AnalyticsCustomizationDb(
      databasePath: testDbPath,
      databaseFactory: databaseFactoryFfi,
    );
    repository = AnalyticsCustomizationRepository(db: db);
    await repository.init();
  });

  tearDown(() async {
    await repository.close();
    await db.deleteDatabaseFile();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  ProviderContainer createContainer([
    AnalyticsCustomizationRepository? customRepo,
  ]) {
    return ProviderContainer(
      overrides: [
        analyticsCustomizationRepositoryProvider.overrideWithValue(
          customRepo ?? repository,
        ),
      ],
    );
  }

  group('FinPulse Saved Default & Independent Temporary Period Tests (1 to 15)', () {
    // 1. Monthly default when no saved preference exists
    test('1. Monthly default when no saved preference exists', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      expect(
        container.read(savedDefaultPeriodProvider),
        AnalyticsPeriod.monthly,
      );
      for (final screen in AnalyticsScreenType.values) {
        expect(
          container.read(analyticsScreenPeriodProvider(screen)),
          AnalyticsPeriod.monthly,
        );
      }
      expect(container.read(selectedPeriodProvider), AnalyticsPeriod.monthly);
    });

    // 2. Restoring a saved Weekly preference
    test('2. Restoring a saved Weekly preference', () async {
      await repository.saveAll(
        const AnalyticsCustomizationPreferences(
          defaultPeriod: AnalyticsPeriod.weekly,
        ),
      );

      final container = createContainer();
      addTearDown(container.dispose);

      expect(
        container.read(savedDefaultPeriodProvider),
        AnalyticsPeriod.weekly,
      );
      for (final screen in AnalyticsScreenType.values) {
        expect(
          container.read(analyticsScreenPeriodProvider(screen)),
          AnalyticsPeriod.weekly,
        );
      }
      expect(container.read(selectedPeriodProvider), AnalyticsPeriod.weekly);
    });

    // 3. Restoring a saved Monthly preference
    test('3. Restoring a saved Monthly preference', () async {
      await repository.saveAll(
        const AnalyticsCustomizationPreferences(
          defaultPeriod: AnalyticsPeriod.monthly,
        ),
      );

      final container = createContainer();
      addTearDown(container.dispose);

      expect(
        container.read(savedDefaultPeriodProvider),
        AnalyticsPeriod.monthly,
      );
      for (final screen in AnalyticsScreenType.values) {
        expect(
          container.read(analyticsScreenPeriodProvider(screen)),
          AnalyticsPeriod.monthly,
        );
      }
      expect(container.read(selectedPeriodProvider), AnalyticsPeriod.monthly);
    });

    // 4. Restoring a saved Yearly preference
    test('4. Restoring a saved Yearly preference', () async {
      await repository.saveAll(
        const AnalyticsCustomizationPreferences(
          defaultPeriod: AnalyticsPeriod.yearly,
        ),
      );

      final container = createContainer();
      addTearDown(container.dispose);

      expect(
        container.read(savedDefaultPeriodProvider),
        AnalyticsPeriod.yearly,
      );
      for (final screen in AnalyticsScreenType.values) {
        expect(
          container.read(analyticsScreenPeriodProvider(screen)),
          AnalyticsPeriod.yearly,
        );
      }
      expect(container.read(selectedPeriodProvider), AnalyticsPeriod.yearly);
    });

    // 5. Invalid saved preference fallback
    test('5. Invalid saved preference fallback', () {
      final fallback = AnalyticsCustomizationPreferences.parseAnalyticsPeriod(
        'unknown_period_value',
        AnalyticsPeriod.monthly,
      );
      expect(fallback, AnalyticsPeriod.monthly);

      final nullFallback =
          AnalyticsCustomizationPreferences.parseAnalyticsPeriod(
            null,
            AnalyticsPeriod.monthly,
          );
      expect(nullFallback, AnalyticsPeriod.monthly);

      final fromMapFallback = AnalyticsCustomizationPreferences.fromMap({
        'profile_key': 'default',
        'default_period': 'unsupported_period_str',
      });
      expect(fromMapFallback.defaultPeriod, AnalyticsPeriod.monthly);
    });

    // 6. Financial Analytics temporarily selects Weekly without changing the saved default
    test('6. Financial Analytics temporarily selects Weekly without changing the saved default', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      // Saved default starts as Monthly
      expect(
        container.read(savedDefaultPeriodProvider),
        AnalyticsPeriod.monthly,
      );

      // Temporarily select Weekly on Financial Analytics screen
      container
          .read(
            analyticsScreenPeriodProvider(AnalyticsScreenType.financial)
                .notifier,
          )
          .setPeriod(AnalyticsPeriod.weekly);

      // Financial Analytics is now Weekly
      expect(
        container.read(
          analyticsScreenPeriodProvider(AnalyticsScreenType.financial),
        ),
        AnalyticsPeriod.weekly,
      );
      expect(container.read(selectedPeriodProvider), AnalyticsPeriod.weekly);

      // Saved default provider and repository cache remain Monthly
      expect(
        container.read(savedDefaultPeriodProvider),
        AnalyticsPeriod.monthly,
      );
      expect(repository.defaultPeriod, AnalyticsPeriod.monthly);

      // Direct DB read verifies no SQLite write occurred
      final dbPrefs = await db.getPreferences();
      expect(dbPrefs?.defaultPeriod, AnalyticsPeriod.monthly);
    });

    // 7. Income Analytics can independently select Yearly
    test('7. Income Analytics can independently select Yearly', () {
      final container = createContainer();
      addTearDown(container.dispose);

      container
          .read(
            analyticsScreenPeriodProvider(AnalyticsScreenType.financial)
                .notifier,
          )
          .setPeriod(AnalyticsPeriod.weekly);
      container
          .read(
            analyticsScreenPeriodProvider(AnalyticsScreenType.income).notifier,
          )
          .setPeriod(AnalyticsPeriod.yearly);

      expect(
        container.read(
          analyticsScreenPeriodProvider(AnalyticsScreenType.financial),
        ),
        AnalyticsPeriod.weekly,
      );
      expect(
        container.read(
          analyticsScreenPeriodProvider(AnalyticsScreenType.income),
        ),
        AnalyticsPeriod.yearly,
      );
      expect(
        container.read(savedDefaultPeriodProvider),
        AnalyticsPeriod.monthly,
      );
    });

    // 8. Changing one screen does not affect another screen
    test('8. Changing one screen does not affect another screen', () {
      final container = createContainer();
      addTearDown(container.dispose);

      // Financial -> Weekly
      container
          .read(
            analyticsScreenPeriodProvider(AnalyticsScreenType.financial)
                .notifier,
          )
          .setPeriod(AnalyticsPeriod.weekly);
      // Income -> Yearly
      container
          .read(
            analyticsScreenPeriodProvider(AnalyticsScreenType.income).notifier,
          )
          .setPeriod(AnalyticsPeriod.yearly);
      // Goal & Savings -> Weekly
      container
          .read(
            analyticsScreenPeriodProvider(AnalyticsScreenType.goalSavings)
                .notifier,
          )
          .setPeriod(AnalyticsPeriod.weekly);

      // Verify each screen maintains its own independent selection
      expect(
        container.read(
          analyticsScreenPeriodProvider(AnalyticsScreenType.financial),
        ),
        AnalyticsPeriod.weekly,
      );
      expect(
        container.read(
          analyticsScreenPeriodProvider(AnalyticsScreenType.income),
        ),
        AnalyticsPeriod.yearly,
      );
      expect(
        container.read(
          analyticsScreenPeriodProvider(AnalyticsScreenType.expense),
        ),
        AnalyticsPeriod.monthly, // untouched default
      );
      expect(
        container.read(
          analyticsScreenPeriodProvider(AnalyticsScreenType.goalSavings),
        ),
        AnalyticsPeriod.weekly,
      );
      expect(
        container.read(
          analyticsScreenPeriodProvider(AnalyticsScreenType.spendingAnomaly),
        ),
        AnalyticsPeriod.monthly, // untouched default
      );
    });

    // 9. Temporary selections remain while navigating between screens during the same session
    test('9. Temporary selections remain while navigating between screens during the same session', () {
      final container = createContainer();
      addTearDown(container.dispose);

      // User navigates to Financial Analytics and picks Weekly
      container
          .read(
            analyticsScreenPeriodProvider(AnalyticsScreenType.financial)
                .notifier,
          )
          .setPeriod(AnalyticsPeriod.weekly);

      // User navigates away to Expense Analytics and checks period
      expect(
        container.read(
          analyticsScreenPeriodProvider(AnalyticsScreenType.expense),
        ),
        AnalyticsPeriod.monthly,
      );

      // User navigates to Spending Anomaly and selects Yearly
      container
          .read(
            analyticsScreenPeriodProvider(AnalyticsScreenType.spendingAnomaly)
                .notifier,
          )
          .setPeriod(AnalyticsPeriod.yearly);

      // User navigates back to Financial Analytics: Weekly is preserved
      expect(
        container.read(
          analyticsScreenPeriodProvider(AnalyticsScreenType.financial),
        ),
        AnalyticsPeriod.weekly,
      );

      // User navigates back to Spending Anomaly: Yearly is preserved
      expect(
        container.read(
          analyticsScreenPeriodProvider(AnalyticsScreenType.spendingAnomaly),
        ),
        AnalyticsPeriod.yearly,
      );
    });

    // 10. Simulated browser refresh resets all screens to the saved default
    test(
      '10. Simulated browser refresh resets all screens to the saved default',
      () {
        final container1 = createContainer();
        // User makes several temporary selections
        container1
            .read(
              analyticsScreenPeriodProvider(AnalyticsScreenType.financial)
                  .notifier,
            )
            .setPeriod(AnalyticsPeriod.weekly);
        container1
            .read(
              analyticsScreenPeriodProvider(AnalyticsScreenType.income)
                  .notifier,
            )
            .setPeriod(AnalyticsPeriod.yearly);
        container1
            .read(
              analyticsScreenPeriodProvider(AnalyticsScreenType.expense)
                  .notifier,
            )
            .setPeriod(AnalyticsPeriod.weekly);

        expect(
          container1.read(
            analyticsScreenPeriodProvider(AnalyticsScreenType.financial),
          ),
          AnalyticsPeriod.weekly,
        );

        // Simulated browser refresh: container is disposed and reconstructed
        container1.dispose();
        final container2 = createContainer();
        addTearDown(container2.dispose);

        // All screens reset to the saved default (monthly)
        for (final screen in AnalyticsScreenType.values) {
          expect(
            container2.read(analyticsScreenPeriodProvider(screen)),
            AnalyticsPeriod.monthly,
          );
        }
      },
    );

    // 11. Simulated application restart resets all screens to the saved default
    test('11. Simulated application restart resets all screens to the saved default', () async {
      final container1 = createContainer();
      container1
          .read(
            analyticsScreenPeriodProvider(AnalyticsScreenType.financial)
                .notifier,
          )
          .setPeriod(AnalyticsPeriod.weekly);
      container1
          .read(
            analyticsScreenPeriodProvider(AnalyticsScreenType.income).notifier,
          )
          .setPeriod(AnalyticsPeriod.yearly);
      container1.dispose();

      // Simulate full application process restart: close DB and reopen
      await repository.close();
      final reopenedDb = AnalyticsCustomizationDb(
        databasePath: testDbPath,
        databaseFactory: databaseFactoryFfi,
      );
      final reopenedRepo = AnalyticsCustomizationRepository(db: reopenedDb);
      await reopenedRepo.init();

      final container2 = createContainer(reopenedRepo);
      addTearDown(container2.dispose);
      addTearDown(reopenedRepo.close);

      for (final screen in AnalyticsScreenType.values) {
        expect(
          container2.read(analyticsScreenPeriodProvider(screen)),
          AnalyticsPeriod.monthly,
        );
      }
    });

    // 12. Logout clears all temporary selections without deleting the saved default
    test('12. Logout clears all temporary selections without deleting the saved default', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      // Simulate logged in user
      await container
          .read(authProvider.notifier)
          .login('user@finpulse.com', 'password123');

      // Set temporary overrides
      container
          .read(
            analyticsScreenPeriodProvider(AnalyticsScreenType.financial)
                .notifier,
          )
          .setPeriod(AnalyticsPeriod.weekly);
      container
          .read(
            analyticsScreenPeriodProvider(AnalyticsScreenType.income).notifier,
          )
          .setPeriod(AnalyticsPeriod.yearly);

      expect(
        container.read(
          analyticsScreenPeriodProvider(AnalyticsScreenType.financial),
        ),
        AnalyticsPeriod.weekly,
      );
      expect(
        container.read(
          analyticsScreenPeriodProvider(AnalyticsScreenType.income),
        ),
        AnalyticsPeriod.yearly,
      );

      // User logs out
      container.read(authProvider.notifier).logout();

      // Temporary selections are cleared; all screens return to saved default (monthly)
      for (final screen in AnalyticsScreenType.values) {
        expect(
          container.read(analyticsScreenPeriodProvider(screen)),
          AnalyticsPeriod.monthly,
        );
      }

      // Saved default in repository and SQLite was NOT deleted or overwritten
      expect(repository.defaultPeriod, AnalyticsPeriod.monthly);
      final dbPrefs = await db.getPreferences();
      expect(dbPrefs?.defaultPeriod, AnalyticsPeriod.monthly);
    });

    // 13. Login restores all screens from the saved default
    test('13. Login restores all screens from the saved default', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      // Perform login
      final success = await container
          .read(authProvider.notifier)
          .login('alex@finpulse.com', 'secret123');
      expect(success, isTrue);

      // All analytics screens initialize from saved default (monthly)
      for (final screen in AnalyticsScreenType.values) {
        expect(
          container.read(analyticsScreenPeriodProvider(screen)),
          AnalyticsPeriod.monthly,
        );
      }
    });

    // 14. Saving a new default period updates screens without temporary overrides
    test('14. Saving a new default period updates screens without temporary overrides', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      // Financial has temporary override (Weekly)
      container
          .read(
            analyticsScreenPeriodProvider(AnalyticsScreenType.financial)
                .notifier,
          )
          .setPeriod(AnalyticsPeriod.weekly);

      // Expense has no temporary override (currently Monthly default)
      expect(
        container.read(
          analyticsScreenPeriodProvider(AnalyticsScreenType.expense),
        ),
        AnalyticsPeriod.monthly,
      );

      // User changes Default Analytics Period to Yearly in Analytics Customization and saves
      await repository.saveAll(
        const AnalyticsCustomizationPreferences(
          defaultPeriod: AnalyticsPeriod.yearly,
        ),
      );
      container
          .read(savedDefaultPeriodProvider.notifier)
          .syncState(AnalyticsPeriod.yearly);

      // Screens without active overrides (Expense, Income, etc.) immediately reflect the new saved default
      expect(
        container.read(
          analyticsScreenPeriodProvider(AnalyticsScreenType.expense),
        ),
        AnalyticsPeriod.yearly,
      );
      expect(
        container.read(
          analyticsScreenPeriodProvider(AnalyticsScreenType.income),
        ),
        AnalyticsPeriod.yearly,
      );

      // Financial Analytics preserves its active in-session temporary selection (Weekly)
      expect(
        container.read(
          analyticsScreenPeriodProvider(AnalyticsScreenType.financial),
        ),
        AnalyticsPeriod.weekly,
      );

      // After session reset (e.g. refresh), ALL screens use the newly saved default (Yearly)
      container.read(temporaryPeriodOverridesProvider.notifier).clearAll();
      for (final screen in AnalyticsScreenType.values) {
        expect(
          container.read(analyticsScreenPeriodProvider(screen)),
          AnalyticsPeriod.yearly,
        );
      }
    });

    // 15. Temporary period selections never write to persistent storage
    test(
      '15. Temporary period selections never write to persistent storage',
      () async {
        final container = createContainer();
        addTearDown(container.dispose);

        // Initial saved default is Monthly
        final initialDbPrefs = await db.getPreferences();
        expect(initialDbPrefs?.defaultPeriod, AnalyticsPeriod.monthly);

        // Mutate temporary selections across all screens
        container
            .read(
              analyticsScreenPeriodProvider(AnalyticsScreenType.financial)
                  .notifier,
            )
            .setPeriod(AnalyticsPeriod.weekly);
        container
            .read(
              analyticsScreenPeriodProvider(AnalyticsScreenType.income)
                  .notifier,
            )
            .setPeriod(AnalyticsPeriod.yearly);
        container
            .read(
              analyticsScreenPeriodProvider(AnalyticsScreenType.expense)
                  .notifier,
            )
            .setPeriod(AnalyticsPeriod.weekly);
        container
            .read(
              analyticsScreenPeriodProvider(AnalyticsScreenType.goalSavings)
                  .notifier,
            )
            .setPeriod(AnalyticsPeriod.yearly);
        container
            .read(
              analyticsScreenPeriodProvider(AnalyticsScreenType.spendingAnomaly)
                  .notifier,
            )
            .setPeriod(AnalyticsPeriod.weekly);

        // Verify SQLite was NEVER written to
        final afterDbPrefs = await db.getPreferences();
        expect(afterDbPrefs?.defaultPeriod, AnalyticsPeriod.monthly);
        expect(repository.defaultPeriod, AnalyticsPeriod.monthly);
      },
    );
  });
}
