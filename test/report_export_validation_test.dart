import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prot/core/services/app_preferences_service.dart';
import 'package:prot/features/analytics/data/analytics_customization_repository.dart';
import 'package:prot/features/analytics/data/analytics_customization_storage.dart';
import 'package:prot/features/analytics/data/report_export_repository.dart';
import 'package:prot/features/analytics/models/analytics_customization_preferences.dart';
import 'package:prot/features/analytics/models/dashboard_layout_preferences.dart';
import 'package:prot/features/analytics/models/report_export_preferences.dart';
import 'package:prot/features/analytics/presentation/screens/report_export_screen.dart';
import 'package:prot/features/analytics/presentation/screens/select_export_requirement_screen.dart';
import 'package:prot/features/analytics/providers/analytics_provider.dart';
import 'package:prot/features/analytics/services/export_requirements_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _InMemoryStorage implements AnalyticsCustomizationStorage {
  bool _open = false;
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
  late ReportExportRepository exportRepository;
  late AnalyticsCustomizationRepository customizationRepository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPreferencesService.init();

    storage = _InMemoryStorage();
    customizationRepository = AnalyticsCustomizationRepository(db: storage);
    await customizationRepository.init();

    exportRepository = ReportExportRepository(storage: storage);
    await exportRepository.init();
  });

  tearDown(() async {
    await exportRepository.close();
    await customizationRepository.close();
  });

  ProviderContainer createContainer({
    ReportExportPreferences? initialExportPrefs,
  }) {
    if (initialExportPrefs != null) {
      storage.saveReportExportPreferencesAtomically(initialExportPrefs);
      exportRepository.init();
    }
    return ProviderContainer(
      overrides: [
        analyticsCustomizationRepositoryProvider.overrideWithValue(
          customizationRepository,
        ),
        reportExportRepositoryProvider.overrideWithValue(exportRepository),
      ],
    );
  }

  Widget buildTestApp(
    Widget screen, {
    ProviderContainer? container,
    Size size = const Size(1200, 1800),
  }) {
    return MediaQuery(
      data: MediaQueryData(size: size),
      child: UncontrolledProviderScope(
        container: container ?? createContainer(),
        child: MaterialApp(home: Scaffold(body: screen)),
      ),
    );
  }

  group('Export Requirements Validation Tests (1 to 12)', () {
    // 1. One selected requirement passes validation
    test('1. One selected requirement passes validation', () {
      const singleSelection = ['trans_history'];
      expect(
        ExportRequirementsValidator.hasValidRequirements(singleSelection),
        isTrue,
      );
      expect(
        ExportRequirementsValidator.countValidRequirements(singleSelection),
        1,
      );
      expect(ExportRequirementsValidator.validate(singleSelection), isNull);
    });

    // 2. Multiple selected requirements pass validation
    test('2. Multiple selected requirements pass validation', () {
      const multipleSelection = [
        'trans_history',
        'inc_analysis',
        'exp_analysis',
      ];
      expect(
        ExportRequirementsValidator.hasValidRequirements(multipleSelection),
        isTrue,
      );
      expect(
        ExportRequirementsValidator.countValidRequirements(multipleSelection),
        3,
      );
      expect(ExportRequirementsValidator.validate(multipleSelection), isNull);
    });

    // 3. All seven selected requirements pass validation
    test('3. All seven selected requirements pass validation', () {
      final allSeven = ReportExportPreferences.allRequirementIds;
      expect(allSeven.length, 7);
      expect(
        ExportRequirementsValidator.hasValidRequirements(allSeven),
        isTrue,
      );
      expect(ExportRequirementsValidator.countValidRequirements(allSeven), 7);
      expect(ExportRequirementsValidator.validate(allSeven), isNull);
    });

    // 4. Empty selection fails validation
    test('4. Empty selection fails validation with exact error message', () {
      const emptyList = <String>[];
      expect(
        ExportRequirementsValidator.hasValidRequirements(emptyList),
        isFalse,
      );
      expect(ExportRequirementsValidator.countValidRequirements(emptyList), 0);
      expect(
        ExportRequirementsValidator.validate(emptyList),
        'Please select at least one report section before generating your report.',
      );

      // Null handling
      expect(ExportRequirementsValidator.hasValidRequirements(null), isFalse);
      expect(
        ExportRequirementsValidator.validate(null),
        'Please select at least one report section before generating your report.',
      );
    });

    // 5. Unknown requirement IDs do not count as valid selections
    test('5. Unknown requirement IDs do not count as valid selections', () {
      const unknownIds = ['unknown_module_123', 'fake_section', 'invalid_req'];
      expect(
        ExportRequirementsValidator.hasValidRequirements(unknownIds),
        isFalse,
      );
      expect(ExportRequirementsValidator.countValidRequirements(unknownIds), 0);
      expect(
        ExportRequirementsValidator.validate(unknownIds),
        'Please select at least one report section before generating your report.',
      );

      // Mixed selection with 1 valid and 2 unknown
      const mixedIds = ['invalid_req', 'goal_savings', 'fake_module'];
      expect(
        ExportRequirementsValidator.hasValidRequirements(mixedIds),
        isTrue,
      );
      expect(ExportRequirementsValidator.countValidRequirements(mixedIds), 1);
      expect(ExportRequirementsValidator.validate(mixedIds), isNull);
    });

    // 6. Select All passes validation
    testWidgets('6. Select All passes validation in Riverpod state and UI', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = createContainer();
      final allModuleIds = SelectExportRequirementScreen.allModules
          .map((m) => m.id)
          .toList();

      await container
          .read(exportPreferencesProvider.notifier)
          .selectAll(allModuleIds);

      final state = container.read(exportPreferencesProvider);
      expect(state.selectedRequirements.length, 7);
      expect(state.hasValidRequirements, isTrue);
      expect(
        ExportRequirementsValidator.hasValidRequirements(
          state.selectedRequirements,
        ),
        isTrue,
      );
    });

    // 7. Deselect All fails validation when generation is attempted
    testWidgets(
      '7. Deselect All fails validation when report generation is attempted',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final container = createContainer();
        final allModuleIds = SelectExportRequirementScreen.allModules
            .map((m) => m.id)
            .toList();

        // 1. Select All to ensure all 7 are selected
        await container
            .read(exportPreferencesProvider.notifier)
            .selectAll(allModuleIds);
        expect(
          container.read(exportPreferencesProvider).selectedRequirements.length,
          7,
        );

        // 2. Deselect All (calls selectAll again when all 7 are selected)
        await container
            .read(exportPreferencesProvider.notifier)
            .selectAll(allModuleIds);
        expect(
          container.read(exportPreferencesProvider).selectedRequirements,
          isEmpty,
        );

        // 3. Render ReportExportScreen with empty selection
        await tester.pumpWidget(
          buildTestApp(const ReportExportScreen(), container: container),
        );
        await tester.pumpAndSettle();

        // 4. Attempt to press Generate & Download Report
        await tester.tap(find.text('Generate & Download Report'));
        await tester.pumpAndSettle();

        // 5. Must display validation error SnackBar
        expect(
          find.text(
            'Please select at least one report section before generating your report.',
          ),
          findsOneWidget,
        );
        expect(find.text('Select Sections'), findsOneWidget);

        // 6. Must NOT display the success "Report Ready" dialog
        expect(find.text('Report Ready'), findsNothing);
      },
    );

    // 8. Empty selection remains persisted after simulated application restart
    test('8. Empty selection remains persisted after simulated application restart', () async {
      // Save empty selection
      final emptyPrefs = ReportExportPreferences(
        reportFormat: 'PDF Report',
        periodLabel: 'Monthly',
        accountScope: 'BOC',
        selectedRequirements: const <String>[],
      );
      await exportRepository.savePreferences(emptyPrefs);

      expect(exportRepository.currentPreferences.selectedRequirements, isEmpty);

      // Simulate application restart by creating a new repository on the same storage
      final freshRepository = ReportExportRepository(storage: storage);
      await freshRepository.init();

      expect(freshRepository.currentPreferences.selectedRequirements, isEmpty);
      expect(freshRepository.currentPreferences.hasValidRequirements, isFalse);
    });

    // 9. Generate & Download Report is blocked when no valid requirements are selected
    testWidgets(
      '9. Generate & Download Report is blocked and provides navigation action',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final emptyPrefs = ReportExportPreferences(
          reportFormat: 'Excel (.XLSX)',
          periodLabel: 'Weekly',
          accountScope: 'Cash Wallet',
          selectedRequirements: const <String>[],
        );
        await exportRepository.savePreferences(emptyPrefs);

        final container = createContainer();

        await tester.pumpWidget(
          buildTestApp(const ReportExportScreen(), container: container),
        );
        await tester.pumpAndSettle();

        // Tap Generate & Download Report
        await tester.tap(find.text('Generate & Download Report'));
        await tester.pumpAndSettle();

        // SnackBar error displayed
        expect(
          find.text(
            'Please select at least one report section before generating your report.',
          ),
          findsOneWidget,
        );

        // Tap "Select Sections" action in SnackBar
        await tester.tap(find.text('Select Sections'));
        await tester.pumpAndSettle();

        // Navigates to SelectExportRequirementScreen
        expect(find.byType(SelectExportRequirementScreen), findsOneWidget);
        expect(find.text('0 of 7 modules selected'), findsOneWidget);
      },
    );

    // 10. Share to WhatsApp is blocked when no valid requirements are selected
    testWidgets(
      '10. Share to WhatsApp is blocked when no valid requirements are selected',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final emptyPrefs = ReportExportPreferences(
          reportFormat: 'Raw Data',
          periodLabel: 'Yearly',
          accountScope: 'Commercial Bank',
          selectedRequirements: const <String>[],
        );
        await exportRepository.savePreferences(emptyPrefs);

        final container = createContainer();

        await tester.pumpWidget(
          buildTestApp(const ReportExportScreen(), container: container),
        );
        await tester.pumpAndSettle();

        // Tap Share to WhatsApp
        await tester.tap(find.text('Share to WhatsApp'));
        await tester.pumpAndSettle();

        // SnackBar error displayed
        expect(
          find.text(
            'Please select at least one report section before generating your report.',
          ),
          findsOneWidget,
        );

        // Does NOT show the WhatsApp sharing dialog
        expect(
          find.text('Ready to send generated summary report via WhatsApp.'),
          findsNothing,
        );
      },
    );

    // 11. Selecting a requirement again allows the action to continue
    testWidgets(
      '11. Selecting a requirement allows Generate & Download Report to proceed',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final emptyPrefs = ReportExportPreferences(
          reportFormat: 'PDF Report',
          periodLabel: 'Monthly',
          accountScope: 'BOC',
          selectedRequirements: const <String>[],
        );
        await exportRepository.savePreferences(emptyPrefs);

        final container = createContainer();

        await tester.pumpWidget(
          buildTestApp(const ReportExportScreen(), container: container),
        );
        await tester.pumpAndSettle();

        // Blocked initially
        await tester.tap(find.text('Generate & Download Report'));
        await tester.pumpAndSettle();
        expect(find.text('Report Ready'), findsNothing);

        // Select a requirement via notifier
        await container
            .read(exportPreferencesProvider.notifier)
            .toggleRequirement('inc_analysis');
        await tester.pumpAndSettle();

        // Now Generate & Download Report proceeds
        await tester.tap(find.text('Generate & Download Report'));
        await tester.pump(); // Start generation timer
        await tester.pump(const Duration(milliseconds: 1500)); // Complete delay
        await tester.pumpAndSettle();

        // "Report Ready" dialog successfully displayed
        expect(find.text('Report Ready'), findsOneWidget);
        expect(find.text('1 analytics modules'), findsOneWidget);
      },
    );

    // 12. Existing export settings and persistence remain unchanged
    test(
      '12. Existing export settings and persistence remain completely intact',
      () async {
        final customStart = DateTime.utc(2026, 5, 1);
        final customEnd = DateTime.utc(2026, 5, 31);
        final initialPrefs = ReportExportPreferences(
          reportFormat: 'Excel (.XLSX)',
          periodLabel: 'Custom Range',
          accountScope: 'Hatton National Bank',
          selectedRequirements: const ['trans_history', 'debt_invest'],
          startDate: customStart,
          endDate: customEnd,
        );
        await exportRepository.savePreferences(initialPrefs);

        final container = createContainer();
        final state = container.read(exportPreferencesProvider);

        // Verify all settings are preserved
        expect(state.format, 'Excel (.XLSX)');
        expect(state.period, 'Custom Range');
        expect(state.periodType, 'Custom');
        expect(state.account, 'Hatton National Bank');
        expect(state.startDate, customStart);
        expect(state.endDate, customEnd);
        expect(state.selectedRequirements, {'trans_history', 'debt_invest'});
        expect(state.hasValidRequirements, isTrue);

        // Toggle requirement and verify other fields remain unchanged
        await container
            .read(exportPreferencesProvider.notifier)
            .toggleRequirement('exp_analysis');

        final updatedState = container.read(exportPreferencesProvider);
        expect(updatedState.format, 'Excel (.XLSX)');
        expect(updatedState.period, 'Custom Range');
        expect(updatedState.account, 'Hatton National Bank');
        expect(updatedState.startDate, customStart);
        expect(updatedState.endDate, customEnd);
        expect(updatedState.selectedRequirements, {
          'trans_history',
          'debt_invest',
          'exp_analysis',
        });
      },
    );
  });
}
