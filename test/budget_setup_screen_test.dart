import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prot/core/theme/app_theme.dart';
import 'package:prot/features/budget/presentation/add_budget_category_screen.dart';
import 'package:prot/features/budget/presentation/budget_screen.dart';
import 'package:prot/features/budget/presentation/budget_setup_screen.dart';
import 'package:prot/features/budget/presentation/edit_budget_category_screen.dart';
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

    // 6. Save & Update Budget Bottom Button
    expect(find.text('Save & Update Budget'), findsOneWidget);
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
}
