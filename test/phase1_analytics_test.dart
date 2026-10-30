import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prot/core/services/app_preferences_service.dart';
import 'package:prot/features/analytics/presentation/financial_analytics_screen.dart';
import 'package:prot/features/analytics/presentation/screens/analytics_customization_screen.dart';
import 'package:prot/features/analytics/presentation/screens/categories_customization_screen.dart';
import 'package:prot/features/analytics/presentation/screens/dashboard_widgets_screen.dart';
import 'package:prot/features/analytics/presentation/screens/expense_analytics_screen.dart';
import 'package:prot/features/analytics/presentation/screens/goal_savings_analytics_screen.dart';
import 'package:prot/features/analytics/presentation/screens/income_analytics_screen.dart';
import 'package:prot/features/analytics/presentation/screens/prediction_analysis_screen.dart';
import 'package:prot/features/analytics/presentation/screens/report_export_screen.dart';
import 'package:prot/features/analytics/presentation/screens/select_export_requirement_screen.dart';
import 'package:prot/features/analytics/presentation/screens/spending_anomaly_screen.dart';
import 'package:prot/features/navigation/main_wrapper.dart';
import 'package:prot/features/profile/presentation/profile_screen.dart';
import 'package:prot/features/settings/presentation/screens/app_info_screen.dart';
import 'package:prot/features/settings/presentation/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPreferencesService.init();
  });

  Widget createTestWidget(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        home: child,
      ),
    );
  }

  testWidgets('Financial Analytics Dashboard renders properly with 5 quick actions',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const FinancialAnalyticsScreen()));

    expect(find.text('Financial Analytics'), findsOneWidget);
    expect(find.text('Monthly'), findsOneWidget);
    expect(find.text('Income'), findsWidgets);
    expect(find.text('Expenses'), findsWidgets);
    expect(find.text('Goal Savings'), findsWidgets);
    expect(find.text('Income Prediction'), findsOneWidget);
    expect(find.text('Expenses Prediction'), findsOneWidget);
    expect(find.text('Import Statements'), findsOneWidget);
    expect(find.text('Export Hub'), findsOneWidget);
    expect(find.text('Anomaly Detection'), findsOneWidget);
    // Verified: Transaction History quick action is removed from dashboard
    expect(find.text('Transaction History'), findsNothing);
  });

  testWidgets('App Settings screen renders sections and controls with Dark Mode toggle',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const SettingsScreen()));

    expect(find.text('App Settings'), findsOneWidget);
    expect(find.text('Dark Mode Theme'), findsOneWidget);
    expect(find.text('Primary Accent Color'), findsOneWidget);
    expect(find.text('Customize Widgets'), findsOneWidget);
    expect(find.text('Customize Analytical Dashboard'), findsOneWidget);
    expect(find.text('Notifications & Alerts'), findsOneWidget);
    expect(find.text('Daily Log Reminder Time'), findsOneWidget);
    expect(find.text('GPS Location Suggestions'), findsOneWidget);
    expect(find.text('Cloud Real-time Auto-Sync'), findsOneWidget);
    expect(find.text('Local Encrypted Database'), findsOneWidget);
    expect(find.text('Biometric Face ID / Fingerprint'), findsOneWidget);
    expect(find.text('App Information'), findsOneWidget);
    expect(find.text('System Version'), findsOneWidget);
  });

  testWidgets('Dashboard Widgets screen renders active and available list with taps',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const DashboardWidgetsScreen()));

    expect(find.text('Dashboard Layout'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
    expect(find.text('Active Dashboard Layout'), findsOneWidget);
    expect(find.text('Available Widgets to Add'), findsOneWidget);
    expect(find.text('Save Preferences'), findsOneWidget);
  });

  testWidgets('Profile Screen renders LKR account details, quick stats, and grouped sections',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const ProfileScreen()));

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Kavinda Perera'), findsOneWidget);
    expect(find.text('kavinda.perera@email.lk'), findsOneWidget);
    expect(find.text('Linked Banks'), findsOneWidget);
    expect(find.text('Budget Mode'), findsOneWidget);
    expect(find.text('CRIB Score'), findsOneWidget);
    expect(find.text('Bank Accounts'), findsOneWidget);
    expect(find.text('Bank SMS Auto-Sync'), findsOneWidget);
    expect(find.text('App Settings'), findsOneWidget);
    expect(find.text('Download Statements'), findsOneWidget);
    expect(find.text('Transaction History'), findsOneWidget);
  });

  testWidgets('Analytics Customization screen renders chart style selectors',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(createTestWidget(const AnalyticsCustomizationScreen()));

    expect(find.text('Analytics Customization'), findsOneWidget);
    expect(find.text('Main Dashboard Customization'), findsOneWidget);
    expect(find.text('Visual Mode'), findsOneWidget);
    expect(find.text('Sub Dashboard Customization'), findsOneWidget);
    expect(find.text('Overall Trend'), findsOneWidget);
    expect(find.text('Category Breakdown'), findsOneWidget);
    expect(find.text('Customize Sectors & Categories'), findsOneWidget);
  });

  testWidgets('Categories Customization screen renders tabs and items',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(createTestWidget(const CategoriesCustomizationScreen()));

    expect(find.text('Analytics Customization'), findsOneWidget);
    expect(find.text('Income Methods'), findsOneWidget);
    expect(find.text('Expense Categories'), findsOneWidget);
    expect(find.text('Primary Salary'), findsOneWidget);
    expect(find.text('Apply Layout to All 3 Sub-Dashboards'), findsOneWidget);
    expect(find.text('Save & Apply Customization'), findsOneWidget);
  });

  testWidgets('Report Export screen renders formats, filters, and actions',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const ReportExportScreen()));

    expect(find.text('Export'), findsOneWidget);
    expect(find.text('PDF Report'), findsOneWidget);
    expect(find.text('Excel (.XLSX)'), findsOneWidget);
    expect(find.text('Raw Data'), findsOneWidget);
    expect(find.text('Time Period'), findsOneWidget);
    expect(find.text('Accounts'), findsOneWidget);
    expect(find.text('Generate & Download Report'), findsOneWidget);
    expect(find.text('Share to WhatsApp'), findsOneWidget);
  });

  testWidgets('Select Export Requirement screen renders all 7 modules',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(createTestWidget(const SelectExportRequirementScreen()));

    expect(find.text('Select Requirement'), findsOneWidget);
    expect(find.text('Transaction History'), findsOneWidget);
    expect(find.text('Income Analysis'), findsOneWidget);
    expect(find.text('Expenses Analysis'), findsOneWidget);
    expect(find.text('Goal Savings Analysis'), findsOneWidget);
    expect(find.text('Income Prediction Analysis'), findsOneWidget);
    expect(find.text('Expenses Prediction Analysis'), findsOneWidget);
    expect(find.text('Debt, BNPL & Investments'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);
  });

  testWidgets('Income Analytics renders charts and streams',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const IncomeAnalyticsScreen()));

    expect(find.text('Income Analytics'), findsOneWidget);
    expect(find.text('LKR 535,000'), findsOneWidget);
    expect(find.text('Primary Salary'), findsWidgets);
    expect(find.text('All Income Streams'), findsOneWidget);
  });

  testWidgets('Expense Analytics renders charts and distribution',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const ExpenseAnalyticsScreen()));

    expect(find.text('Expense Analytics'), findsOneWidget);
    expect(find.text('LKR 318,500'), findsOneWidget);
    expect(find.text('Categories Breakdown'), findsOneWidget);
  });

  testWidgets('Goal Savings Analytics renders cushion and targets',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(createTestWidget(const GoalSavingsAnalyticsScreen()));

    expect(find.text('Goal Savings Analytics'), findsOneWidget);
    expect(find.text('LKR 108,000'), findsOneWidget);
    expect(find.text('Emergency Fund (6-Months Cushion)'), findsOneWidget);
    expect(find.text('Other Active Savings Targets'), findsOneWidget);
  });

  testWidgets('Prediction Analysis toggles between Expenses and Income',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const PredictionAnalysisScreen(
      initialMode: PredictionMode.expenses,
    )));

    expect(find.text('Expenses Prediction Analysis'), findsOneWidget);
    expect(find.text('Expenses Forecast'), findsOneWidget);
    expect(find.text('Income Forecast'), findsOneWidget);
    expect(find.text('Nov 2026 Expected Outflow'), findsOneWidget);
    expect(find.text('LKR 330,000'), findsOneWidget);

    // Tap to switch to Income Forecast
    await tester.tap(find.text('Income Forecast'));
    await tester.pumpAndSettle();

    expect(find.text('Income Prediction Analysis'), findsOneWidget);
    expect(find.text('Nov 2026 Expected Inflow'), findsOneWidget);
    expect(find.text('LKR 540,000'), findsOneWidget);
  });

  testWidgets('Spending Anomaly Analysis renders detected anomalies and spikes',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const SpendingAnomalyScreen()));

    expect(find.text('Spending Anomaly Analysis'), findsOneWidget);
    expect(find.text('Unusual Spendings'), findsOneWidget);
    expect(find.text('Category Spike Breakdown'), findsOneWidget);
    expect(find.text('Flagged Transactions'), findsOneWidget);
    expect(find.text('CEB Electricity Bill'), findsOneWidget);
    expect(find.text('Pizza Hut'), findsOneWidget);
  });

  testWidgets('App Info screen renders ECORP branding and legal specifications',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const AppInfoScreen()));

    expect(find.text('App Information'), findsOneWidget);
    expect(find.text('ECORP'), findsOneWidget);
    expect(find.text('Personal Budgeting App'), findsOneWidget);
    expect(find.text('Free & Open Source'), findsOneWidget);
    expect(find.text('Local-First Mode'), findsOneWidget);
    expect(find.text('Data & Privacy Summary'), findsOneWidget);
    expect(find.text('Group ECORP'), findsOneWidget);
  });

  testWidgets('MainWrapper renders 5-tab navigation bar with Analytics',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const MainWrapper()));

    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Budget'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Goals'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
