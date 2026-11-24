import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/slide_route.dart';
import '../../../core/providers/navigation_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/analytics_provider.dart';
import '../services/analytics_period_helper.dart';
import 'screens/expense_analytics_screen.dart';
import 'screens/goal_savings_analytics_screen.dart';
import 'screens/income_analytics_screen.dart';
import 'screens/prediction_analysis_screen.dart';
import 'screens/report_export_screen.dart';
import 'screens/spending_anomaly_screen.dart';
import 'widgets/analytics_chart_widgets.dart';
import 'widgets/import_statements_dialog.dart';

class FinancialAnalyticsScreen extends ConsumerStatefulWidget {
  const FinancialAnalyticsScreen({super.key});

  @override
  ConsumerState<FinancialAnalyticsScreen> createState() =>
      _FinancialAnalyticsScreenState();
}

class _FinancialAnalyticsScreenState
    extends ConsumerState<FinancialAnalyticsScreen> {
  final NumberFormat _currencyFormat = NumberFormat('#,##,000');
  int _selectedMonthIndex = 5; // Default October / last entry

  final List<Map<String, dynamic>> _weeklyData = [
    {'month': 'W1', 'income': 120000.0, 'expense': 75000.0, 'savings': 5000.0},
    {'month': 'W2', 'income': 135000.0, 'expense': 82000.0, 'savings': 6000.0},
    {'month': 'W3', 'income': 130000.0, 'expense': 78000.0, 'savings': 4000.0},
    {'month': 'W4', 'income': 150000.0, 'expense': 83500.0, 'savings': 5000.0},
  ];

  final List<Map<String, dynamic>> _monthlyData = [
    {
      'month': 'May',
      'income': 420000.0,
      'expense': 280000.0,
      'savings': 15000.0,
    },
    {
      'month': 'Jun',
      'income': 450000.0,
      'expense': 310000.0,
      'savings': 18000.0,
    },
    {
      'month': 'Jul',
      'income': 480000.0,
      'expense': 295000.0,
      'savings': 20000.0,
    },
    {
      'month': 'Aug',
      'income': 460000.0,
      'expense': 340000.0,
      'savings': 12000.0,
    },
    {
      'month': 'Sep',
      'income': 510000.0,
      'expense': 305000.0,
      'savings': 25000.0,
    },
    {
      'month': 'Oct',
      'income': 535000.0,
      'expense': 318500.0,
      'savings': 20000.0,
    },
  ];

  final List<Map<String, dynamic>> _yearlyData = [
    {
      'month': '2021',
      'income': 4800000.0,
      'expense': 3200000.0,
      'savings': 200000.0,
    },
    {
      'month': '2022',
      'income': 5200000.0,
      'expense': 3500000.0,
      'savings': 240000.0,
    },
    {
      'month': '2023',
      'income': 5800000.0,
      'expense': 3700000.0,
      'savings': 280000.0,
    },
    {
      'month': '2024',
      'income': 6100000.0,
      'expense': 3900000.0,
      'savings': 300000.0,
    },
    {
      'month': '2025',
      'income': 6300000.0,
      'expense': 3800000.0,
      'savings': 320000.0,
    },
    {
      'month': '2026',
      'income': 6420000.0,
      'expense': 3822000.0,
      'savings': 350000.0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final selectedPeriod = ref.watch(
      analyticsScreenPeriodProvider(AnalyticsScreenType.financial),
    );
    final mainStyle = ref.watch(mainChartStyleProvider);
    final accentColor = ref.watch(accentColorProvider).color;
    final widgetsState = ref.watch(dashboardWidgetsProvider);
    final activeIds = widgetsState.activeWidgets.map((w) => w.id).toSet();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = AppColors.getBg(isDark);
    final cardBg = AppColors.getCard(isDark);
    final borderColor = AppColors.getBorder(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final textSecondary = AppColors.getTextSecondary(isDark);

    final List<Map<String, dynamic>> currentData;
    final String chartTitle;
    switch (selectedPeriod) {
      case AnalyticsPeriod.weekly:
        final weeklyBuckets = AnalyticsPeriodHelper.getWeeklyBuckets();
        currentData = List.generate(_weeklyData.length, (i) {
          final label = i < weeklyBuckets.length
              ? weeklyBuckets[i].label
              : 'W${i + 1}';
          return {..._weeklyData[i], 'month': label};
        });
        chartTitle = 'Income vs Expenses (Weekly)';
        break;
      case AnalyticsPeriod.monthly:
        currentData = _monthlyData;
        chartTitle = 'Income vs Expenses (May – Oct)';
        break;
      case AnalyticsPeriod.yearly:
        currentData = _yearlyData;
        chartTitle = 'Income vs Expenses (2021 – 2026)';
        break;
      default:
        currentData = _monthlyData;
        chartTitle = 'Income vs Expenses (May – Oct)';
    }

    final selectedIdx = _selectedMonthIndex.clamp(0, currentData.length - 1);
    final activeItem = currentData[selectedIdx];

    final double activeIncome = (activeItem['income'] as num).toDouble();
    final double activeExpense = (activeItem['expense'] as num).toDouble();
    final double activeSavings = ((activeItem['savings'] ?? 20000.0) as num)
        .toDouble();

    final showIncome = activeIds.contains('active_income');
    final showExpense = activeIds.contains('active_expenses');
    final showSavings = activeIds.contains('active_savings');
    final showTrend = activeIds.contains('active_trend');

    final hasAnySummary = showIncome || showExpense || showSavings;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Back Button & Title
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        ref.read(selectedTabProvider.notifier).setTab(0);
                      }
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Icon(
                        Icons.chevron_left_rounded,
                        color: textPrimary,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Financial Analytics',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Period Selector
              Container(
                height: 44,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: accentColor, width: 1.2),
                ),
                child: Row(
                  children: [
                    _buildPeriodItem(
                      AnalyticsPeriod.weekly,
                      'Weekly',
                      selectedPeriod,
                      accentColor,
                      textSecondary,
                    ),
                    _buildPeriodItem(
                      AnalyticsPeriod.monthly,
                      'Monthly',
                      selectedPeriod,
                      accentColor,
                      textSecondary,
                    ),
                    _buildPeriodItem(
                      AnalyticsPeriod.yearly,
                      'Yearly',
                      selectedPeriod,
                      accentColor,
                      textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Summary Cards (Dynamically driven by Dashboard Widgets preferences)
              if (hasAnySummary) ...[
                Row(
                  children: [
                    if (showIncome)
                      Expanded(
                        child: _buildSummaryCard(
                          title: 'Income',
                          amount: _currencyFormat.format(activeIncome.toInt()),
                          color: const Color(0xFF98E836),
                          textColor: const Color(0xFF0C0F14),
                          onTap: () {
                            Navigator.of(
                              context,
                            ).push(slideRoute(const IncomeAnalyticsScreen()));
                          },
                        ),
                      ),
                    if (showIncome && (showExpense || showSavings))
                      const SizedBox(width: 10),
                    if (showExpense)
                      Expanded(
                        child: _buildSummaryCard(
                          title: 'Expenses',
                          amount: _currencyFormat.format(activeExpense.toInt()),
                          color: const Color(0xFFF43F5E),
                          textColor: const Color(0xFF0C0F14),
                          onTap: () {
                            Navigator.of(
                              context,
                            ).push(slideRoute(const ExpenseAnalyticsScreen()));
                          },
                        ),
                      ),
                    if (showExpense && showSavings) const SizedBox(width: 10),
                    if (showSavings)
                      Expanded(
                        child: _buildSummaryCard(
                          title: 'Goal Savings',
                          amount: _currencyFormat.format(activeSavings.toInt()),
                          color: const Color(0xFF38BDF8),
                          textColor: const Color(0xFF0C0F14),
                          onTap: () {
                            Navigator.of(context).push(
                              slideRoute(const GoalSavingsAnalyticsScreen()),
                            );
                          },
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
              ],

              // Income vs Expenses Comparison Chart (Dynamically driven by Widget preferences)
              if (showTrend) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            chartTitle,
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.circle,
                                color: Color(0xFF98E836),
                                size: 8,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'In',
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.circle,
                                color: Color(0xFFF43F5E),
                                size: 8,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Ex',
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (mainStyle == ChartVisualMode.line)
                        DualTrendLineChart(
                          labels: currentData
                              .map((m) => m['month'] as String)
                              .toList(),
                          incomeValues: currentData
                              .map((m) => (m['income'] as num).toDouble())
                              .toList(),
                          expenseValues: currentData
                              .map((m) => (m['expense'] as num).toDouble())
                              .toList(),
                          selectedIndex: selectedIdx,
                          height: 155,
                        )
                      else if (mainStyle == ChartVisualMode.donut)
                        DonutBreakdownChart(
                          income: activeIncome,
                          expenses: activeExpense,
                          height: 205,
                        )
                      else
                        GroupedDualBarChart(
                          monthlyData: currentData,
                          selectedIndex: selectedIdx,
                          onSelectMonth: (index) {
                            setState(() => _selectedMonthIndex = index);
                          },
                          height: 155,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // Dynamically Pinned Specialized Dashboards from Dashboard Layout Screen
              ..._buildPinnedWidgets(
                context,
                activeIds,
                isDark,
                cardBg,
                borderColor,
                textPrimary,
                textSecondary,
                ref.watch(subTrendChartStyleProvider),
                selectedPeriod,
              ),

              // Quick Actions Grid (4 cards: Exactly matching 1. Financial Analytics Dashboard.png)
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      title: 'Expenses Prediction',
                      subtitle: 'Analysis',
                      cardBg: cardBg,
                      borderColor: const Color(0xFFF43F5E),
                      titleColor: const Color(0xFFF43F5E),
                      textSecondary: textSecondary,
                      icon: Icons.troubleshoot_rounded,
                      iconBgColor: Colors.white,
                      iconColor: const Color(0xFFE11D48),
                      onTap: () {
                        Navigator.of(context)
                            .push(slideRoute(const PredictionAnalysisScreen()));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      title: 'Anomaly Detection',
                      subtitle: 'PDF, XLS',
                      cardBg: cardBg,
                      borderColor: const Color(0xFFF43F5E),
                      titleColor: const Color(0xFFF43F5E),
                      textSecondary: textSecondary,
                      icon: Icons.warning_amber_rounded,
                      iconBgColor: Colors.white,
                      iconColor: const Color(0xFFF97316),
                      onTap: () {
                        Navigator.of(context)
                            .push(slideRoute(const SpendingAnomalyScreen()));
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      title: 'Import Statements',
                      subtitle: 'PDF, XLS',
                      cardBg: cardBg,
                      borderColor: const Color(0xFF38BDF8),
                      titleColor: const Color(0xFF38BDF8),
                      textSecondary: textSecondary,
                      icon: Icons.file_download_outlined,
                      iconBgColor: const Color(0xFF0EA5E9),
                      iconColor: Colors.white,
                      onTap: () {
                        ImportStatementsDialog.show(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      title: 'Export Hub',
                      subtitle: 'PDF, CSV',
                      cardBg: cardBg,
                      borderColor: const Color(0xFF38BDF8),
                      titleColor: const Color(0xFF38BDF8),
                      textSecondary: textSecondary,
                      icon: Icons.file_upload_outlined,
                      iconBgColor: const Color(0xFF2563EB),
                      iconColor: Colors.white,
                      onTap: () {
                        Navigator.of(context)
                            .push(slideRoute(const ReportExportScreen()));
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPinnedWidgets(
    BuildContext context,
    Set<String> activeIds,
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    ChartVisualMode subTrendStyle,
    AnalyticsPeriod selectedPeriod,
  ) {
    final widgets = <Widget>[];
    final labels = AnalyticsPeriodHelper.getLabelsForPeriod(selectedPeriod);
    final lastIndex = (labels.length - 1).clamp(0, 10);

    // Dynamic aggregated totals and values reflecting selected period
    final List<double> incomeTrendValues;
    final String incomeTotalDisplay;
    final List<double> expenseTrendValues;
    final String expenseTotalDisplay;
    final List<double> savingsTrendValues;
    final String savingsTotalDisplay;
    final List<double> anomalyTrendValues;

    switch (selectedPeriod) {
      case AnalyticsPeriod.weekly:
        incomeTrendValues = const [120000, 135000, 130000, 150000];
        incomeTotalDisplay = 'LKR 150,000';
        expenseTrendValues = const [75000, 82000, 78000, 83500];
        expenseTotalDisplay = 'LKR 83,500';
        savingsTrendValues = const [5000, 6000, 4000, 5000];
        savingsTotalDisplay = 'LKR 5,000';
        anomalyTrendValues = const [130000, 145000, 138000, 200000];
        break;
      case AnalyticsPeriod.yearly:
        incomeTrendValues = const [
          4800000,
          5200000,
          5800000,
          6100000,
          6300000,
          6420000,
        ];
        incomeTotalDisplay = 'LKR 6,420,000';
        expenseTrendValues = const [
          3200000,
          3500000,
          3700000,
          3900000,
          3800000,
          3822000,
        ];
        expenseTotalDisplay = 'LKR 3,822,000';
        savingsTrendValues = const [
          200000,
          240000,
          280000,
          300000,
          320000,
          350000,
        ];
        savingsTotalDisplay = 'LKR 350,000';
        anomalyTrendValues = const [
          900000,
          1050000,
          1200000,
          1400000,
          1650000,
          2000000,
        ];
        break;
      case AnalyticsPeriod.monthly:
      default:
        incomeTrendValues = const [65000, 70000, 72000, 90000, 83000, 155000];
        incomeTotalDisplay = 'LKR 535,000';
        expenseTrendValues = const [54000, 68500, 38000, 46000, 62000, 50000];
        expenseTotalDisplay = 'LKR 318,500';
        savingsTrendValues = const [
          250000,
          320000,
          380000,
          440000,
          480000,
          580000,
        ];
        savingsTotalDisplay = 'LKR 2,450,000';
        anomalyTrendValues = const [
          120000,
          125000,
          124000,
          145000,
          138000,
          200000,
        ];
        break;
    }

    // 1. Income Analytics Specialized Dashboard Card
    if (activeIds.contains('avail_inc_analytics')) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: GestureDetector(
            onTap: () =>
                Navigator.of(context)
                    .push(slideRoute(const IncomeAnalyticsScreen())),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF152512) : cardBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFF98E836), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'INCOME ANALYTICS • TOTAL',
                        style: TextStyle(
                          color: Color(0xFF98E836),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Icon(
                        Icons.open_in_new_rounded,
                        color: const Color(0xFF98E836).withValues(alpha: 0.8),
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    incomeTotalDisplay,
                    style: const TextStyle(
                      color: Color(0xFF98E836),
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  AdaptiveTrendChart(
                    mode: subTrendStyle,
                    labels: labels,
                    values: incomeTrendValues,
                    color: const Color(0xFF98E836),
                    selectedIndex: lastIndex,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 2. Expenses Analytics Specialized Dashboard Card
    if (activeIds.contains('avail_exp_analytics')) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: GestureDetector(
            onTap: () =>
                Navigator.of(context)
                    .push(slideRoute(const ExpenseAnalyticsScreen())),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF281519) : cardBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFFF6464), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'EXPENSE ANALYTICS • TOTAL',
                        style: TextStyle(
                          color: Color(0xFFFF6464),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Icon(
                        Icons.open_in_new_rounded,
                        color: const Color(0xFFFF6464).withValues(alpha: 0.8),
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expenseTotalDisplay,
                    style: const TextStyle(
                      color: Color(0xFFFF6464),
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  AdaptiveTrendChart(
                    mode: subTrendStyle,
                    labels: labels,
                    values: expenseTrendValues,
                    color: const Color(0xFFFF6464),
                    selectedIndex: lastIndex,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 3. Goal Savings Analytics Specialized Dashboard Card
    if (activeIds.contains('avail_goal_analytics')) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: GestureDetector(
            onTap: () =>
                Navigator.of(context)
                    .push(slideRoute(const GoalSavingsAnalyticsScreen())),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF10212B) : cardBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'GOAL SAVINGS ANALYTICS • TOTAL',
                        style: TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Icon(
                        Icons.open_in_new_rounded,
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.8),
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    savingsTotalDisplay,
                    style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  AdaptiveTrendChart(
                    mode: subTrendStyle,
                    labels: labels,
                    values: savingsTrendValues,
                    color: const Color(0xFF38BDF8),
                    selectedIndex: lastIndex,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 4. Income Prediction Analytics Specialized Dashboard Card
    if (activeIds.contains('avail_inc_pred')) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFF98E836).withValues(alpha: 0.6),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Expected Next Month Income',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.circle,
                          color: Color(0xFF38BDF8),
                          size: 8,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Actual',
                          style: TextStyle(color: textSecondary, fontSize: 11),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.circle,
                          color: Color(0xFF98E836),
                          size: 8,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Est.',
                          style: TextStyle(
                            color: Color(0xFF98E836),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'LKR 165,000',
                  style: TextStyle(
                    color: Color(0xFF98E836),
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                const PredictionBarChartWidget(
                  months: ['Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov*'],
                  values: [135000, 142000, 148000, 138000, 155000, 165000],
                  yAxisLabels: ['120K', '145K', '170K'],
                  forecastColor: Color(0xFF98E836),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 5. Expenses Prediction Analytics Specialized Dashboard Card
    if (activeIds.contains('avail_exp_pred')) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: GestureDetector(
            onTap: () =>
                Navigator.of(context)
                    .push(slideRoute(const PredictionAnalysisScreen())),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFFF43F5E).withValues(alpha: 0.6),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Expected Next Month Expense',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            color: Color(0xFF38BDF8),
                            size: 8,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Actual',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.circle,
                            color: Color(0xFFF43F5E),
                            size: 8,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Est.',
                            style: TextStyle(
                              color: Color(0xFFF43F5E),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'LKR 68,000',
                    style: TextStyle(
                      color: Color(0xFFF43F5E),
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const PredictionBarChartWidget(
                    months: ['Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov*'],
                    values: [61000, 64000, 59000, 67000, 65000, 68000],
                    yAxisLabels: ['50K', '60k', '75K'],
                    forecastColor: Color(0xFFF43F5E),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 6. Anomaly Detection Analytics Specialized Dashboard Card
    if (activeIds.contains('avail_anomaly')) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: GestureDetector(
            onTap: () =>
                Navigator.of(context)
                    .push(slideRoute(const SpendingAnomalyScreen())),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF281519) : cardBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFF43F5E), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '2 Anomalies',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF43F5E),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'LKR 30,000 Spike',
                          style: TextStyle(
                            color: Color(0xFF0C0F14),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'LKR 200,000',
                    style: TextStyle(
                      color: Color(0xFFFF5C6C),
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  CurvedTrendLineChart(
                    labels: labels,
                    values: anomalyTrendValues,
                    lineColor: const Color(0xFFF43F5E),
                    selectedIndex: lastIndex,
                    height: 115,
                    valueFormatter: (v) => '',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildPeriodItem(
    AnalyticsPeriod period,
    String label,
    AnalyticsPeriod current,
    Color accentColor,
    Color textSecondary,
  ) {
    final isSelected = current == period;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref
              .read(
                analyticsScreenPeriodProvider(AnalyticsScreenType.financial)
                    .notifier,
              )
              .setPeriod(period);
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? accentColor : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF0C0F14) : textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String amount,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: textColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'LKR',
              style: TextStyle(
                color: textColor.withValues(alpha: 0.8),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Breakdown',
              style: TextStyle(
                color: textColor.withValues(alpha: 0.8),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required Color cardBg,
    required Color borderColor,
    required Color titleColor,
    required Color textSecondary,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Icon(icon, color: iconColor, size: 20)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
