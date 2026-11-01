import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prot/core/theme/app_theme.dart';
import 'package:prot/features/budget/presentation/add_budget_category_screen.dart';
import 'package:prot/features/budget/presentation/add_fixed_bill_screen.dart';
import 'package:prot/features/budget/presentation/budget_progress_screen.dart';
import 'package:prot/features/budget/presentation/budget_screen.dart';
import 'package:prot/features/budget/presentation/budget_setup_screen.dart';
import 'package:prot/features/budget/presentation/edit_budget_category_screen.dart';
import 'package:prot/features/budget/presentation/edit_fixed_bill_screen.dart';
import 'package:prot/features/navigation/main_wrapper.dart';

void main() {
  Widget createWidgetUnderTest(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: child,
      ),
    );
  }

  testWidgets('BudgetSetupScreen renders all key components matching Screen 01 design', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const BudgetSetupScreen()));
    await tester.pumpAndSettle();

    // 1. Screen Title
    expect(find.text('Monthly Budget Setup'), findsOneWidget);

    // 2. Monthly Income Hero Card
    expect(find.text('Monthly Income'), findsOneWidget);
    expect(find.text('Base salary & extras'), findsOneWidget);
    expect(find.text('LKR 450,000'), findsOneWidget);

    // 3. Remaining to Allocate Banner
    expect(find.text('Remaining to Allocate:'), findsOneWidget);
    expect(find.text('LKR 105,000'), findsOneWidget);

    // 4. Variable Expense Budgets Section
    expect(find.text('Variable Expense Budgets'), findsOneWidget);
    expect(find.text('Type cap below'), findsOneWidget);
    expect(find.text('Food & Groceries'), findsOneWidget);
    expect(find.text('LKR 65,000'), findsOneWidget);
    expect(find.text('Dining & Takeout'), findsOneWidget);
    expect(find.text('LKR 35,000'), findsOneWidget);
    expect(find.text('Travel & Transport'), findsOneWidget);
    expect(find.text('LKR 30,000'), findsOneWidget);
    expect(find.text('+ Add New Budget Category'), findsOneWidget);

    // 5. Update Fixed Monthly Bills Section
    expect(find.text('Update Fixed Monthly Bills'), findsOneWidget);
    expect(find.text('Total: LKR 190,000'), findsOneWidget);
    expect(find.text('Apartment Rent'), findsOneWidget);
    expect(find.text('LKR 120,000'), findsOneWidget);
    expect(find.text('CEB Electricity & Water'), findsOneWidget);
    expect(find.text('LKR 45,000'), findsOneWidget);
    expect(find.text('Dialog & Insurance'), findsOneWidget);
    expect(find.text('LKR 25,000'), findsOneWidget);
    expect(find.text('+ Add New Fixed Bill'), findsOneWidget);

    // 6. Bottom Action Buttons matching updated Screen 01 design
    expect(find.text('Add Recurring & Subscription'), findsOneWidget);
    expect(find.text('View Budget Progress'), findsOneWidget);
  });

  testWidgets('BudgetScreen entry point renders BudgetSetupScreen', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const BudgetScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(BudgetSetupScreen), findsOneWidget);
    expect(find.text('Monthly Budget Setup'), findsOneWidget);
  });

  testWidgets('Clicking Budget navigation tab in MainWrapper displays BudgetSetupScreen', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const MainWrapper()));
    await tester.pumpAndSettle();

    final budgetTab = find.text('Budget');
    expect(budgetTab, findsOneWidget);
    await tester.tap(budgetTab);
    await tester.pumpAndSettle();

    expect(find.byType(BudgetSetupScreen), findsOneWidget);
    expect(find.text('Monthly Budget Setup'), findsOneWidget);
  });

  testWidgets('Tapping Add Budget Category navigates to AddBudgetCategoryScreen and back', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const BudgetSetupScreen()));
    await tester.pumpAndSettle();

    // Tap Add Budget Category
    final addCategoryBtn = find.text('+ Add New Budget Category');
    expect(addCategoryBtn, findsOneWidget);
    await tester.tap(addCategoryBtn);
    await tester.pumpAndSettle();

    // Verify AddBudgetCategoryScreen is opened
    expect(find.byType(AddBudgetCategoryScreen), findsOneWidget);
    expect(find.text('Add Budget Category'), findsOneWidget);
    expect(find.text('Category Information'), findsOneWidget);
    expect(find.text('Category Group'), findsOneWidget);
    expect(find.text('Category Icon'), findsOneWidget);
    expect(find.text('Category Color'), findsOneWidget);
    expect(find.text('Budget Allocation'), findsOneWidget);
    expect(find.text('Add Category'), findsOneWidget);
    expect(find.text('Advanced setting'), findsOneWidget);

    // Tap back button
    final backBtn = find.byIcon(Icons.chevron_left_rounded);
    expect(backBtn, findsOneWidget);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    // Verify returned to BudgetSetupScreen
    expect(find.byType(BudgetSetupScreen), findsOneWidget);
    expect(find.text('Monthly Budget Setup'), findsOneWidget);
  });

  testWidgets('Tapping Food & Groceries opens EditBudgetCategoryScreen with its data and back returns', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const BudgetSetupScreen()));
    await tester.pumpAndSettle();

    // Tap Food & Groceries
    final foodItem = find.text('Food & Groceries');
    expect(foodItem, findsOneWidget);
    await tester.tap(foodItem);
    await tester.pumpAndSettle();

    // Verify EditBudgetCategoryScreen is opened with Food & Groceries details
    expect(find.byType(EditBudgetCategoryScreen), findsOneWidget);
    expect(find.text('Edit Budget Category'), findsOneWidget);
    expect(find.text('Category Details'), findsOneWidget);
    expect(find.text('Food & Groceries'), findsOneWidget);
    expect(find.text('Budget Allocation & Status'), findsOneWidget);
    expect(find.text('65,000'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
    expect(find.text('Delete Category'), findsOneWidget);

    // Tap back button
    final backBtn = find.byIcon(Icons.chevron_left_rounded);
    expect(backBtn, findsOneWidget);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    // Verify returned to BudgetSetupScreen
    expect(find.byType(BudgetSetupScreen), findsOneWidget);
    expect(find.text('Monthly Budget Setup'), findsOneWidget);
  });

  testWidgets('Tapping Dining & Takeout opens EditBudgetCategoryScreen with its data', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const BudgetSetupScreen()));
    await tester.pumpAndSettle();

    // Tap Dining & Takeout
    final diningItem = find.text('Dining & Takeout');
    expect(diningItem, findsOneWidget);
    await tester.tap(diningItem);
    await tester.pumpAndSettle();

    // Verify EditBudgetCategoryScreen displays Dining & Takeout details
    expect(find.byType(EditBudgetCategoryScreen), findsOneWidget);
    expect(find.text('Edit Budget Category'), findsOneWidget);
    expect(find.text('Dining & Takeout'), findsOneWidget);
    expect(find.text('35,000'), findsOneWidget);

    // Tap back button
    final backBtn = find.byIcon(Icons.chevron_left_rounded);
    expect(backBtn, findsOneWidget);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    expect(find.byType(BudgetSetupScreen), findsOneWidget);
  });

  testWidgets('Tapping Apartment Rent fixed bill opens EditFixedBillScreen (03B) with its data', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const BudgetSetupScreen()));
    await tester.pumpAndSettle();

    // Tap Apartment Rent
    final rentItem = find.text('Apartment Rent');
    expect(rentItem, findsOneWidget);
    await tester.ensureVisible(rentItem);
    await tester.pumpAndSettle();
    await tester.tap(rentItem);
    await tester.pumpAndSettle();

    // Verify EditFixedBillScreen (03B) is opened with Apartment Rent details
    expect(find.byType(EditFixedBillScreen), findsOneWidget);
    expect(find.text('Edit Fixed Bill'), findsOneWidget);
    expect(find.text('Monthly Fixed Bill'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Paid'), findsOneWidget);
    expect(find.text('Mr. Sandun (Landlord)'), findsOneWidget);
    expect(find.text('120,000'), findsOneWidget);
    expect(find.text('Day 1 of every month'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
    expect(find.text('Delete Fixed Bill'), findsOneWidget);

    // Tap back button
    final backBtn = find.byIcon(Icons.chevron_left_rounded);
    expect(backBtn, findsOneWidget);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    // Returns to BudgetSetupScreen
    expect(find.byType(BudgetSetupScreen), findsOneWidget);
    expect(find.text('Monthly Budget Setup'), findsOneWidget);
  });

  testWidgets('Tapping CEB Electricity & Water opens EditFixedBillScreen with CEB data', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const BudgetSetupScreen()));
    await tester.pumpAndSettle();

    // Tap CEB Electricity & Water
    final cebItem = find.text('CEB Electricity & Water');
    expect(cebItem, findsOneWidget);
    await tester.ensureVisible(cebItem);
    await tester.pumpAndSettle();
    await tester.tap(cebItem);
    await tester.pumpAndSettle();

    // Verify EditFixedBillScreen displays CEB details
    expect(find.byType(EditFixedBillScreen), findsOneWidget);
    expect(find.text('Edit Fixed Bill'), findsOneWidget);
    expect(find.text('CEB Electricity & Water'), findsNWidgets(2)); // Header & field
    expect(find.text('45,000'), findsOneWidget);
    expect(find.text('Day 10 of every month'), findsOneWidget);

    // Tap back button
    final backBtn = find.byIcon(Icons.chevron_left_rounded);
    expect(backBtn, findsOneWidget);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    expect(find.byType(BudgetSetupScreen), findsOneWidget);
  });

  testWidgets('Tapping Save Changes on EditFixedBillScreen navigates back and updates Screen 01', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const BudgetSetupScreen()));
    await tester.pumpAndSettle();

    // Tap Apartment Rent
    final rentItem = find.text('Apartment Rent');
    await tester.ensureVisible(rentItem);
    await tester.pumpAndSettle();
    await tester.tap(rentItem);
    await tester.pumpAndSettle();

    expect(find.byType(EditFixedBillScreen), findsOneWidget);

    // Tap Save Changes
    final saveBtn = find.text('Save Changes');
    expect(saveBtn, findsOneWidget);
    await tester.ensureVisible(saveBtn);
    await tester.pumpAndSettle();
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();

    // Verify navigated back to Screen 01
    expect(find.byType(BudgetSetupScreen), findsOneWidget);
    expect(find.text('Monthly Budget Setup'), findsOneWidget);
    expect(find.text('Apartment Rent'), findsOneWidget);
  });

  testWidgets('Tapping Add Fixed Bill navigates to AddFixedBillScreen (03A) and back', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const BudgetSetupScreen()));
    await tester.pumpAndSettle();

    // Tap Add Fixed Bill
    final addBillBtn = find.text('+ Add New Fixed Bill');
    expect(addBillBtn, findsOneWidget);
    await tester.ensureVisible(addBillBtn);
    await tester.pumpAndSettle();
    await tester.tap(addBillBtn);
    await tester.pumpAndSettle();

    // Verify AddFixedBillScreen (03A) is opened
    expect(find.byType(AddFixedBillScreen), findsOneWidget);
    expect(find.text('Add Fixed Bill'), findsNWidgets(2)); // Title & Button
    expect(find.text('Bill Name'), findsOneWidget);
    expect(find.text('Biller / Provider Name'), findsOneWidget);
    expect(find.text('Monthly Amount'), findsOneWidget);
    expect(find.text('Due Date'), findsOneWidget);
    expect(find.text('Category & Icon'), findsOneWidget);
    expect(find.text('Internet'), findsOneWidget);
    expect(find.text('Insurance'), findsOneWidget);
    expect(find.text('Rent'), findsOneWidget);
    expect(find.text('medicine'), findsOneWidget);
    expect(find.text('Phone'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);

    // Tap back button
    final backBtn = find.byIcon(Icons.chevron_left_rounded);
    expect(backBtn, findsOneWidget);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    // Verify returned to BudgetSetupScreen
    expect(find.byType(BudgetSetupScreen), findsOneWidget);
    expect(find.text('Monthly Budget Setup'), findsOneWidget);
  });

  testWidgets('Tapping View Budget Progress navigates to BudgetProgressScreen (04) and back returns', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const BudgetSetupScreen()));
    await tester.pumpAndSettle();

    // Tap View Budget Progress button
    final viewProgressBtn = find.text('View Budget Progress');
    expect(viewProgressBtn, findsOneWidget);
    await tester.ensureVisible(viewProgressBtn);
    await tester.pumpAndSettle();
    await tester.tap(viewProgressBtn);
    await tester.pumpAndSettle();

    // Verify BudgetProgressScreen is opened
    expect(find.byType(BudgetProgressScreen), findsOneWidget);
    expect(find.text('Budget Progress'), findsOneWidget);
    expect(find.text('Total Income: LKR 100,000'), findsOneWidget);
    expect(find.text('Assigned: LKR 100,000'), findsOneWidget);
    expect(find.text('Total Used'), findsOneWidget);
    expect(find.text('Total Available'), findsOneWidget);
    expect(find.text('Unassigned'), findsOneWidget);
    expect(find.text('CATEGORY PROGRESS (5 CATEGORIES)'), findsOneWidget);
    expect(find.text('Bills'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Transport'), findsOneWidget);
    expect(find.text('Savings'), findsOneWidget);

    // Tap back button '<'
    final backBtn = find.byIcon(Icons.chevron_left_rounded);
    expect(backBtn, findsOneWidget);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    // Verify returned to BudgetSetupScreen
    expect(find.byType(BudgetSetupScreen), findsOneWidget);
    expect(find.text('Monthly Budget Setup'), findsOneWidget);
  });

  testWidgets('BudgetProgressScreen standalone renders default values matching Screen 04 reference', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const BudgetProgressScreen()));
    await tester.pumpAndSettle();

    // Screen title and top bar
    expect(find.text('Budget Progress'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);

    // Summary Card values
    expect(find.text('Total Income: LKR 100,000'), findsOneWidget);
    expect(find.text('Assigned: LKR 100,000'), findsOneWidget);

    // 3 Metric Cards
    expect(find.text('Total Used'), findsOneWidget);
    expect(find.text('LKR 42,000'), findsOneWidget);
    expect(find.text('Total Available'), findsOneWidget);
    expect(find.text('LKR 58,000'), findsOneWidget);
    expect(find.text('Unassigned'), findsOneWidget);
    expect(find.text('LKR 0'), findsOneWidget);

    // Category progress header
    expect(find.text('CATEGORY PROGRESS (5 CATEGORIES)'), findsOneWidget);

    // Categories
    expect(find.text('Bills'), findsOneWidget);
    expect(find.text('Assigned: LKR 30,000'), findsOneWidget);
    expect(find.text('LKR 15,000'), findsOneWidget);

    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Assigned: LKR 25,000'), findsOneWidget);
    expect(find.text('LKR 13,000'), findsOneWidget);

    expect(find.text('Transport'), findsOneWidget);
    expect(find.text('Assigned: LKR 15,000'), findsOneWidget);

    expect(find.text('Savings'), findsOneWidget);
    expect(find.text('Assigned: LKR 20,000'), findsOneWidget);

    // Both Transport and Savings have LKR 10,000 available
    expect(find.text('LKR 10,000'), findsNWidgets(2));

    // Verify no obsolete zero-based budget banner or edit buttons
    expect(find.byIcon(Icons.edit_outlined), findsNothing);
    expect(find.byIcon(Icons.bar_chart_rounded), findsNothing);
  });

  testWidgets('Tapping Add Recurring & Subscription shows snackbar on BudgetSetupScreen', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const BudgetSetupScreen()));
    await tester.pumpAndSettle();

    final recurringBtn = find.text('Add Recurring & Subscription');
    expect(recurringBtn, findsOneWidget);
    await tester.ensureVisible(recurringBtn);
    await tester.pumpAndSettle();
    await tester.tap(recurringBtn);
    await tester.pump();

    // Verify SnackBar shown
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Add Recurring & Subscription'), findsNWidgets(2)); // Button & snackbar
  });
}
