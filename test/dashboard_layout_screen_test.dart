import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prot/core/services/app_preferences_service.dart';
import 'package:prot/features/analytics/data/analytics_customization_storage.dart';
import 'package:prot/features/analytics/data/dashboard_layout_repository.dart';
import 'package:prot/features/analytics/models/analytics_customization_preferences.dart';
import 'package:prot/features/analytics/models/dashboard_layout_preferences.dart';
import 'package:prot/features/analytics/models/report_export_preferences.dart';
import 'package:prot/features/analytics/presentation/screens/dashboard_widgets_screen.dart';
import 'package:prot/features/analytics/providers/analytics_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _InMemoryStorage implements AnalyticsCustomizationStorage {
  bool _open = false;
  bool shouldFailSave = false;
  final Map<String, AnalyticsCustomizationPreferences> _analytics = {};
  final Map<String, DashboardLayoutPreferences> _layouts = {};
  final Map<String, ReportExportPreferences> _reportExports = {};

  @override
  bool get isOpen => _open;

  @override
  Future<void> init() async {
    _open = true;
  }

  @override
  Future<AnalyticsCustomizationPreferences?> getPreferences({
    String profileKey = AnalyticsCustomizationPreferences.defaultProfileKey,
  }) async {
    return _analytics[profileKey];
  }

  @override
  Future<void> savePreferencesAtomically(
    AnalyticsCustomizationPreferences preferences, {
    DateTime? timestamp,
    Future<void> Function(dynamic txn)? beforeCommitHook,
  }) async {
    if (shouldFailSave) {
      throw StateError('Simulated storage write failure');
    }
    if (beforeCommitHook != null) {
      await beforeCommitHook(null);
    }
    _analytics[preferences.profileKey] = preferences;
  }

  @override
  Future<DashboardLayoutPreferences?> getDashboardLayout({
    String profileKey = DashboardLayoutPreferences.defaultProfileKey,
  }) async {
    return _layouts[profileKey];
  }

  @override
  Future<void> saveDashboardLayoutAtomically(
    DashboardLayoutPreferences preferences, {
    DateTime? timestamp,
    Future<void> Function(dynamic txn)? beforeCommitHook,
  }) async {
    if (shouldFailSave) {
      throw StateError('Simulated storage write failure');
    }
    if (beforeCommitHook != null) {
      await beforeCommitHook(null);
    }
    _layouts[preferences.profileKey] = preferences;
  }

  @override
  Future<ReportExportPreferences?> getReportExportPreferences({
    String profileKey = ReportExportPreferences.defaultProfileKey,
  }) async {
    return _reportExports[profileKey];
  }

  @override
  Future<void> saveReportExportPreferencesAtomically(
    ReportExportPreferences preferences, {
    DateTime? timestamp,
    Future<void> Function(dynamic txn)? beforeCommitHook,
  }) async {
    if (shouldFailSave) {
      throw StateError('Simulated storage write failure');
    }
    if (beforeCommitHook != null) {
      await beforeCommitHook(null);
    }
    _reportExports[preferences.profileKey] = preferences;
  }

  @override
  Future<void> close() async {
    _open = false;
  }
}

