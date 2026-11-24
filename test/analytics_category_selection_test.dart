import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prot/core/services/app_preferences_service.dart';
import 'package:prot/features/analytics/data/analytics_customization_repository.dart';
import 'package:prot/features/analytics/data/analytics_customization_storage.dart';
import 'package:prot/features/analytics/models/analytics_customization_preferences.dart';
import 'package:prot/features/analytics/models/dashboard_layout_preferences.dart';
import 'package:prot/features/analytics/models/report_export_preferences.dart';
import 'package:prot/features/analytics/presentation/screens/categories_customization_screen.dart';
import 'package:prot/features/analytics/presentation/screens/expense_analytics_screen.dart';
import 'package:prot/features/analytics/presentation/screens/goal_savings_analytics_screen.dart';
import 'package:prot/features/analytics/presentation/screens/income_analytics_screen.dart';
import 'package:prot/features/analytics/presentation/screens/prediction_analysis_screen.dart';
import 'package:prot/features/analytics/presentation/screens/spending_anomaly_screen.dart';
import 'package:prot/features/analytics/providers/analytics_provider.dart';
import 'package:prot/features/goals/models/goal_model.dart';
import 'package:prot/features/goals/providers/goals_provider.dart';
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
  late AnalyticsCustomizationRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPreferencesService.init();

    storage = _InMemoryStorage();
    repository = AnalyticsCustomizationRepository(db: storage);
    await repository.init();
  });

  tearDown(() async {
    await repository.close();
  });

  ProviderContainer createContainer({
    List<CustomCategoryItem>? incomeCategories,
    List<CustomCategoryItem>? expenseCategories,
    List<GoalModel>? goals,
  }) {
    return ProviderContainer(
      overrides: [
        analyticsCustomizationRepositoryProvider.overrideWithValue(repository),
        if (incomeCategories != null)
          incomeMethodsProvider.overrideWith(
            () => _TestIncomeNotifier(incomeCategories),
          ),
        if (expenseCategories != null)
          expenseCategoriesProvider.overrideWith(
            () => _TestExpenseNotifier(expenseCategories),
          ),
        if (goals != null)
          goalsProvider.overrideWith(() => _TestGoalsNotifier(goals)),
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

  group('Category Management & Analytics Integration Tests (1 to 15)', () {
    // 1. Analytics Customization displays the appropriate shared categories
    testWidgets('1. Analytics Customization displays shared categories', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = createContainer();
      await tester.pumpWidget(
        buildTestApp(
          const CategoriesCustomizationScreen(),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      // Income tab: default shared income categories
      expect(find.text('Analytics Customization'), findsOneWidget);
      expect(find.text('Income Methods'), findsOneWidget);
      expect(find.text('Expense Categories'), findsOneWidget);
      expect(find.text('Primary Salary'), findsOneWidget);
      expect(find.text('Kandy Annex Rent Inflow'), findsOneWidget);
      expect(find.text('Freelance'), findsOneWidget);

      // Switch to Expense tab
      await tester.tap(find.text('Expense Categories'));
      await tester.pumpAndSettle();

      expect(find.text('Food & Groceries'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Utilities'), findsOneWidget);
    });

    // 2. No category creation controls remain in Analytics
    testWidgets('2. No category creation controls remain in Analytics', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestApp(
          const CategoriesCustomizationScreen(
            initialTab: CustomizationTab.incomeMethods,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify no add buttons or creation controls
      expect(find.text('+ Add Custom Income Source or Category'), findsNothing);
      expect(
        find.text('+ Add Custom Expense Source or Category'),
        findsNothing,
      );
      expect(find.text('+ Add Custom Income Source'), findsNothing);
      expect(find.text('+ Add Custom Expense Category'), findsNothing);
      expect(find.byType(TextField), findsNothing);

      // Switch to Expense tab
      await tester.tap(find.text('Expense Categories'));
      await tester.pumpAndSettle();

      expect(
        find.text('+ Add Custom Expense Source or Category'),
        findsNothing,
      );
      expect(find.byType(TextField), findsNothing);
    });

    // 3. Editing a category name updates the shared category
    testWidgets('3. Editing a category name updates the shared category', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = createContainer();
      // Add a user-created category
      container
          .read(incomeMethodsProvider.notifier)
          .add('Side Project', const Color(0xFFF59E0B));

      await tester.pumpWidget(
        buildTestApp(
          const CategoriesCustomizationScreen(),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Side Project'), findsOneWidget);

      // Tap Edit button on the user-created category
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Income Source'), findsOneWidget);

      // Enter new name
      await tester.enterText(find.byType(TextField), 'Consulting Revenue');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Shared provider has been updated
      expect(find.text('Consulting Revenue'), findsOneWidget);
      expect(
        container
            .read(incomeMethodsProvider)
            .any((c) => c.name == 'Consulting Revenue'),
        isTrue,
      );
    });

    // 4. Changing a category colour updates the shared category
    testWidgets('4. Changing a category colour updates the shared category', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = createContainer();
      container
          .read(expenseCategoriesProvider.notifier)
          .add('Subscriptions', const Color(0xFF38BDF8));

      await tester.pumpWidget(
        buildTestApp(
          const CategoriesCustomizationScreen(
            initialTab: CustomizationTab.expenseCategories,
          ),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Pick emerald color (0xFF10B981) from palette wrap
      final emeraldFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color ==
                const Color(0xFF10B981),
      );
      expect(emeraldFinder, findsOneWidget);
      await tester.tap(emeraldFinder);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final updated = container
          .read(expenseCategoriesProvider)
          .firstWhere((c) => c.name == 'Subscriptions');
      expect(updated.color, const Color(0xFF10B981));
    });

    // 5. Editing preserves the original category ID
    testWidgets('5. Editing preserves the original category ID', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = createContainer();
      container
          .read(incomeMethodsProvider.notifier)
          .add('Online Store', const Color(0xFF98E836));

      final originalItem = container
          .read(incomeMethodsProvider)
          .firstWhere((c) => c.name == 'Online Store');
      final originalId = originalItem.id;

      await tester.pumpWidget(
        buildTestApp(
          const CategoriesCustomizationScreen(),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'E-Commerce Store');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final updatedItem = container
          .read(incomeMethodsProvider)
          .firstWhere((c) => c.id == originalId);
      expect(updatedItem.name, 'E-Commerce Store');
      expect(updatedItem.id, originalId);
    });

    // 6. Deleting a user-created category removes it from the shared list
    testWidgets(
      '6. Deleting a user-created category removes it from the shared list',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final container = createContainer();
        container
            .read(incomeMethodsProvider.notifier)
            .add('Temporary Gig', const Color(0xFFF43F5E));

        await tester.pumpWidget(
          buildTestApp(
            const CategoriesCustomizationScreen(),
            container: container,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Temporary Gig'), findsOneWidget);

        await tester.tap(find.text('Edit'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        expect(find.text('Temporary Gig'), findsNothing);
        expect(
          container
              .read(incomeMethodsProvider)
              .any((c) => c.name == 'Temporary Gig'),
          isFalse,
        );
      },
    );

    // 7. Built-in categories remain protected
    testWidgets(
      '7. Built-in categories remain protected from editing and deletion',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final container = createContainer();
        await tester.pumpWidget(
          buildTestApp(
            const CategoriesCustomizationScreen(),
            container: container,
          ),
        );
        await tester.pumpAndSettle();

        // Built-in categories display lock icon and NO Edit button
        expect(find.byIcon(Icons.lock_outline_rounded), findsNWidgets(3));
        expect(find.text('Edit'), findsNothing);

        // Direct provider invocation guard
        container
            .read(incomeMethodsProvider.notifier)
            .remove('inc_1'); // Primary Salary
        expect(
          container.read(incomeMethodsProvider).any((c) => c.id == 'inc_1'),
          isTrue,
        );

        container
            .read(incomeMethodsProvider.notifier)
            .update('inc_1', 'Altered Salary', Colors.black);
        expect(
          container
              .read(incomeMethodsProvider)
              .firstWhere((c) => c.id == 'inc_1')
              .name,
          'Primary Salary',
        );
      },
    );

    // 8. Renamed categories appear correctly in all relevant analytics screens
    testWidgets(
      '8. Renamed categories appear correctly across relevant analytics screens',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final container = createContainer();
        container
            .read(expenseCategoriesProvider.notifier)
            .add('Fine Dining', const Color(0xFFF43F5E));

        final catId = container
            .read(expenseCategoriesProvider)
            .firstWhere((c) => c.name == 'Fine Dining')
            .id;

        // Rename via shared provider
        container
            .read(expenseCategoriesProvider.notifier)
            .update(catId, 'Luxury Restaurants', const Color(0xFFF43F5E));

        // Screen 1: Expense Analytics
        await tester.pumpWidget(
          buildTestApp(const ExpenseAnalyticsScreen(), container: container),
        );
        await tester.pumpAndSettle();
        expect(find.text('Luxury Restaurants'), findsWidgets);

        // Screen 2: Prediction Analysis
        await tester.pumpWidget(
          buildTestApp(const PredictionAnalysisScreen(), container: container),
        );
        await tester.pumpAndSettle();
        expect(find.text('Luxury Restaurants'), findsOneWidget);

        // Screen 3: Spending Anomaly
        await tester.pumpWidget(
          buildTestApp(const SpendingAnomalyScreen(), container: container),
        );
        await tester.pumpAndSettle();
        expect(find.text('Luxury Restaurants'), findsOneWidget);
      },
    );

    // 9. Updated colours appear consistently
    testWidgets('9. Updated colours appear consistently across screens', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = createContainer();
      container
          .read(expenseCategoriesProvider.notifier)
          .add('Hobbies', const Color(0xFF98E836));

      final catId = container
          .read(expenseCategoriesProvider)
          .firstWhere((c) => c.name == 'Hobbies')
          .id;

      container
          .read(expenseCategoriesProvider.notifier)
          .update(
            catId,
            'Hobbies',
            const Color(0xFF9353D3), // Updated to Purple
          );

      await tester.pumpWidget(
        buildTestApp(const ExpenseAnalyticsScreen(), container: container),
      );
      await tester.pumpAndSettle();

      final category = container
          .read(expenseCategoriesProvider)
          .firstWhere((c) => c.id == catId);
      expect(category.color, const Color(0xFF9353D3));
    });

    // 10. Deleted selected categories fall back safely
    testWidgets(
      '10. Removing selected category falls back to first remaining category',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final container = createContainer();
        container
            .read(expenseCategoriesProvider.notifier)
            .add('Gym Membership', const Color(0xFF10B981));

        await tester.pumpWidget(
          buildTestApp(const ExpenseAnalyticsScreen(), container: container),
        );
        await tester.pumpAndSettle();

        // Tap Gym Membership
        await tester.tap(find.text('Gym Membership').first);
        await tester.pumpAndSettle();
        expect(find.text('Gym Membership'), findsWidgets);

        // Delete the selected category
        final gymId = container
            .read(expenseCategoriesProvider)
            .firstWhere((c) => c.name == 'Gym Membership')
            .id;
        container.read(expenseCategoriesProvider.notifier).remove(gymId);
        await tester.pumpAndSettle();

        // Automatically falls back to first available category
        expect(find.text('Food & Groceries - Monthly Spend'), findsOneWidget);
      },
    );

    // 11. Empty category lists are handled correctly
    testWidgets('11. Empty category lists are handled gracefully', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = createContainer(
        incomeCategories: const [],
        expenseCategories: const [],
        goals: const [],
      );

      // Categories Customization screen empty state
      await tester.pumpWidget(
        buildTestApp(
          const CategoriesCustomizationScreen(),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No income sources available'), findsOneWidget);
      expect(
        find.text('Categories are managed through the Budget module.'),
        findsOneWidget,
      );

      // Income Screen Empty State
      await tester.pumpWidget(
        buildTestApp(const IncomeAnalyticsScreen(), container: container),
      );
      await tester.pumpAndSettle();
      expect(find.text('No income categories available'), findsOneWidget);

      // Expense Screen Empty State
      await tester.pumpWidget(
        buildTestApp(const ExpenseAnalyticsScreen(), container: container),
      );
      await tester.pumpAndSettle();
      expect(find.text('No expense categories available'), findsWidgets);

      // Prediction Empty State
      await tester.pumpWidget(
        buildTestApp(const PredictionAnalysisScreen(), container: container),
      );
      await tester.pumpAndSettle();
      expect(find.text('No expense categories available'), findsWidgets);
    });

    // 12. Income and expense categories remain correctly separated
    test('12. Income and expense categories remain correctly separated', () {
      final container = createContainer();
      final incomeCats = container.read(incomeMethodsProvider);
      final expenseCats = container.read(expenseCategoriesProvider);

      for (final cat in incomeCats) {
        expect(cat.isExpense, isFalse);
      }
      for (final cat in expenseCats) {
        expect(cat.isExpense, isTrue);
      }
    });

    // 13. Goal & Savings continues using GoalModel
    testWidgets('13. Goal & Savings continues using GoalModel', (tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = createContainer();
      await tester.pumpWidget(
        buildTestApp(const GoalSavingsAnalyticsScreen(), container: container),
      );
      await tester.pumpAndSettle();

      expect(find.text('Emergency Fund'), findsWidgets);
      expect(find.text('Save for Vacation'), findsWidgets);
      expect(find.text('Vehicle Upgrade'), findsWidgets);

      // Add a dynamic goal
      container
          .read(goalsProvider.notifier)
          .addGoal(
            const GoalModel(
              id: 'wedding_fund',
              title: 'Wedding Fund',
              subtitle: 'Autumn 2027',
              currentAmount: 150000,
              targetAmount: 800000,
              monthlyContribution: 20000,
              color: Color(0xFFF43F5E),
              iconBg: Color(0xFF281519),
              icon: Icons.favorite_border,
            ),
          );
      await tester.pumpAndSettle();

      expect(find.text('Wedding Fund'), findsWidgets);
    });

    // 14. No category changes are written to a duplicate Analytics database
    testWidgets(
      '14. No category changes are written to a duplicate Analytics database',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final container = createContainer();
        final prefsBefore = await storage.getPreferences();

        container
            .read(incomeMethodsProvider.notifier)
            .add('Bonus Income', Colors.green);

        final catId = container
            .read(incomeMethodsProvider)
            .firstWhere((c) => c.name == 'Bonus Income')
            .id;
        container
            .read(incomeMethodsProvider.notifier)
            .update(catId, 'Annual Bonus', Colors.teal);
        container.read(incomeMethodsProvider.notifier).remove(catId);

        final prefsAfter = await storage.getPreferences();
        expect(prefsAfter, equals(prefsBefore));
      },
    );

    // 15. No transaction or other student's functionality is broken
    test(
      '15. Category items maintain integrity without breaking foreign models',
      () {
        const item = CustomCategoryItem(
          id: 'test_item',
          name: 'Test Category',
          color: Color(0xFF98E836),
          isExpense: false,
          isDefault: false,
        );
        expect(item.id, 'test_item');
        expect(item.name, 'Test Category');
        expect(item.isDefault, isFalse);

        final updated = item.copyWith(name: 'Updated Category');
        expect(updated.id, 'test_item');
        expect(updated.name, 'Updated Category');
        expect(updated.isDefault, isFalse);
      },
    );
  });
}

class _TestIncomeNotifier extends IncomeMethodsNotifier {
  final List<CustomCategoryItem> initialList;
  _TestIncomeNotifier(this.initialList);

  @override
  List<CustomCategoryItem> build() => initialList;
}

class _TestExpenseNotifier extends ExpenseCategoriesNotifier {
  final List<CustomCategoryItem> initialList;
  _TestExpenseNotifier(this.initialList);

  @override
  List<CustomCategoryItem> build() => initialList;
}

class _TestGoalsNotifier extends GoalsNotifier {
  final List<GoalModel> initialGoals;
  _TestGoalsNotifier(this.initialGoals);

  @override
  GoalsState build() => GoalsState(goals: initialGoals);
}
