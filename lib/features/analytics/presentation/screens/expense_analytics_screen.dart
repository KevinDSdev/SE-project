import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../providers/analytics_provider.dart';
import '../widgets/analytics_chart_widgets.dart';

class ExpenseAnalyticsScreen extends ConsumerStatefulWidget {
  const ExpenseAnalyticsScreen({super.key});

  @override
  ConsumerState<ExpenseAnalyticsScreen> createState() =>
      _ExpenseAnalyticsScreenState();
}

class _ExpenseAnalyticsScreenState extends ConsumerState<ExpenseAnalyticsScreen> {
  String _selectedFilter = 'Food & Groceries';
  String? _customPeriodLabel;

  final List<String> _filters = [
    'All (6)',
    'Food & Groceries',
    'Transport',
    'Utilities',
  ];

  final List<String> _months = ['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'];
  final List<double> _totalTrend = [54000, 68500, 38000, 46000, 62000, 50000];

  final Map<String, Map<String, dynamic>> _categoryData = {
    'Food & Groceries': {
      'title': 'Food & Groceries - Monthly Spend',
      'budget': 'Budget: LKR 70K',
      'total': 'LKR 65,000',
      'values': [14500.0, 18200.0, 12000.0, 11000.0, 5200.0, 4100.0],
      'barColor': const Color(0xFFF59E0B),
      'alternateColor': const Color(0xFFFF5C6C),
      'alternateIndex': 1,
    },
    'Transport': {
      'title': 'Transport - Fuel & Rides',
      'budget': 'Budget: LKR 35K',
      'total': 'LKR 32,500',
      'values': [5200.0, 6100.0, 4800.0, 5500.0, 5900.0, 5000.0],
      'barColor': const Color(0xFF38BDF8),
      'alternateColor': const Color(0xFFFF5C6C),
      'alternateIndex': 1,
    },
    'Utilities': {
      'title': 'Utilities - Electricity & Water',
      'budget': 'Budget: LKR 50K',
      'total': 'LKR 45,000',
      'values': [7200.0, 8100.0, 7400.0, 7600.0, 7500.0, 7200.0],
      'barColor': const Color(0xFFF59E0B),
      'alternateColor': const Color(0xFFFF5C6C),
      'alternateIndex': 1,
    },
    'All (6)': {
      'title': 'Total Monthly Outflow Across Categories',
      'budget': 'Budget: LKR 350K',
      'total': 'LKR 318,500',
      'values': [54000.0, 68500.0, 38000.0, 46000.0, 62000.0, 50000.0],
      'barColor': const Color(0xFFF59E0B),
      'alternateColor': const Color(0xFFFF5C6C),
      'alternateIndex': 1,
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

    final currentCat =
        _categoryData[_selectedFilter] ?? _categoryData['Food & Groceries']!;

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
                        'Expense Analytics',
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

              // Total Expenses Card
              Container(
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
                    const Text(
                      'TOTAL',
                      style: TextStyle(
                        color: Color(0xFFFF6464),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'LKR 318,500',
                      style: TextStyle(
                        color: Color(0xFFFF6464),
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AdaptiveTrendChart(
                      mode: trendStyle,
                      labels: _months,
                      values: _totalTrend,
                      color: const Color(0xFFFF6464),
                      selectedIndex: 5,
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
                                ? const Color(0xFFF43F5E)
                                : cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSel
                                  ? const Color(0xFFF43F5E)
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
                                      ? Colors.white
                                      : textSecondary,
                                  fontSize: 13,
                                  fontWeight:
                                      isSel ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                              if (isSel && filter != 'All (6)') ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.check,
                                  color: Colors.white,
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
                      currentCat['title'] as String,
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
                          currentCat['total'] as String,
                          style: const TextStyle(
                            color: Color(0xFFFF5C6C),
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          currentCat['budget'] as String,
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AdaptiveCategoryChart(
                      mode: categoryStyle,
                      months: _months,
                      values: currentCat['values'] as List<double>,
                      barColor: currentCat['barColor'] as Color,
                      alternateBarColor: currentCat['alternateColor'] as Color?,
                      labelColor: const Color(0xFFE2E8F0),
                      selectedLabelColor: const Color(0xFFFF5C6C),
                      selectedMonthColor: const Color(0xFFB0B7C3),
                      selectedIndex: (currentCat['alternateIndex'] as int?) ?? 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Categories Distribution
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
                      'Categories Distribution',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildExpenseRow(
                      dotColor: Colors.white,
                      name: 'Housing & Rent',
                      amount: 'LKR 120,000',
                      amountColor: textPrimary,
                      textColor: textSecondary,
                    ),
                    const SizedBox(height: 12),
                    _buildExpenseRow(
                      dotColor: const Color(0xFFFF5C6C),
                      name: 'Food & Groceries',
                      amount: 'LKR 65,000',
                      amountColor: const Color(0xFFFF5C6C),
                      textColor: textSecondary,
                    ),
                    const SizedBox(height: 12),
                    _buildExpenseRow(
                      dotColor: const Color(0xFFF59E0B),
                      name: 'Utilities (CEB & Water)',
                      amount: 'LKR 45,000',
                      amountColor: const Color(0xFFF59E0B),
                      textColor: textSecondary,
                    ),
                    const SizedBox(height: 12),
                    _buildExpenseRow(
                      dotColor: const Color(0xFF38BDF8),
                      name: 'Travel & Transport',
                      amount: 'LKR 32,500',
                      amountColor: const Color(0xFF38BDF8),
                      textColor: textSecondary,
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

  Widget _buildExpenseRow({
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