void main() {
  late _InMemoryStorage storage;
  late DashboardLayoutRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPreferencesService.init();
    storage = _InMemoryStorage();
    repository = DashboardLayoutRepository(storage: storage);
    await repository.init();
  });

  tearDown(() async {
    await repository.close();
  });

  Widget buildApp(ProviderContainer container, {bool wrapWithLauncher = true}) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: wrapWithLauncher
            ? Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const DashboardWidgetsScreen(),
                          ),
                        );
                      },
                      child: const Text('Open Layout'),
                    ),
                  ),
                ),
              )
            : const DashboardWidgetsScreen(),
      ),
    );
  }

  Future<void> openScreen(WidgetTester tester) async {
    await tester.tap(find.text('Open Layout'));
    await tester.pumpAndSettle();
  }

  Future<void> tapButton(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  group('DashboardWidgetsScreen & dashboardWidgetsProvider', () {
    testWidgets(
      'Save Preferences persists, updates provider state, and pops screen',
      (WidgetTester tester) async {
        final container = ProviderContainer(
          overrides: [
            dashboardLayoutRepositoryProvider.overrideWithValue(repository),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(buildApp(container));
        await openScreen(tester);

        // Remove active_income and add Income Analytics.
        await tapButton(
          tester,
          find.byKey(const ValueKey('remove_card_active_income')),
        );
        await tapButton(tester, find.text('+ Add').first);
        await tapButton(tester, find.text('Save Preferences'));

        // Screen popped back to launcher.
        expect(find.text('Open Layout'), findsOneWidget);
        expect(find.text('Preferences saved successfully.'), findsOneWidget);

        // Provider and repository both updated.
        final expectedActive = <String>[
          'active_expenses',
          'active_savings',
          'active_trend',
          'avail_inc_analytics',
        ];
        expect(
          container
              .read(dashboardWidgetsProvider)
              .activeWidgets
              .map((c) => c.id)
              .toList(),
          equals(expectedActive),
        );
        expect(repository.activeCardIds, equals(expectedActive));
      },
    );

    testWidgets(
      'Save failure shows error SnackBar, does not update provider state, and stays on screen',
      (WidgetTester tester) async {
        final container = ProviderContainer(
          overrides: [
            dashboardLayoutRepositoryProvider.overrideWithValue(repository),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(buildApp(container));
        await openScreen(tester);

        // Remove active_expenses in draft, then force storage failure.
        await tapButton(
          tester,
          find.byKey(const ValueKey('remove_card_active_expenses')),
        );
        storage.shouldFailSave = true;

        await tapButton(tester, find.text('Save Preferences'));

        // Still on Dashboard Layout screen with error feedback.
        expect(find.text('Dashboard Layout'), findsOneWidget);
        expect(
          find.text('Failed to save dashboard layout. Please try again.'),
          findsOneWidget,
        );

        // Provider and repository still hold original default active cards.
        expect(
          container
              .read(dashboardWidgetsProvider)
              .activeWidgets
              .map((c) => c.id)
              .toList(),
          equals(DashboardLayoutPreferences.defaultActiveCardIds),
        );
        expect(
          repository.activeCardIds,
          equals(DashboardLayoutPreferences.defaultActiveCardIds),
        );
      },
    );

    testWidgets('Reset only changes draft until Save Preferences is pressed', (
      WidgetTester tester,
    ) async {
      await repository.saveActiveCardIds(const <String>['active_income']);

      final container = ProviderContainer(
        overrides: [
          dashboardLayoutRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildApp(container));
      await openScreen(tester);

      // Tap Reset: draft resets to defaults, but provider & repository remain unchanged.
      await tapButton(tester, find.text('Reset'));

      expect(
        container
            .read(dashboardWidgetsProvider)
            .activeWidgets
            .map((c) => c.id)
            .toList(),
        equals(<String>['active_income']),
      );
      expect(repository.activeCardIds, equals(<String>['active_income']));

      // Let the floating Reset SnackBar dismiss so it does not cover Save Preferences.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Now tap Save Preferences to apply and persist the reset.
      await tapButton(tester, find.text('Save Preferences'));

      expect(
        container
            .read(dashboardWidgetsProvider)
            .activeWidgets
            .map((c) => c.id)
            .toList(),
        equals(DashboardLayoutPreferences.defaultActiveCardIds),
      );
      expect(
        repository.activeCardIds,
        equals(DashboardLayoutPreferences.defaultActiveCardIds),
      );
    });

    testWidgets('active_trend card can be removed and persisted', (
      WidgetTester tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          dashboardLayoutRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildApp(container));
      await openScreen(tester);

      final trendRemoveButton = find.byKey(
        const ValueKey('remove_card_active_trend'),
      );
      expect(trendRemoveButton, findsOneWidget);

      await tapButton(tester, trendRemoveButton);
      await tapButton(tester, find.text('Save Preferences'));

      final activeIds = container
          .read(dashboardWidgetsProvider)
          .activeWidgets
          .map((c) => c.id)
          .toList();
      expect(activeIds, isNot(contains('active_trend')));
      expect(repository.activeCardIds, isNot(contains('active_trend')));

      final availableIds = container
          .read(dashboardWidgetsProvider)
          .availableWidgets
          .map((c) => c.id)
          .toList();
      expect(availableIds, contains('active_trend'));
    });

    testWidgets(
      'Available Cards are derived correctly and empty available copy avoids the word widget',
      (WidgetTester tester) async {
        await repository.saveActiveCardIds(
          DashboardLayoutPreferences.allKnownCardIds,
        );

        final container = ProviderContainer(
          overrides: [
            dashboardLayoutRepositoryProvider.overrideWithValue(repository),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(buildApp(container, wrapWithLauncher: false));
        await tester.pumpAndSettle();

        expect(
          container.read(dashboardWidgetsProvider).availableWidgets,
          isEmpty,
        );
        expect(
          find.text('All Analytics Dashboard Cards are currently active'),
          findsOneWidget,
        );
      },
    );
  });
}
