import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/slide_route.dart';
import '../../../core/providers/navigation_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/analytics_provider.dart';
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
  int _selectedMonthIndex = 5; // Default Oct (index 5)
  final NumberFormat _currencyFormat = NumberFormat('#,###');

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
      'expense': 295000.0,
      'savings': 18000.0,
    },
    {
      'month': 'Jul',
      'income': 470000.0,
      'expense': 260000.0,
      'savings': 14000.0,
    },
    {
      'month': 'Aug',
      'income': 510000.0,
      'expense': 290000.0,
      'savings': 22000.0,
    },
    {
      'month': 'Sep',
      'income': 490000.0,
      'expense': 305000.0,
      'savings': 19000.0,
    },
    {
      'month': 'Oct',
      'income': 535000.0,
      'expense': 318500.0,
      'savings': 20000.0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final selectedPeriod = ref.watch(selectedPeriodProvider);
    final mainStyle = ref.watch(mainChartStyleProvider);
    final accentColor = ref.watch(accentColorProvider).color;
    final widgetsState = ref.watch(dashboardWidgetsProvider);
    final activeIds = widgetsState.activeWidgets.map((w) => w.id).toSet();

    final activeMonth = _monthlyData[_selectedMonthIndex];

    // Dynamic adjustment based on selected period
    double activeIncome = activeMonth['income'] as double;
    double activeExpense = activeMonth['expense'] as double;
    double activeSavings = (activeMonth['savings'] as double?) ?? 20000.0;

    if (selectedPeriod == AnalyticsPeriod.weekly) {
      activeIncome = (activeIncome / 4).roundToDouble();
      activeExpense = (activeExpense / 4).roundToDouble();
      activeSavings = (activeSavings / 4).roundToDouble();
    } else if (selectedPeriod == AnalyticsPeriod.yearly) {
      activeIncome = activeIncome * 12;
      activeExpense = activeExpense * 12;
      activeSavings = activeSavings * 12;
    }

    final showIncome = activeIds.contains('active_income');
    final showExpense = activeIds.contains('active_expenses');
    final showSavings = activeIds.contains('active_savings');
    final showTrend = activeIds.contains('active_trend');

    final hasAnySummary = showIncome || showExpense || showSavings;

    return Scaffold(
      backgroundColor: AppColors.lightBg,
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
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.lightBorder),
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: AppColors.lightTextPrimary,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Financial Analytics',
                    style: TextStyle(
                      color: AppColors.lightTextPrimary,
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    _buildPeriodItem(
                      AnalyticsPeriod.weekly,
                      'Weekly',
                      selectedPeriod,
                      accentColor,
                    ),
                    _buildPeriodItem(
                      AnalyticsPeriod.monthly,
                      'Monthly',
                      selectedPeriod,
                      accentColor,
                    ),
                    _buildPeriodItem(
                      AnalyticsPeriod.yearly,
                      'Yearly',
                      selectedPeriod,
                      accentColor,
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
                            Navigator.of(context).push(
                              slideRoute(const IncomeAnalyticsScreen()),
                            );
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
                          textColor: Colors.white,
                          onTap: () {
                            Navigator.of(context).push(
                              slideRoute(const ExpenseAnalyticsScreen()),
                            );
                          },
                        ),
                      ),
                    if (showExpense && showSavings)
                      const SizedBox(width: 10),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Income vs Expenses (May – Oct)',
                            style: TextStyle(
                              color: AppColors.lightTextPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Row(
                            children: const [
                              Icon(Icons.circle,
                                  color: Color(0xFF98E836), size: 8),
                              SizedBox(width: 4),
                              Text(
                                'In',
                                style: TextStyle(
                                  color: AppColors.lightTextSecondary,
                                  fontSize: 11,
                                ),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.circle,
                                  color: Color(0xFFF43F5E), size: 8),
                              SizedBox(width: 4),
                              Text(
                                'Ex',
                                style: TextStyle(
                                  color: AppColors.lightTextSecondary,
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
                          labels: _monthlyData
                              .map((m) => m['month'] as String)
                              .toList(),
                          incomeValues: _monthlyData
                              .map((m) => (m['income'] as num).toDouble())
                              .toList(),
                          expenseValues: _monthlyData
                              .map((m) => (m['expense'] as num).toDouble())
                              .toList(),
                          selectedIndex: _selectedMonthIndex,
                          height: 155,
                        )
                      else if (mainStyle == ChartVisualMode.donut)
                        DonutBreakdownChart(
                          income: activeIncome,
                          expenses: activeExpense,
                          height: 155,
                        )
                      else
                        GroupedDualBarChart(
                          monthlyData: _monthlyData,
                          selectedIndex: _selectedMonthIndex,
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

              // Dynamically Pinned Extra Widgets from Dashboard Widgets Screen
              ..._buildPinnedWidgets(context, activeIds),

              // Quick Actions Grid (5 cards: Transaction History removed)
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      title: 'Income Prediction',
                      subtitle: 'Analysis',
                      borderColor: const Color(0xFF98E836),
                      titleColor: const Color(0xFF65A30D),
                      icon: Icons.trending_up_rounded,
                      iconBgColor: const Color(0xFF98E836).withValues(alpha: 0.15),
                      iconColor: const Color(0xFF65A30D),
                      onTap: () {
                        Navigator.of(context).push(
                          slideRoute(const PredictionAnalysisScreen(
                            initialMode: PredictionMode.income,
                          )),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      title: 'Expenses Prediction',
                      subtitle: 'Analysis',
                      borderColor: const Color(0xFFF43F5E),
                      titleColor: const Color(0xFFE11D48),
                      icon: Icons.query_stats_rounded,
                      iconBgColor: const Color(0xFFF43F5E).withValues(alpha: 0.15),
                      iconColor: const Color(0xFFE11D48),
                      onTap: () {
                        Navigator.of(context).push(
                          slideRoute(const PredictionAnalysisScreen(
                            initialMode: PredictionMode.expenses,
                          )),
                        );
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
                      borderColor: const Color(0xFF38BDF8),
                      titleColor: const Color(0xFF0284C7),
                      icon: Icons.file_download_outlined,
                      iconBgColor: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                      iconColor: const Color(0xFF0284C7),
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
                      borderColor: const Color(0xFF38BDF8),
                      titleColor: const Color(0xFF0284C7),
                      icon: Icons.file_upload_outlined,
                      iconBgColor: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                      iconColor: const Color(0xFF0284C7),
                      onTap: () {
                        Navigator.of(context).push(
                          slideRoute(const ReportExportScreen()),
                        );
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
                      title: 'Anomaly Detection',
                      subtitle: 'PDF, XLS',
                      borderColor: const Color(0xFFF43F5E),
                      titleColor: const Color(0xFFE11D48),
                      icon: Icons.warning_amber_rounded,
                      iconBgColor: const Color(0xFFF43F5E).withValues(alpha: 0.15),
                      iconColor: const Color(0xFFE11D48),
                      onTap: () {
                        Navigator.of(context).push(
                          slideRoute(const SpendingAnomalyScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: SizedBox()),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPinnedWidgets(BuildContext context, Set<String> activeIds) {
    final widgets = <Widget>[];

    if (activeIds.contains('avail_inc_pred')) {
      widgets.add(_buildPinnedCard(
        context,
        title: 'Income Prediction Analytics',
        subtitle: 'Projected next month: LKR 540,000 (High 92%)',
        color: const Color(0xFF98E836),
        icon: Icons.insights_rounded,
        onTap: () => Navigator.of(context).push(
          slideRoute(const PredictionAnalysisScreen(initialMode: PredictionMode.income)),
        ),
      ));
    }

    if (activeIds.contains('avail_exp_pred')) {
      widgets.add(_buildPinnedCard(
        context,
        title: 'Expenses Prediction Analytics',
        subtitle: 'Projected next month: LKR 330,000 (High 88%)',
        color: const Color(0xFFF43F5E),
        icon: Icons.query_stats_rounded,
        onTap: () => Navigator.of(context).push(
          slideRoute(const PredictionAnalysisScreen(initialMode: PredictionMode.expenses)),
        ),
      ));
    }

    if (activeIds.contains('avail_anomaly')) {
      widgets.add(_buildPinnedCard(
        context,
        title: 'Anomaly Detection Analytics',
        subtitle: '1 unusual spending spike flagged in Oct',
        color: const Color(0xFFF59E0B),
        icon: Icons.warning_amber_rounded,
        onTap: () => Navigator.of(context).push(
          slideRoute(const SpendingAnomalyScreen()),
        ),
      ));
    }

    if (activeIds.contains('avail_inc_analytics')) {
      widgets.add(_buildPinnedCard(
        context,
        title: 'Income Analytics Details',
        subtitle: 'Primary Salary, Rent Inflow, Freelance',
        color: const Color(0xFF98E836),
        icon: Icons.pie_chart_outline_rounded,
        onTap: () => Navigator.of(context).push(
          slideRoute(const IncomeAnalyticsScreen()),
        ),
      ));
    }

    if (activeIds.contains('avail_exp_analytics')) {
      widgets.add(_buildPinnedCard(
        context,
        title: 'Expenses Analytics Details',
        subtitle: 'Food & Groceries, Transport, Utilities',
        color: const Color(0xFFF43F5E),
        icon: Icons.analytics_outlined,
        onTap: () => Navigator.of(context).push(
          slideRoute(const ExpenseAnalyticsScreen()),
        ),
      ));
    }

    if (activeIds.contains('avail_goal_analytics')) {
      widgets.add(_buildPinnedCard(
        context,
        title: 'Goal Savings Analytics Details',
        subtitle: 'Emergency Fund, Vehicle, Vacation',
        color: const Color(0xFF38BDF8),
        icon: Icons.track_changes_rounded,
        onTap: () => Navigator.of(context).push(
          slideRoute(const GoalSavingsAnalyticsScreen()),
        ),
      ));
    }

    return widgets;
  }

  Widget _buildPinnedCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.lightBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.lightTextPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.lightTextSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.lightTextSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodItem(
    AnalyticsPeriod period,
    String label,
    AnalyticsPeriod current,
    Color accentColor,
  ) {
    final isSelected = current == period;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(selectedPeriodProvider.notifier).setPeriod(period);
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
                color: isSelected
                    ? const Color(0xFF0C0F14)
                    : AppColors.lightTextSecondary,
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
    required Color borderColor,
    required Color titleColor,
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
          color: Colors.white,
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
              child: Center(
                child: Icon(icon, color: iconColor, size: 20),
              ),
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
                    style: const TextStyle(
                      color: AppColors.lightTextSecondary,
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
