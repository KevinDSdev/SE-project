import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prot/core/theme/app_theme.dart';
import 'package:prot/features/analytics/presentation/financial_analytics_screen.dart';
import 'package:prot/features/analytics/presentation/transaction_history_screen.dart';

Widget createTestApp(Widget child) {
  return ProviderScope(
    child: MaterialApp(theme: AppTheme.lightTheme, home: child),
  );
}

void main() {
  group('TransactionHistoryScreen Tests', () {
    testWidgets('renders AppBar with Transaction History title', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp(const TransactionHistoryScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Transaction History'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
      expect(find.byIcon(Icons.filter_list_rounded), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('allows category filtering and text search entry', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(
          const TransactionHistoryScreen(
            initialCategory: HistoryCategoryFilter.groceries,
            initialSearchQuery: 'Keells',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Transaction History'), findsOneWidget);
      expect(find.text('Groceries'), findsWidgets);
      expect(find.text('Keells'), findsWidgets);
    });

    testWidgets('opens sort modal bottom sheet on filter button tap', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp(const TransactionHistoryScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.filter_list_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Sort Transactions'), findsOneWidget);
      expect(find.text('Newest First'), findsOneWidget);
      expect(find.text('Oldest First'), findsOneWidget);
      expect(find.text('Highest Amount'), findsOneWidget);
      expect(find.text('Lowest Amount'), findsOneWidget);
    });

    testWidgets(
      'FinancialAnalyticsScreen and TransactionHistoryScreen remain separate',
      (tester) async {
        await tester.pumpWidget(
          createTestApp(const FinancialAnalyticsScreen()),
        );
        await tester.pumpAndSettle();

        expect(find.text('Financial Analytics'), findsOneWidget);
      },
    );
  });
}
