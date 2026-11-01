import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prot/core/theme/app_theme.dart';
import 'package:prot/features/budget/presentation/budget_progress_screen.dart';
import 'package:prot/features/budget/presentation/budget_setup_screen.dart';
import 'package:prot/features/budget/presentation/budget_template_selection_screen.dart';
import 'package:prot/features/budget/presentation/custom_budget_template_screen.dart';
import 'package:prot/features/budget/presentation/essential_budget_template_screen.dart';
import 'package:prot/features/budget/presentation/family_budget_template_screen.dart';
import 'package:prot/features/budget/presentation/student_budget_template_screen.dart';

void main() {
  Widget createWidgetUnderTest(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: child,
      ),
    );
  }

  group('Budget Template Selection and Preview Tests', () {
    testWidgets('1. Screen 04 has Budget Templates button and navigates to Screen 07',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(const BudgetProgressScreen()));
      await tester.pumpAndSettle();

      final templatesBtn = find.text('Budget Templates');
      expect(templatesBtn, findsOneWidget);

      await tester.ensureVisible(templatesBtn);
      await tester.pumpAndSettle();
      await tester.tap(templatesBtn);
      await tester.pumpAndSettle();

      // Verify Screen 07 opened
      expect(find.byType(BudgetTemplateSelectionScreen), findsOneWidget);
      expect(find.text('Budget Templates'), findsOneWidget);
      expect(find.text('Essential Budget'), findsOneWidget);
      expect(find.text('Student Budget'), findsOneWidget);
      expect(find.text('Family Budget'), findsOneWidget);
      expect(find.text('Custom Budget'), findsOneWidget);
      expect(find.text('Preview Template'), findsOneWidget);
    });

    testWidgets('2. Tapping Essential Budget navigates to Screen 07A and back returns',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(const BudgetTemplateSelectionScreen()));
      await tester.pumpAndSettle();

      final essentialCard = find.text('Essential Budget');
      expect(essentialCard, findsOneWidget);
      await tester.tap(essentialCard);
      await tester.pumpAndSettle();

      // Screen 07A is opened
      expect(find.byType(EssentialBudgetTemplateScreen), findsOneWidget);
      expect(find.text('Template Preview'), findsOneWidget);
      expect(find.text('Essential Budget'), findsOneWidget);
      expect(find.text('Balanced framework for daily necessities.'), findsOneWidget);
      expect(find.text('Available: LKR 100,000'), findsOneWidget);
      expect(find.text('Assigned: LKR 100,000'), findsOneWidget);
      expect(find.text('EXAMPLE ALLOCATIONS (5 CATEGORIES)'), findsOneWidget);
      expect(find.text('Bills & Utilities'), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Savings'), findsOneWidget);
      expect(find.text('Miscellaneous'), findsOneWidget);
      expect(find.text('Use This Template'), findsOneWidget);
      expect(find.text('Back to Templates'), findsOneWidget);

      // Back via '<'
      final backBtn = find.byIcon(Icons.chevron_left_rounded);
      await tester.tap(backBtn);
      await tester.pumpAndSettle();

      expect(find.byType(BudgetTemplateSelectionScreen), findsOneWidget);
    });

    testWidgets('3. Back to Templates button on Screen 07A returns to Screen 07',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(const EssentialBudgetTemplateScreen()));
      await tester.pumpAndSettle();

      final backBtn = find.text('Back to Templates');
      await tester.ensureVisible(backBtn);
      await tester.pumpAndSettle();
      await tester.tap(backBtn);
      await tester.pumpAndSettle();

      expect(find.byType(EssentialBudgetTemplateScreen), findsNothing);
    });

    testWidgets('4. Tapping Student Budget navigates to Screen 07B and back returns',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(const BudgetTemplateSelectionScreen()));
      await tester.pumpAndSettle();

      final studentCard = find.text('Student Budget');
      expect(studentCard, findsOneWidget);
      await tester.tap(studentCard);
      await tester.pumpAndSettle();

      // Screen 07B is opened
      expect(find.byType(StudentBudgetTemplateScreen), findsOneWidget);
      expect(find.text('Template Preview'), findsOneWidget);
      expect(find.text('Student Budget Template'), findsOneWidget);
      expect(find.text('Optimized for campus expenses, tuition, books & living.'), findsOneWidget);
      expect(find.text('Available: LKR 100,000'), findsOneWidget);
      expect(find.text('Assigned: LKR 100,000'), findsOneWidget);
      expect(find.text('EXAMPLE ALLOCATIONS (5 CATEGORIES)'), findsOneWidget);
      expect(find.text('Education & Courses'), findsOneWidget);
      expect(find.text('Food & Meals'), findsOneWidget);
      expect(find.text('Travel & Transport'), findsOneWidget);
      expect(find.text('Emergency Savings'), findsOneWidget);
      expect(find.text('Personal Expenses'), findsOneWidget);
      expect(find.text('Use This Template'), findsOneWidget);
      expect(find.text('Back to Templates'), findsOneWidget);

      // Back via '<'
      final backBtn = find.byIcon(Icons.chevron_left_rounded);
      await tester.tap(backBtn);
      await tester.pumpAndSettle();

      expect(find.byType(BudgetTemplateSelectionScreen), findsOneWidget);
    });

    testWidgets('5. Tapping Family Budget navigates to Screen 07C and back returns',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(const BudgetTemplateSelectionScreen()));
      await tester.pumpAndSettle();

      final familyCard = find.text('Family Budget');
      expect(familyCard, findsOneWidget);
      await tester.tap(familyCard);
      await tester.pumpAndSettle();

      // Screen 07C is opened
      expect(find.byType(FamilyBudgetTemplateScreen), findsOneWidget);
      expect(find.text('Template Preview'), findsOneWidget);
      expect(find.text('Family Budget'), findsOneWidget);
      expect(find.text('Comprehensive plan for multi-member homes.'), findsOneWidget);
      expect(find.text('Available: LKR 100,000'), findsOneWidget);
      expect(find.text('Assigned: LKR 100,000'), findsOneWidget);
      expect(find.text('EXAMPLE ALLOCATIONS (6 CATEGORIES)'), findsOneWidget);
      expect(find.text('Household Bills'), findsOneWidget);
      expect(find.text('Groceries & Food'), findsOneWidget);
      expect(find.text('Family Savings'), findsOneWidget);
      expect(find.text('Education & Kids'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Health & Personal'), findsOneWidget);
      expect(find.text('Use This Template'), findsOneWidget);
      expect(find.text('Back to Templates'), findsOneWidget);

      // Back via '<'
      final backBtn = find.byIcon(Icons.chevron_left_rounded);
      await tester.tap(backBtn);
      await tester.pumpAndSettle();

      expect(find.byType(BudgetTemplateSelectionScreen), findsOneWidget);
    });

    testWidgets('6. Tapping Custom Budget navigates to Screen 07D and back returns',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(const BudgetTemplateSelectionScreen()));
      await tester.pumpAndSettle();

      final customCard = find.text('Custom Budget');
      expect(customCard, findsOneWidget);
      await tester.tap(customCard);
      await tester.pumpAndSettle();

      // Screen 07D is opened
      expect(find.byType(CustomBudgetTemplateScreen), findsOneWidget);
      expect(find.text('Template Preview'), findsOneWidget);
      expect(find.text('Custom Budget'), findsOneWidget);
      expect(find.text('Blank canvas with zero predefined caps.'), findsOneWidget);
      expect(find.text('Available: LKR 100,000'), findsOneWidget);
      expect(find.text('YOUR CATEGORIES (0 CATEGORIES)'), findsOneWidget);
      expect(find.text('No categories yet'), findsOneWidget);
      expect(find.text('Start with 100% user-defined categories. Add your own and set your own limits.'), findsOneWidget);
      expect(find.text('Start Custom Budget'), findsOneWidget);
      expect(find.text('Back to Templates'), findsOneWidget);

      // Back via '<'
      final backBtn = find.byIcon(Icons.chevron_left_rounded);
      await tester.tap(backBtn);
      await tester.pumpAndSettle();

      expect(find.byType(BudgetTemplateSelectionScreen), findsOneWidget);
    });

    testWidgets('7. Preview Template button navigates to selected template screen',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(const BudgetTemplateSelectionScreen()));
      await tester.pumpAndSettle();

      final previewBtn = find.text('Preview Template');
      expect(previewBtn, findsOneWidget);
      await tester.ensureVisible(previewBtn);
      await tester.pumpAndSettle();
      await tester.tap(previewBtn);
      await tester.pumpAndSettle();

      // Default selected is Student Budget
      expect(find.byType(StudentBudgetTemplateScreen), findsOneWidget);
    });

    testWidgets('8. Full flow: Screen 01 -> Screen 04 -> Screen 07 -> Screen 07A -> Back',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(const BudgetSetupScreen()));
      await tester.pumpAndSettle();

      // 1. Screen 01 -> Screen 04
      final viewProgressBtn = find.text('View Budget Progress');
      await tester.ensureVisible(viewProgressBtn);
      await tester.pumpAndSettle();
      await tester.tap(viewProgressBtn);
      await tester.pumpAndSettle();

      expect(find.byType(BudgetProgressScreen), findsOneWidget);

      // 2. Screen 04 -> Screen 07
      final templatesBtn = find.text('Budget Templates');
      await tester.ensureVisible(templatesBtn);
      await tester.pumpAndSettle();
      await tester.tap(templatesBtn);
      await tester.pumpAndSettle();

      expect(find.byType(BudgetTemplateSelectionScreen), findsOneWidget);

      // 3. Screen 07 -> Screen 07A
      final essentialCard = find.text('Essential Budget');
      await tester.tap(essentialCard);
      await tester.pumpAndSettle();

      expect(find.byType(EssentialBudgetTemplateScreen), findsOneWidget);

      // 4. Back to Screen 07
      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(BudgetTemplateSelectionScreen), findsOneWidget);

      // 5. Back to Screen 04
      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(BudgetProgressScreen), findsOneWidget);

      // 6. Back to Screen 01
      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(BudgetSetupScreen), findsOneWidget);
    });
  });
}
