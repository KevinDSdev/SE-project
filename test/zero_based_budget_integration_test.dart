import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prot/core/theme/app_theme.dart';
import 'package:prot/features/budget/models/budget_category_model.dart';
import 'package:prot/features/budget/models/budget_status.dart';
import 'package:prot/features/budget/presentation/budget_progress_screen.dart';
import 'package:prot/features/budget/presentation/budget_setup_screen.dart';
import 'package:prot/features/budget/providers/budget_provider.dart';

void main() {
  Widget createWidgetUnderTest(Widget child, [List<dynamic> overrides = const []]) {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: child,
      ),
    );
  }

  group('Phase 4: BudgetProvider Reactive State Integration', () {
    test('Initial baseline state initializes with correct calculations', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(budgetProvider);
      expect(state.monthlyIncome, equals(450000.0));
      expect(state.baselineSavings, equals(25000.0));
      expect(state.variableCategories.length, equals(3));
      expect(state.fixedBills.length, equals(3));

      // Calculations:
      // Variable: 65k + 35k + 30k = 130k
      // Fixed: 120k + 45k + 25k = 190k
      // Savings: 25k
      // Total Allocated: 345,000
      // Total Spent: 42,000 (Food 20k + Dining 12k + Travel 10k)
      // Total Available: 345,000 - 42,000 = 303,000
      // Unallocated: 105,000
      expect(state.calculation.totalVariableAllocated, equals(130000.0));
      expect(state.calculation.totalFixedAllocated, equals(190000.0));
      expect(state.calculation.totalSavingsAllocated, equals(25000.0));
      expect(state.calculation.totalAllocated, equals(345000.0));
      expect(state.calculation.totalSpent, equals(42000.0));
      expect(state.calculation.totalAvailable, equals(303000.0));
      expect(state.calculation.unallocatedAmount, equals(105000.0));
      expect(state.calculation.status, equals(BudgetStatus.underallocated));
      expect(state.calculation.status.displayName, equals('UNDERALLOCATED'));
    });

    test('addCategory updates allocations and achieves BALANCED status', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final newCat = BudgetCategoryModel(
        id: 'education',
        name: 'Education',
        group: 'Needs',
        icon: Icons.school,
        color: Colors.green,
        assignedAmount: 105000,
        spentAmount: 0,
      );

      container.read(budgetProvider.notifier).addCategory(newCat);

      final state = container.read(budgetProvider);
      expect(state.variableCategories.length, equals(4));
      expect(state.calculation.totalAllocated, equals(450000.0));
      expect(state.calculation.unallocatedAmount, equals(0.0));
      expect(state.calculation.status, equals(BudgetStatus.balanced));
      expect(state.calculation.status.displayName, equals('BALANCED'));
    });

    test('updateCategory recalculates and detects OVERALLOCATED status', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final foodCategory = container
          .read(budgetProvider)
          .variableCategories
          .firstWhere((c) => c.id == 'food_groceries');

      // Increase Food allocation from 65,000 to 200,000 (+135,000)
      final updatedFood = foodCategory.copyWith(assignedAmount: 200000);
      container.read(budgetProvider.notifier).updateCategory(updatedFood);

      final state = container.read(budgetProvider);
      // Total Allocated: 345,000 + 135,000 = 480,000
      // Unallocated: 450,000 - 480,000 = -30,000
      expect(state.calculation.totalAllocated, equals(480000.0));
      expect(state.calculation.unallocatedAmount, equals(-30000.0));
      expect(state.calculation.status, equals(BudgetStatus.overallocated));
      expect(state.calculation.status.displayName, equals('OVERALLOCATED'));
    });

    test('deleteCategory recalculates and frees up unallocated income', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Remove travel category (assigned: 30,000)
      container.read(budgetProvider.notifier).deleteCategory('travel_transport');

      final state = container.read(budgetProvider);
      expect(state.variableCategories.length, equals(2));
      // Total Allocated: 345,000 - 30,000 = 315,000
      // Unallocated: 450,000 - 315,000 = 135,000
      expect(state.calculation.totalAllocated, equals(315000.0));
      expect(state.calculation.unallocatedAmount, equals(135000.0));
      expect(state.calculation.status, equals(BudgetStatus.underallocated));
    });

    test('updateFixedBill modifies fixed allocation totals', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final rentBill = container
          .read(budgetProvider)
          .fixedBills
          .firstWhere((b) => b.id == 'apartment_rent');

      // Reduce rent from 120,000 to 100,000 (-20,000)
      final updatedRent = rentBill.copyWith(amount: 100000);
      container.read(budgetProvider.notifier).updateFixedBill(updatedRent);

      final state = container.read(budgetProvider);
      expect(state.calculation.totalFixedAllocated, equals(170000.0));
      expect(state.calculation.totalAllocated, equals(325000.0));
      expect(state.calculation.unallocatedAmount, equals(125000.0));
    });

    test('toggleBillPaid updates spent and available without altering unallocatedAmount', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialUnallocated =
          container.read(budgetProvider).calculation.unallocatedAmount;
      final initialSpent =
          container.read(budgetProvider).calculation.totalSpent;

      // Mark CEB bill (45,000) as paid
      container.read(budgetProvider.notifier).toggleBillPaid('ceb_bills');

      final state = container.read(budgetProvider);
      // Unallocated must remain unchanged
      expect(state.calculation.unallocatedAmount, equals(initialUnallocated));
      // Total spent increases by 45,000 (from 42,000 to 87,000)
      expect(state.calculation.totalSpent, equals(initialSpent + 45000.0));
    });

    test('setMonthlyIncome triggers dynamic status transition', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Set income to exactly total allocated (345,000)
      container.read(budgetProvider.notifier).setMonthlyIncome(345000);
      expect(
        container.read(budgetProvider).calculation.status,
        equals(BudgetStatus.balanced),
      );

      // Reduce income below total allocated
      container.read(budgetProvider.notifier).setMonthlyIncome(200000);
      expect(
        container.read(budgetProvider).calculation.status,
        equals(BudgetStatus.overallocated),
      );

      // Increase income above total allocated
      container.read(budgetProvider.notifier).setMonthlyIncome(500000);
      expect(
        container.read(budgetProvider).calculation.status,
        equals(BudgetStatus.underallocated),
      );
    });
  });

  group('Phase 4: Budget UI Screen Integration', () {
    testWidgets('BudgetSetupScreen displays dynamic status badge', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(const BudgetSetupScreen()));
      await tester.pumpAndSettle();

      // Verify the status badge is rendered
      expect(find.text('UNDERALLOCATED'), findsOneWidget);
      expect(find.text('Remaining to Allocate:'), findsOneWidget);
      expect(find.text('LKR 105,000'), findsOneWidget);
    });

    testWidgets('BudgetProgressScreen in live mode renders active budgetProvider calculations', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(const BudgetProgressScreen.live()),
      );
      await tester.pumpAndSettle();

      // Top bar contains live status badge
      expect(find.text('UNDERALLOCATED'), findsOneWidget);

      // Summary Card shows live totals (Income: 450,000; Assigned: 345,000)
      expect(find.text('Total Income: LKR 450,000'), findsOneWidget);
      expect(find.text('Assigned: LKR 345,000'), findsOneWidget);

      // 3 Metric Cards show live calculation results
      expect(find.text('Total Used'), findsOneWidget);
      expect(find.text('LKR 42,000'), findsOneWidget);
      expect(find.text('Total Available'), findsOneWidget);
      expect(find.text('LKR 303,000'), findsOneWidget);
      expect(find.text('Unassigned'), findsOneWidget);
      expect(find.text('LKR 105,000'), findsOneWidget);

      // Category Progress lists the 3 live categories from budgetProvider
      expect(find.text('CATEGORY PROGRESS (3 CATEGORIES)'), findsOneWidget);
      expect(find.text('Food & Groceries'), findsOneWidget);
      expect(find.text('Dining & Takeout'), findsOneWidget);
      expect(find.text('Travel & Transport'), findsOneWidget);
    });

    testWidgets('BudgetProgressScreen defaults to Live Mode and switches cleanly between Live and Reference views', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(const BudgetProgressScreen()),
      );
      await tester.pumpAndSettle();

      // 1. Initially opens in Live Mode by default
      expect(find.text('Total Income: LKR 450,000'), findsOneWidget);
      expect(find.text('Assigned: LKR 345,000'), findsOneWidget);
      expect(find.text('LKR 105,000'), findsOneWidget);
      expect(find.text('UNDERALLOCATED'), findsOneWidget);

      // 2. Tap mode switch to switch to Reference/Demo Mode
      final toggleBtn = find.byKey(const Key('budget_progress_mode_toggle'));
      expect(toggleBtn, findsOneWidget);
      await tester.tap(toggleBtn);
      await tester.pumpAndSettle();

      // Displays Reference/Demo numbers without affecting underlying provider data
      expect(find.text('Total Income: LKR 100,000'), findsOneWidget);
      expect(find.text('Assigned: LKR 100,000'), findsOneWidget);
      expect(find.text('Unassigned'), findsOneWidget);
      expect(find.text('LKR 0'), findsOneWidget);
      expect(find.text('Demo Mode'), findsOneWidget);

      // 3. Tap mode switch again to switch back to Live Mode
      await tester.tap(toggleBtn);
      await tester.pumpAndSettle();

      // Live mode data is completely restored
      expect(find.text('Total Income: LKR 450,000'), findsOneWidget);
      expect(find.text('Assigned: LKR 345,000'), findsOneWidget);
      expect(find.text('LKR 105,000'), findsOneWidget);
      expect(find.text('UNDERALLOCATED'), findsOneWidget);
    });
  });
}
