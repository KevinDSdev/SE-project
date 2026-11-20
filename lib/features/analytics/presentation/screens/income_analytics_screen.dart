import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../services/analytics_period_helper.dart';
import '../widgets/analytics_chart_widgets.dart';

class IncomeAnalyticsScreen extends ConsumerStatefulWidget {
  const IncomeAnalyticsScreen({super.key});

  @override
  ConsumerState<IncomeAnalyticsScreen> createState() =>
      _IncomeAnalyticsScreenState();
}

class _IncomeAnalyticsScreenState extends ConsumerState<IncomeAnalyticsScreen> {
  String _selectedFilter = 'Primary Salary';

  final List<String> _filters = [
    'All (3)',
    'Primary Salary',
    'Rent Inflow',
    'Freelance',
  ];

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
                    ref.read(selectedPeriodProvider.notifier).setPeriod(period);
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

    final trendStyle = ref.watch(subTrendChartStyleProvider);
    final categoryStyle = ref.watch(subCategoryChartStyleProvider);
    final selectedPeriod = ref.watch(selectedPeriodProvider);

    final periodLabel = AnalyticsPeriodHelper.getPeriodTypeLabel(
      selectedPeriod,
    );
    final labels = AnalyticsPeriodHelper.getLabelsForPeriod(selectedPeriod);
    final lastIndex = (labels.length - 1).clamp(0, 10);

    final String totalAmountDisplay;
    final List<double> totalTrend;
    final Map<String, Map<String, dynamic>> streamData;
    final String primarySalaryStreamAmount;
    final String rentStreamAmount;
    final String freelanceStreamAmount;

    switch (selectedPeriod) {
      case AnalyticsPeriod.weekly:
        totalAmountDisplay = 'LKR 150,000';
        totalTrend = const [120000, 135000, 130000, 150000];
        primarySalaryStreamAmount = 'LKR 125,000';
        rentStreamAmount = 'LKR 15,000';
        freelanceStreamAmount = 'LKR 10,000';
        streamData = {
          'Primary Salary': {
            'title': 'Primary Salary',
            'total': 'LKR 125,000',
            'values': const [100000.0, 110000.0, 105000.0, 125000.0],
            'color': const Color(0xFF98E836),
          },
          'Rent Inflow': {
            'title': 'Kandy Annex Rent Inflow',
            'total': 'LKR 15,000',
            'values': const [13750.0, 13750.0, 13750.0, 15000.0],
            'color': const Color(0xFF38BDF8),
          },
          'Freelance': {
            'title': 'Freelance Income',
            'total': 'LKR 10,000',
            'values': const [6250.0, 11250.0, 11250.0, 10000.0],
            'color': const Color(0xFF9353D3),
          },
          'All (3)': {
            'title': 'Combined Income Streams',
            'total': 'LKR 150,000',
            'values': const [120000.0, 135000.0, 130000.0, 150000.0],
            'color': const Color(0xFF98E836),
          },
        };
        break;
      case AnalyticsPeriod.yearly:
        totalAmountDisplay = 'LKR 6,420,000';
        totalTrend = const [
          4800000,
          5200000,
          5800000,
          6100000,
          6300000,
          6420000,
        ];
        primarySalaryStreamAmount = 'LKR 5,400,000';
        rentStreamAmount = 'LKR 660,000';
        freelanceStreamAmount = 'LKR 360,000';
        streamData = {
          'Primary Salary': {
            'title': 'Primary Salary',
            'total': 'LKR 5,400,000',
            'values': const [
              4000000.0,
              4400000.0,
              4900000.0,
              5100000.0,
              5300000.0,
              5400000.0,
            ],
            'color': const Color(0xFF98E836),
          },
          'Rent Inflow': {
            'title': 'Kandy Annex Rent Inflow',
            'total': 'LKR 660,000',
            'values': const [
              500000.0,
              520000.0,
              550000.0,
              600000.0,
              640000.0,
              660000.0,
            ],
            'color': const Color(0xFF38BDF8),
          },
          'Freelance': {
            'title': 'Freelance Income',
            'total': 'LKR 360,000',
            'values': const [
              300000.0,
              280000.0,
              350000.0,
              400000.0,
              360000.0,
              360000.0,
            ],
            'color': const Color(0xFF9353D3),
          },
          'All (3)': {
            'title': 'Combined Income Streams',
            'total': 'LKR 6,420,000',
            'values': const [
              4800000.0,
              5200000.0,
              5800000.0,
              6100000.0,
              6300000.0,
              6420000.0,
            ],
            'color': const Color(0xFF98E836),
          },
        };
        break;
      case AnalyticsPeriod.monthly:
      default:
        totalAmountDisplay = 'LKR 535,000';
        totalTrend = const [65000, 70000, 72000, 90000, 83000, 155000];
        primarySalaryStreamAmount = 'LKR 450,000';
        rentStreamAmount = 'LKR 55,000';
        freelanceStreamAmount = 'LKR 30,000';
        streamData = {
          'Primary Salary': {
            'title': 'Primary Salary',
            'total': 'LKR 450,000',
            'values': const [
              70000.0,
              70000.0,
              80000.0,
              70000.0,
              70000.0,
              90000.0,
            ],
            'color': const Color(0xFF98E836),
          },
          'Rent Inflow': {
            'title': 'Kandy Annex Rent Inflow',
            'total': 'LKR 55,000',
            'values': const [
              55000.0,
              55000.0,
              55000.0,
              55000.0,
              55000.0,
              55000.0,
            ],
            'color': const Color(0xFF38BDF8),
          },
          'Freelance': {
            'title': 'Freelance Income',
            'total': 'LKR 30,000',
            'values': const [
              20000.0,
              35000.0,
              15000.0,
              40000.0,
              25000.0,
              30000.0,
            ],
            'color': const Color(0xFF9353D3),
          },
          'All (3)': {
            'title': 'Combined Income Streams',
            'total': 'LKR 535,000',
            'values': const [
              145000.0,
              160000.0,
              150000.0,
              165000.0,
              150000.0,
              175000.0,
            ],
            'color': const Color(0xFF98E836),
          },
        };
        break;
    }

