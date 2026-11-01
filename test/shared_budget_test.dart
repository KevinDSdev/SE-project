import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prot/core/theme/app_theme.dart';
import 'package:prot/features/budget/presentation/budget_progress_screen.dart';
import 'package:prot/features/budget/presentation/budget_setup_screen.dart';
import 'package:prot/features/budget/presentation/create_shared_budget_screen.dart';
import 'package:prot/features/budget/presentation/shared_budget_members_screen.dart';
import 'package:prot/features/budget/presentation/shared_budget_overview_screen.dart';

void main() {
  Widget createWidgetUnderTest(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: child,
      ),
    );
  }

  group('Shared Budget Navigation and Screens Tests', () {
    testWidgets('1. Screen 04 has Shared Budget button and navigates to Screen 06A',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(const BudgetProgressScreen()));
      await tester.pumpAndSettle();

      final sharedBudgetBtn = find.text('Shared Budget');
      expect(sharedBudgetBtn, findsOneWidget);

      await tester.ensureVisible(sharedBudgetBtn);
      await tester.pumpAndSettle();
      await tester.tap(sharedBudgetBtn);
      await tester.pumpAndSettle();

      // Screen 06A is opened
      expect(find.byType(SharedBudgetOverviewScreen), findsOneWidget);
      expect(find.text('Shared Budgets'), findsOneWidget);
      expect(find.text('Family Vacation'), findsOneWidget);
      expect(find.text('Goal: Save for a family holiday'), findsOneWidget);
      expect(find.text('3 Members'), findsOneWidget);
      expect(find.text('Shared Funds'), findsOneWidget);
      expect(find.text('LKR 150,000'), findsOneWidget);
      expect(find.text('Total Used'), findsOneWidget);
      expect(find.text('Total Available'), findsOneWidget);
      expect(find.text('LKR 105,000'), findsOneWidget);
      // Both Total Used and Accommodation available are LKR 45,000
      expect(find.text('LKR 45,000'), findsNWidgets(2));
      expect(find.text('SHARED CATEGORIES (4 CATEGORIES)'), findsOneWidget);
      expect(find.text('Accommodation'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Food & Dining'), findsOneWidget);
      expect(find.text('Activities'), findsOneWidget);
      expect(find.text('Manage Members'), findsOneWidget);
      expect(find.text('Edit Budget'), findsOneWidget);
      expect(find.text('Allocate Funds'), findsOneWidget);
    });

    testWidgets('2 & 3. Manage Members navigates to Screen 06C and back button returns to 06A',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(const SharedBudgetOverviewScreen()));
      await tester.pumpAndSettle();

      final manageMembersBtn = find.text('Manage Members');
      expect(manageMembersBtn, findsOneWidget);

      await tester.ensureVisible(manageMembersBtn);
      await tester.pumpAndSettle();
      await tester.tap(manageMembersBtn);
      await tester.pumpAndSettle();

      // Screen 06C is opened
      expect(find.byType(SharedBudgetMembersScreen), findsOneWidget);
      expect(find.text('Shared Budget Members'), findsOneWidget);
      expect(find.text('Invite New Member'), findsOneWidget);
      expect(find.text('Invite'), findsOneWidget);
      expect(find.text('GROUP MEMBERS (3)'), findsOneWidget);
      expect(find.text('You (Owner)'), findsOneWidget);
      expect(find.text('Family Member 1'), findsOneWidget);
      expect(find.text('Family Member 2'), findsOneWidget);
      expect(find.text('OWNER'), findsOneWidget);
      expect(find.text('MEMBER'), findsNWidgets(2));
      expect(find.text('Remove'), findsNWidgets(2));
      expect(find.text('Done'), findsOneWidget);

      // Back navigation via '<' returns to Screen 06A
      final backBtn = find.byIcon(Icons.chevron_left_rounded);
      expect(backBtn, findsOneWidget);
      await tester.tap(backBtn);
      await tester.pumpAndSettle();

      expect(find.byType(SharedBudgetOverviewScreen), findsOneWidget);
      expect(find.text('Shared Budgets'), findsOneWidget);
    });

    testWidgets('3b. Done button on Screen 06C also returns to Screen 06A',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(const SharedBudgetOverviewScreen()));
      await tester.pumpAndSettle();

      final manageMembersBtn = find.text('Manage Members');
      await tester.ensureVisible(manageMembersBtn);
      await tester.pumpAndSettle();
      await tester.tap(manageMembersBtn);
      await tester.pumpAndSettle();

      expect(find.byType(SharedBudgetMembersScreen), findsOneWidget);

      final doneBtn = find.text('Done');
      await tester.ensureVisible(doneBtn);
      await tester.pumpAndSettle();
      await tester.tap(doneBtn);
      await tester.pumpAndSettle();

      expect(find.byType(SharedBudgetOverviewScreen), findsOneWidget);
    });

    testWidgets('4. Edit Budget navigates to Screen 06B with pre-populated values',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(const SharedBudgetOverviewScreen()));
      await tester.pumpAndSettle();

      final editBudgetBtn = find.text('Edit Budget');
      expect(editBudgetBtn, findsOneWidget);

      await tester.ensureVisible(editBudgetBtn);
      await tester.pumpAndSettle();
      await tester.tap(editBudgetBtn);
      await tester.pumpAndSettle();

      // Screen 06B is opened
      expect(find.byType(CreateSharedBudgetScreen), findsOneWidget);
      expect(find.text('Create Shared Budget'), findsOneWidget);
      expect(find.text('Shared Budget Information'), findsOneWidget);
      expect(find.text('Shared Budget Name'), findsOneWidget);
      expect(find.text('Financial Goal / Purpose'), findsOneWidget);
      expect(find.text('Planning Period'), findsOneWidget);
      expect(find.text('Total Shared Funds (LKR)'), findsOneWidget);
      expect(find.text('Allocate Shared Categories'), findsOneWidget);

      // Pre-populated categories
      expect(find.text('Accommodation'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Food & Dining'), findsOneWidget);
      expect(find.text('Activities'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('5, 6 & 7. Editing category name and amount, then Cancel discards changes',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(const SharedBudgetOverviewScreen()));
      await tester.pumpAndSettle();

      // Food & Dining initial state
      expect(find.text('Food & Dining'), findsOneWidget);
      expect(find.text('Assigned: LKR 25,000'), findsOneWidget);

      // Open Edit Budget
      final editBudgetBtn = find.text('Edit Budget');
      await tester.ensureVisible(editBudgetBtn);
      await tester.pumpAndSettle();
      await tester.tap(editBudgetBtn);
      await tester.pumpAndSettle();

      expect(find.byType(CreateSharedBudgetScreen), findsOneWidget);

      // Find Food & Dining name input field and change to "Groceries"
      final foodField = find.widgetWithText(TextField, 'Food & Dining');
      expect(foodField, findsOneWidget);
      await tester.enterText(foodField, 'Groceries');
      await tester.pumpAndSettle();

      // Find 25,000 amount field and change to 18,000
      final amountField = find.widgetWithText(TextField, '25,000');
      expect(amountField, findsOneWidget);
      await tester.enterText(amountField, '18,000');
      await tester.pumpAndSettle();

      // Tap Cancel button
      final cancelBtn = find.text('Cancel');
      await tester.ensureVisible(cancelBtn);
      await tester.pumpAndSettle();
      await tester.tap(cancelBtn);
      await tester.pumpAndSettle();

      // Verify returned to Screen 06A
      expect(find.byType(SharedBudgetOverviewScreen), findsOneWidget);

      // Verify edits were discarded! "Food & Dining" and "25,000" are preserved.
      expect(find.text('Food & Dining'), findsOneWidget);
      expect(find.text('Assigned: LKR 25,000'), findsOneWidget);
      expect(find.text('Groceries'), findsNothing);
    });

    testWidgets('5, 6, 8 & 9. Editing category name and amount, then Save Changes updates Screen 06A',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(const SharedBudgetOverviewScreen()));
      await tester.pumpAndSettle();

      // Open Edit Budget
      final editBudgetBtn = find.text('Edit Budget');
      await tester.ensureVisible(editBudgetBtn);
      await tester.pumpAndSettle();
      await tester.tap(editBudgetBtn);
      await tester.pumpAndSettle();

      expect(find.byType(CreateSharedBudgetScreen), findsOneWidget);

      // Edit Food & Dining -> Groceries
      final foodField = find.widgetWithText(TextField, 'Food & Dining');
      await tester.enterText(foodField, 'Groceries');
      await tester.pumpAndSettle();

      // Edit 25,000 -> 18,000
      final amountField = find.widgetWithText(TextField, '25,000');
      await tester.enterText(amountField, '18,000');
      await tester.pumpAndSettle();

      // Tap Save Changes
      final saveBtn = find.text('Save Changes');
      await tester.ensureVisible(saveBtn);
      await tester.pumpAndSettle();
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      // Verify returned to Screen 06A
      expect(find.byType(SharedBudgetOverviewScreen), findsOneWidget);

      // Verify updated category information appears on Screen 06A!
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Assigned: LKR 18,000'), findsOneWidget);
      expect(find.text('Food & Dining'), findsNothing);
    });

    testWidgets('10. Full end-to-end flow from Screen 01 -> Screen 04 -> Screen 06A',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(const BudgetSetupScreen()));
      await tester.pumpAndSettle();

      // Screen 01 has View Budget Progress
      final viewProgressBtn = find.text('View Budget Progress');
      await tester.ensureVisible(viewProgressBtn);
      await tester.pumpAndSettle();
      await tester.tap(viewProgressBtn);
      await tester.pumpAndSettle();

      // Screen 04 is displayed
      expect(find.byType(BudgetProgressScreen), findsOneWidget);
      expect(find.text('Budget Progress'), findsOneWidget);

      // Tap Shared Budget on Screen 04
      final sharedBudgetBtn = find.text('Shared Budget');
      await tester.ensureVisible(sharedBudgetBtn);
      await tester.pumpAndSettle();
      await tester.tap(sharedBudgetBtn);
      await tester.pumpAndSettle();

      // Screen 06A is displayed
      expect(find.byType(SharedBudgetOverviewScreen), findsOneWidget);
      expect(find.text('Shared Budgets'), findsOneWidget);

      // Tap Back on Screen 06A -> returns to Screen 04
      final backTo04 = find.byIcon(Icons.chevron_left_rounded);
      await tester.tap(backTo04);
      await tester.pumpAndSettle();

      expect(find.byType(BudgetProgressScreen), findsOneWidget);

      // Tap Back on Screen 04 -> returns to Screen 01
      final backTo01 = find.byIcon(Icons.chevron_left_rounded);
      await tester.tap(backTo01);
      await tester.pumpAndSettle();

      expect(find.byType(BudgetSetupScreen), findsOneWidget);
    });
  });
}
