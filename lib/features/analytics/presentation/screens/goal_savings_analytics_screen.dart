import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../providers/analytics_provider.dart';
import '../widgets/analytics_chart_widgets.dart';

class GoalSavingsAnalyticsScreen extends ConsumerStatefulWidget {
  const GoalSavingsAnalyticsScreen({super.key});

  @override
  ConsumerState<GoalSavingsAnalyticsScreen> createState() =>
      _GoalSavingsAnalyticsScreenState();
}

class _GoalSavingsAnalyticsScreenState
    extends ConsumerState<GoalSavingsAnalyticsScreen> {
  String _selectedFilter = 'Emergency Fund';
  String? _customPeriodLabel;

  final List<String> _filters = [
    'All (4)',
    'Emergency Fund',
    'Vehicle',
    'Vacation',
  ];

  final List<String> _months = ['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'];
  final List<double> _totalTrend = [15000, 18000, 14000, 22000, 19000, 20000];

  final Map<String, Map<String, dynamic>> _goalsData = {
    'Emergency Fund': {
      'title': 'Emergency Fund (6-Months Cushion)',
      'target': 'Target : LKR 100,000',
      'total': 'LKR 45,000',
      'progress': 0.45,
      'values': [25000.0, 30000.0, 32000.0, 38000.0, 40000.0, 45000.0],
      'barColor': const Color(0xFF38BDF8),
      'activeOctColor': const Color(0xFF98E836),
    },
    'Vehicle': {
      'title': 'Vehicle Upgrade Fund',
      'target': 'Target : LKR 250,000',
      'total': 'LKR 80,000',
      'progress': 0.32,
      'values': [40000.0, 45000.0, 55000.0, 60000.0, 70000.0, 80000.0],
      'barColor': const Color(0xFF38BDF8),
      'activeOctColor': const Color(0xFF38BDF8),
    },
    'Vacation': {
      'title': 'Ella Weekend Vacation',
      'target': 'Target : LKR 50,000',
      'total': 'LKR 35,000',
      'progress': 0.70,
      'values': [10000.0, 15000.0, 20000.0, 25000.0, 30000.0, 35000.0],
      'barColor': const Color(0xFFF59E0B),
      'activeOctColor': const Color(0xFFF59E0B),
    },
    'All (4)': {
      'title': 'All Savings Goals Combined',
      'target': 'Total Target : LKR 400,000',
      'total': 'LKR 160,000',
      'progress': 0.40,
      'values': [75000.0, 90000.0, 107000.0, 123000.0, 140000.0, 160000.0],
      'barColor': const Color(0xFF38BDF8),
      'activeOctColor': const Color(0xFF98E836),
    },
  };

  void _showPeriodPicker(BuildContext context, String currentPeriod) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppColors.getCard(isDark);
    final borderColor = AppColors.getBorder(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderColor),
        ),
        title: Text(
          'Select Period',
          style: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'Monthly : 2026',
            'Weekly : 2026',
            'Q3 : 2026',
            'Q2 : 2026',
            'Yearly : 2026',
          ].map((period) {
            return ListTile(
              title: Text(
                period,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 14,
                ),
              ),
              trailing: currentPeriod == period
                  ? const Icon(Icons.check, color: Color(0xFF98E836))
                  : null,
              onTap: () {
                setState(() => _customPeriodLabel = period);
                Navigator.of(ctx).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = AppColors.getBg(isDark);
    final cardBg = AppColors.getCard(isDark);
    final borderColor = AppColors.getBorder(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final textSecondary = AppColors.getTextSecondary(isDark);
    final subContainer = AppColors.getSubContainer(isDark);

    final trendStyle = ref.watch(subTrendChartStyleProvider);
    final categoryStyle = ref.watch(subCategoryChartStyleProvider);
    final defaultPeriod = ref.watch(selectedPeriodProvider);

    final periodLabel = _customPeriodLabel ??
        (defaultPeriod == AnalyticsPeriod.weekly
            ? 'Weekly : 2026'
            : defaultPeriod == AnalyticsPeriod.yearly
                ? 'Yearly : 2026'
                : 'Monthly : 2026');

    final currentGoal =
        _goalsData[_selectedFilter] ?? _goalsData['Emergency Fund']!;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: cardBg,
                            shape: BoxShape.circle,
                            border: Border.all(color: borderColor),
                          ),
                          child: Icon(
                            Icons.chevron_left_rounded,
                            color: textPrimary,
                            size: 26,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Goal Savings Analytics',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _showPeriodPicker(context, periodLabel),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF98E836),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        periodLabel,
                        style: const TextStyle(
                          color: Color(0xFF0C0F14),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Total Savings Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(22),
                  border:
                      Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL',
                      style: TextStyle(
                        color: Color(0xFF0284C7),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'LKR 108,000',
                      style: TextStyle(
                        color: Color(0xFF0284C7),
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AdaptiveTrendChart(
                      mode: trendStyle,
                      labels: _months,
                      values: _totalTrend,
                      color: const Color(0xFF38BDF8),
                      selectedIndex: 5,
                      valueFormatter: (v) => v.toInt().toString(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _filters.map((filter) {
                    final isSel = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFilter = filter),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: isSel
                                ? const Color(0xFF38BDF8)
                                : cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSel
                                  ? const Color(0xFF38BDF8)
                                  : borderColor,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                filter,
                                style: TextStyle(
                                  color: isSel
                                      ? const Color(0xFF0C0F14)
                                      : textSecondary,
                                  fontSize: 13,
                                  fontWeight:
                                      isSel ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                              if (isSel && filter != 'All (4)') ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.check,
                                  color: Color(0xFF0C0F14),
                                  size: 14,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 18),

              // Selected Target Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
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
                        Expanded(
                          child: Text(
                            currentGoal['title'] as String,
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          currentGoal['target'] as String,
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentGoal['total'] as String,
                      style: const TextStyle(
                        color: Color(0xFF0284C7),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (currentGoal['progress'] as num).toDouble(),
                        backgroundColor: subContainer,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF98E836),
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Bar Chart
                    AdaptiveCategoryChart(
                      mode: categoryStyle,
                      months: _months,
                      values: currentGoal['values'] as List<double>,
                      barColor: currentGoal['barColor'] as Color,
                      alternateBarColor:
                          currentGoal['activeOctColor'] as Color?,
                      selectedIndex: 5,
                      valueFormatter: (v) => v.toInt().toString(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Other Active Savings Targets
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Other Active Savings Targets',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTargetRow(
                      dotColor: const Color(0xFF98E836),
                      name: 'Emergency Fund',
                      amount: 'LKR 45,000',
                      amountColor: const Color(0xFF65A30D),
                      textColor: textPrimary,
                    ),
                    const SizedBox(height: 12),
                    _buildTargetRow(
                      dotColor: const Color(0xFF38BDF8),
                      name: 'Vehicle Upgrade',
                      amount: 'LKR 80,000',
                      amountColor: const Color(0xFF0284C7),
                      textColor: textPrimary,
                    ),
                    const SizedBox(height: 12),
                    _buildTargetRow(
                      dotColor: const Color(0xFFF59E0B),
                      name: 'Vacation Trip',
                      amount: 'LKR 35,000',
                      amountColor: const Color(0xFFD97706),
                      textColor: textPrimary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTargetRow({
    required Color dotColor,
    required String name,
    required String amount,
    required Color amountColor,
    required Color textColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              name,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Text(
          amount,
          style: TextStyle(
            color: amountColor,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