    final currentStream =
        streamData[_selectedFilter] ?? streamData['Primary Salary']!;

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
                        'Income Analytics',
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

              // Total Income Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF152512) : cardBg,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFF98E836),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL',
                      style: TextStyle(
                        color: Color(0xFF98E836),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      totalAmountDisplay,
                      style: const TextStyle(
                        color: Color(0xFF98E836),
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AdaptiveTrendChart(
                      mode: trendStyle,
                      labels: labels,
                      values: totalTrend,
                      color: const Color(0xFF98E836),
                      selectedIndex: lastIndex,
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
                            color: isSel ? const Color(0xFF98E836) : cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSel
                                  ? const Color(0xFF98E836)
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
                                  fontWeight: isSel
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                              if (isSel && filter != 'All (3)') ...[
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

              // Selected Category Card
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
                      currentStream['title'] as String,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentStream['total'] as String,
                      style: TextStyle(
                        color: currentStream['color'] as Color,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AdaptiveCategoryChart(
                      mode: categoryStyle,
                      months: labels,
                      values: currentStream['values'] as List<double>,
                      barColor: currentStream['color'] as Color,
                      selectedIndex: lastIndex,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // All Income Streams
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
                      'All Income Streams',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStreamRow(
                      dotColor: const Color(0xFF98E836),
                      name: 'Primary Salary',
                      amount: primarySalaryStreamAmount,
                      amountColor: const Color(0xFF98E836),
                      textColor: textPrimary,
                    ),
                    const SizedBox(height: 12),
                    _buildStreamRow(
                      dotColor: const Color(0xFF38BDF8),
                      name: 'Kandy Annex Rent',
                      amount: rentStreamAmount,
                      amountColor: const Color(0xFF38BDF8),
                      textColor: textPrimary,
                    ),
                    const SizedBox(height: 12),
                    _buildStreamRow(
                      dotColor: const Color(0xFF9353D3),
                      name: 'Freelance Income',
                      amount: freelanceStreamAmount,
                      amountColor: const Color(0xFFA855F7),
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

  Widget _buildStreamRow({
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
