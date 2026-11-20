import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../goals/providers/goals_provider.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../services/analytics_period_helper.dart';
import '../widgets/analytics_chart_widgets.dart';

class GoalSavingsAnalyticsScreen extends ConsumerStatefulWidget {
  const GoalSavingsAnalyticsScreen({super.key});

  @override
  ConsumerState<GoalSavingsAnalyticsScreen> createState() =>
      _GoalSavingsAnalyticsScreenState();
}

class _GoalSavingsAnalyticsScreenState
    extends ConsumerState<GoalSavingsAnalyticsScreen> {
  String? _selectedGoalId;

  void _showPeriodPicker(BuildContext context, AnalyticsPeriod currentPeriod) {
    final accentColor = ref.read(accentColorProvider).color;
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
          children:
              [
                (AnalyticsPeriod.weekly, 'Weekly : 2026'),
                (AnalyticsPeriod.monthly, 'Monthly : 2026'),
                (AnalyticsPeriod.yearly, 'Yearly : 2026'),
              ].map((item) {
                final period = item.$1;
                final label = item.$2;
                final isSel = currentPeriod == period;
                return ListTile(
                  title: Text(
                    label,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 14,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  trailing: isSel
                      ? Icon(Icons.check, color: accentColor)
                      : null,
                  onTap: () {
                    ref
                        .read(
                          analyticsScreenPeriodProvider(
                            AnalyticsScreenType.goalSavings,
                          ).notifier,
                        )
                        .setPeriod(period);
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
    final accentColor = ref.watch(accentColorProvider).color;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = AppColors.getBg(isDark);
    final cardBg = AppColors.getCard(isDark);
    final borderColor = AppColors.getBorder(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final textSecondary = AppColors.getTextSecondary(isDark);
    final subContainer = AppColors.getSubContainer(isDark);

    final trendStyle = ref.watch(subTrendChartStyleProvider);
    final categoryStyle = ref.watch(subCategoryChartStyleProvider);
    final selectedPeriod = ref.watch(
      analyticsScreenPeriodProvider(AnalyticsScreenType.goalSavings),
    );

    final periodLabel = AnalyticsPeriodHelper.getPeriodTypeLabel(
      selectedPeriod,
    );
    final labels = AnalyticsPeriodHelper.getLabelsForPeriod(selectedPeriod);
    final lastIndex = (labels.length - 1).clamp(0, 10);

    final String totalAmountDisplay;
    final List<double> totalTrend;
    final Map<String, Map<String, dynamic>> goalsData;
    final String vehicleTargetDisplay;
    final String vacationTargetDisplay;
    final String techTargetDisplay;

    switch (selectedPeriod) {
      case AnalyticsPeriod.weekly:
        totalAmountDisplay = 'LKR 48,000';
        totalTrend = const [35000, 42000, 38000, 48000];
        vehicleTargetDisplay = 'LKR 14K / 50K';
        vacationTargetDisplay = 'LKR 6K / 10K';
        techTargetDisplay = 'LKR 4K / 5K';
        goalsData = {
          'Emergency Fund': {
            'title': 'Emergency Fund (Weekly Contribution)',
            'target': '/ 30,000',
            'total': 'LKR 28,000',
            'progress': 0.933,
            'values': const [20000.0, 25000.0, 22000.0, 28000.0],
            'barColor': const Color(0xFF38BDF8),
            'activeOctColor': const Color(0xFF98E836),
          },
          'Vehicle': {
            'title': 'Vehicle Upgrade (Weekly Contribution)',
            'target': '/ 50,000',
            'total': 'LKR 14,000',
            'progress': 0.28,
            'values': const [10000.0, 12000.0, 11000.0, 14000.0],
            'barColor': const Color(0xFF38BDF8),
            'activeOctColor': const Color(0xFF98E836),
          },
          'Vacation': {
            'title': 'Vacation (Weekly Contribution)',
            'target': '/ 10,000',
            'total': 'LKR 6,000',
            'progress': 0.60,
            'values': const [5000.0, 5000.0, 5000.0, 6000.0],
            'barColor': const Color(0xFFF59E0B),
            'activeOctColor': const Color(0xFF98E836),
          },
          'All (4)': {
            'title': 'All Weekly Contributions Combined',
            'target': '/ 90,000',
            'total': 'LKR 48,000',
            'progress': 0.53,
            'values': const [35000.0, 42000.0, 38000.0, 48000.0],
            'barColor': const Color(0xFF38BDF8),
            'activeOctColor': const Color(0xFF98E836),
          },
        };
        break;
      case AnalyticsPeriod.yearly:
        totalAmountDisplay = 'LKR 2,450,000';
        totalTrend = const [
          900000,
          1200000,
          1500000,
          1800000,
          2100000,
          2450000,
        ];
        vehicleTargetDisplay = 'LKR 700K / 2.5M';
        vacationTargetDisplay = 'LKR 200K / 250K';
        techTargetDisplay = 'LKR 100K / 150K';
        goalsData = {
          'Emergency Fund': {
            'title': 'Emergency Fund (6 Months Cushion)',
            'target': '/ 1,500,000',
            'total': 'LKR 1,450,000',
            'progress': 0.967,
            'values': const [
              500000.0,
              700000.0,
              900000.0,
              1100000.0,
              1300000.0,
              1450000.0,
            ],
            'barColor': const Color(0xFF38BDF8),
            'activeOctColor': const Color(0xFF98E836),
          },
          'Vehicle': {
            'title': 'Vehicle Upgrade (Hybrid/EV)',
            'target': '/ 2,500,000',
            'total': 'LKR 700,000',
            'progress': 0.28,
            'values': const [
              250000.0,
              320000.0,
              400000.0,
              500000.0,
              600000.0,
              700000.0,
            ],
            'barColor': const Color(0xFF38BDF8),
            'activeOctColor': const Color(0xFF98E836),
          },
          'Vacation': {
            'title': 'Vacation (Ella & Mirissa)',
            'target': '/ 250,000',
            'total': 'LKR 200,000',
            'progress': 0.80,
            'values': const [
              150000.0,
              180000.0,
              200000.0,
              200000.0,
              200000.0,
              200000.0,
            ],
            'barColor': const Color(0xFFF59E0B),
            'activeOctColor': const Color(0xFF98E836),
          },
          'All (4)': {
            'title': 'All Savings Goals Combined',
            'target': '/ 4,400,000',
            'total': 'LKR 2,450,000',
            'progress': 0.56,
            'values': const [
              900000.0,
              1200000.0,
              1500000.0,
              1800000.0,
              2100000.0,
              2450000.0,
            ],
            'barColor': const Color(0xFF38BDF8),
            'activeOctColor': const Color(0xFF98E836),
          },
        };
        break;
      case AnalyticsPeriod.monthly:
      default:
        totalAmountDisplay = 'LKR 2,450,000';
        totalTrend = const [250000, 320000, 380000, 440000, 480000, 580000];
        vehicleTargetDisplay = 'LKR 700K / 2.5M';
        vacationTargetDisplay = 'LKR 200K / 250K';
        techTargetDisplay = 'LKR 100K / 150K';
        goalsData = {
          'Emergency Fund': {
            'title': 'Emergency Fund (6 Months Cushion)',
            'target': '/ 1,500,000',
            'total': 'LKR 1,450,000',
            'progress': 0.967,
            'values': const [
              170000.0,
              200000.0,
              230000.0,
              250000.0,
              260000.0,
              340000.0,
            ],
            'barColor': const Color(0xFF38BDF8),
            'activeOctColor': const Color(0xFF98E836),
          },
          'Vehicle': {
            'title': 'Vehicle Upgrade (Hybrid/EV)',
            'target': '/ 2,500,000',
            'total': 'LKR 700,000',
            'progress': 0.28,
            'values': const [
              80000.0,
              95000.0,
              110000.0,
              120000.0,
              140000.0,
              155000.0,
            ],
            'barColor': const Color(0xFF38BDF8),
            'activeOctColor': const Color(0xFF98E836),
          },
          'Vacation': {
            'title': 'Vacation (Ella & Mirissa)',
            'target': '/ 250,000',
            'total': 'LKR 200,000',
            'progress': 0.80,
            'values': const [
              20000.0,
              25000.0,
              30000.0,
              35000.0,
              40000.0,
              50000.0,
            ],
            'barColor': const Color(0xFFF59E0B),
            'activeOctColor': const Color(0xFF98E836),
          },
          'All (4)': {
            'title': 'All Savings Goals Combined',
            'target': '/ 4,400,000',
            'total': 'LKR 2,450,000',
            'progress': 0.56,
            'values': const [
              250000.0,
              320000.0,
              380000.0,
              440000.0,
              480000.0,
              580000.0,
            ],
            'barColor': const Color(0xFF38BDF8),
            'activeOctColor': const Color(0xFF98E836),
          },
        };
        break;
    }

    final goals = ref.watch(goalsProvider).goals;

    // Auto-select first goal if none selected, or if selected was deleted
    if (goals.isNotEmpty) {
      if (_selectedGoalId == null ||
          !goals.any((g) => g.id == _selectedGoalId)) {
        _selectedGoalId = goals.first.id;
      }
    } else {
      _selectedGoalId = null;
    }

    final selectedGoal = goals.isNotEmpty
        ? goals.firstWhere(
            (g) => g.id == _selectedGoalId,
            orElse: () => goals.first,
          )
        : null;

    final Map<String, dynamic> currentGoal;
    if (selectedGoal == null) {
      currentGoal = {
        'title': 'No Savings Goals Available',
        'target': '/ 0',
        'total': 'LKR 0',
        'progress': 0.0,
        'values': List.filled(labels.length, 0.0),
        'barColor': accentColor,
        'hasData': false,
      };
    } else if (selectedGoal.id == 'emergency_fund' ||
        selectedGoal.title.toLowerCase().contains('emergency')) {
      currentGoal = goalsData['Emergency Fund']!;
    } else if (selectedGoal.id == 'vehicle_upgrade' ||
        selectedGoal.title.toLowerCase().contains('vehicle')) {
      currentGoal = goalsData['Vehicle']!;
    } else if (selectedGoal.id == 'vacation_fund' ||
        selectedGoal.title.toLowerCase().contains('vacation')) {
      currentGoal = goalsData['Vacation']!;
    } else {
      currentGoal = {
        'title': selectedGoal.title,
        'target': '/ ${selectedGoal.targetAmount.toInt()}',
        'total': 'LKR ${selectedGoal.currentAmount.toInt()}',
        'progress': selectedGoal.progress,
        'values': List.filled(labels.length, 0.0),
        'barColor': selectedGoal.color,
        'hasData': false,
      };
    }

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
                      const SizedBox(width: 12),
                      Text(
                        'Goal Savings',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _showPeriodPicker(context, selectedPeriod),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor,
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

              // Total Goals Saved Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F2532) : cardBg,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFF38BDF8),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL',
                      style: TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      totalAmountDisplay,
                      style: const TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AdaptiveTrendChart(
                      mode: trendStyle,
                      labels: labels,
                      values: totalTrend,
                      color: const Color(0xFF38BDF8),
                      selectedIndex: lastIndex,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Filter Chips
              if (goals.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Center(
                    child: Text(
                      'No savings goals available',
                      style: TextStyle(color: textSecondary, fontSize: 13),
                    ),
                  ),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: goals.map((goal) {
                      final isSel = _selectedGoalId == goal.id;
                      final chipFg = isSel
                          ? (accentColor.computeLuminance() > 0.5
                                ? const Color(0xFF0C0F14)
                                : Colors.white)
                          : textSecondary;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedGoalId = goal.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: isSel ? accentColor : cardBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSel ? accentColor : borderColor,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: BoxDecoration(
                                    color: goal.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Text(
                                  goal.title,
                                  style: TextStyle(
                                    color: chipFg,
                                    fontSize: 13,
                                    fontWeight: isSel
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                                if (isSel) ...[
                                  const SizedBox(width: 4),
                                  Icon(Icons.check, color: chipFg, size: 14),
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

              // Selected Goal Card
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
                      currentGoal['title'] as String,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          currentGoal['total'] as String,
                          style: const TextStyle(
                            color: Color(0xFF98E836),
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          currentGoal['target'] as String,
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    if (currentGoal['hasData'] == false) ...[
                      const SizedBox(height: 6),
                      Text(
                        'No contribution history recorded yet for this goal',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
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
                      months: labels,
                      values: currentGoal['values'] as List<double>,
                      barColor: currentGoal['barColor'] as Color,
                      alternateBarColor:
                          currentGoal['activeOctColor'] as Color?,
                      selectedIndex: lastIndex,
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
                    if (goals.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'No savings targets available.',
                          style: TextStyle(color: textSecondary, fontSize: 13),
                        ),
                      )
                    else
                      ...goals.map((goal) {
                        String amt;
                        if (goal.id == 'vehicle_upgrade' ||
                            goal.title.toLowerCase().contains('vehicle')) {
                          amt = vehicleTargetDisplay;
                        } else if (goal.id == 'vacation_fund' ||
                            goal.title.toLowerCase().contains('vacation')) {
                          amt = vacationTargetDisplay;
                        } else if (goal.id == 'emergency_fund' ||
                            goal.title.toLowerCase().contains('emergency')) {
                          amt =
                              'LKR ${(goal.currentAmount / 1000).toInt()}K / ${(goal.targetAmount / 1000).toInt()}K';
                        } else {
                          amt =
                              'LKR ${(goal.currentAmount / 1000).toInt()}K / ${(goal.targetAmount / 1000).toInt()}K';
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildTargetRow(
                            dotColor: goal.color,
                            name: goal.title,
                            amount: amt,
                            amountColor: goal.color,
                            textColor: textPrimary,
                          ),
                        );
                      }),
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
