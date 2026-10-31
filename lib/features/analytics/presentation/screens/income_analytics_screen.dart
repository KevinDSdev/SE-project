import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../providers/analytics_provider.dart';
import '../widgets/analytics_chart_widgets.dart';

class IncomeAnalyticsScreen extends ConsumerStatefulWidget {
  const IncomeAnalyticsScreen({super.key});

  @override
  ConsumerState<IncomeAnalyticsScreen> createState() =>
      _IncomeAnalyticsScreenState();
}

class _IncomeAnalyticsScreenState extends ConsumerState<IncomeAnalyticsScreen> {
  String _selectedFilter = 'Primary Salary';
  String? _customPeriodLabel;

  final List<String> _filters = [
    'All (3)',
    'Primary Salary',
    'Rent Inflow',
    'Freelance',
  ];

  // Total income line trend points
  final List<String> _months = ['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'];
  final List<double> _totalTrend = [65000, 70000, 72000, 90000, 83000, 155000];

  // Specific stream data map
  final Map<String, Map<String, dynamic>> _streamData = {
    'Primary Salary': {
      'title': 'Primary Salary',
      'total': 'LKR 450,000',
      'values': [70000.0, 70000.0, 80000.0, 70000.0, 70000.0, 90000.0],
      'color': const Color(0xFF98E836),
    },
    'Rent Inflow': {
      'title': 'Kandy Annex Rent Inflow',
      'total': 'LKR 55,000',
      'values': [55000.0, 55000.0, 55000.0, 55000.0, 55000.0, 55000.0],
      'color': const Color(0xFF38BDF8),
    },
    'Freelance': {
      'title': 'Freelance Income',
      'total': 'LKR 30,000',
      'values': [20000.0, 35000.0, 15000.0, 40000.0, 25000.0, 30000.0],
      'color': const Color(0xFF9353D3),
    },
    'All (3)': {
      'title': 'Combined Income Streams',
      'total': 'LKR 535,000',
      'values': [145000.0, 160000.0, 150000.0, 165000.0, 150000.0, 175000.0],
      'color': const Color(0xFF98E836),
    },
  };

  void _showPeriodPicker(BuildContext context, String currentPeriod) {
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
                  ? Icon(Icons.check, color: accentColor)
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
    final accentColor = ref.watch(accentColorProvider).color;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = AppColors.getBg(isDark);
    final cardBg = AppColors.getCard(isDark);
    final borderColor = AppColors.getBorder(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final textSecondary = AppColors.getTextSecondary(isDark);

    final trendStyle = ref.watch(subTrendChartStyleProvider);
    final categoryStyle = ref.watch(subCategoryChartStyleProvider);
    final defaultPeriod = ref.watch(selectedPeriodProvider);

    final periodLabel = _customPeriodLabel ??
        (defaultPeriod == AnalyticsPeriod.weekly
            ? 'Weekly : 2026'
            : defaultPeriod == AnalyticsPeriod.yearly
                ? 'Yearly : 2026'
                : 'Monthly : 2026');

    final currentStream =
        _streamData[_selectedFilter] ?? _streamData['Primary Salary']!;

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
                    onTap: () => _showPeriodPicker(context, periodLabel),
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
                  color: cardBg,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFF98E836), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL',
                      style: TextStyle(
                        color: Color(0xFF65A30D),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'LKR 535,000',
                      style: TextStyle(
                        color: Color(0xFF65A30D),
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AdaptiveTrendChart(
                      mode: trendStyle,
                      labels: _months,
                      values: _totalTrend,
                      color: const Color(0xFF98E836),
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
                                ? const Color(0xFF98E836)
                                : cardBg,
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
                                  fontWeight:
                                      isSel ? FontWeight.w700 : FontWeight.w500,
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
                      months: _months,
                      values: currentStream['values'] as List<double>,
                      barColor: currentStream['color'] as Color,
                      selectedIndex: 5,
                      valueFormatter: (v) => v.toInt().toString(),
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
                      amount: 'LKR 450,000',
                      amountColor: const Color(0xFF65A30D),
                      textColor: textPrimary,
                    ),
                    const SizedBox(height: 12),
                    _buildStreamRow(
                      dotColor: const Color(0xFF38BDF8),
                      name: 'Kandy Annex Rent',
                      amount: 'LKR 55,000',
                      amountColor: const Color(0xFF0284C7),
                      textColor: textPrimary,
                    ),
                    const SizedBox(height: 12),
                    _buildStreamRow(
                      dotColor: const Color(0xFF9353D3),
                      name: 'Freelance Income',
                      amount: 'LKR 30,000',
                      amountColor: const Color(0xFF7E22CE),
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
