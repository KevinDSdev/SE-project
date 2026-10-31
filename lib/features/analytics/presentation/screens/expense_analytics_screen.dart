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
    'Bills',
  ];

  final List<String> _months = ['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'];
  final List<double> _totalTrend = [54000, 68500, 38000, 46000, 62000, 50000];

  final Map<String, Map<String, dynamic>> _categoryData = {
    'Food & Groceries': {
      'title': 'Food & Groceries - Monthly Spend',
      'budget': 'Monthly Budget : LKR 60,000',
      'total': 'LKR 50,000',
      'values': [54000.0, 68500.0, 38000.0, 46000.0, 62000.0, 50000.0],
      'barColor': const Color(0xFFF43F5E),
      'alternateColor': const Color(0xFFF43F5E),
      'alternateIndex': 5,
    },
    'Transport': {
      'title': 'Transport - Fuel & Rides',
      'budget': 'Monthly Budget : LKR 25,000',
      'total': 'LKR 21,500',
      'values': [22000.0, 24000.0, 19000.0, 25000.0, 28000.0, 21500.0],
      'barColor': const Color(0xFF38BDF8),
      'alternateColor': const Color(0xFF38BDF8),
    },
    'Utilities': {
      'title': 'Utilities - Electricity & Water',
      'budget': 'Monthly Budget : LKR 30,000',
      'total': 'LKR 28,000',
      'values': [25000.0, 26000.0, 27000.0, 29000.0, 31000.0, 28000.0],
      'barColor': const Color(0xFFF59E0B),
      'alternateColor': const Color(0xFFF59E0B),
    },
    'Bills': {
      'title': 'Bills - Telecom & Internet',
      'budget': 'Monthly Budget : LKR 15,000',
      'total': 'LKR 14,000',
      'values': [12000.0, 13500.0, 14000.0, 14500.0, 15000.0, 14000.0],
      'barColor': const Color(0xFF98E836),
      'alternateColor': const Color(0xFF98E836),
    },
    'All (6)': {
      'title': 'Total Monthly Outflow Across Categories',
      'budget': 'Total Budget : LKR 350,000',
      'total': 'LKR 318,500',
      'values': [280000.0, 295000.0, 260000.0, 290000.0, 305000.0, 318500.0],
      'barColor': const Color(0xFFF43F5E),
      'alternateColor': const Color(0xFFF43F5E),
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
                  color: cardBg,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFF43F5E), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL',
                      style: TextStyle(
                        color: Color(0xFFE11D48),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'LKR 318,500',
                      style: TextStyle(
                        color: Color(0xFFE11D48),
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AdaptiveTrendChart(
                      mode: trendStyle,
                      labels: _months,
                      values: _totalTrend,
                      color: const Color(0xFFF43F5E),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            currentCat['title'] as String,
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          currentCat['budget'] as String,
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
                      currentCat['total'] as String,
                      style: const TextStyle(
                        color: Color(0xFFE11D48),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AdaptiveCategoryChart(
                      mode: categoryStyle,
                      months: _months,
                      values: currentCat['values'] as List<double>,
                      barColor: currentCat['barColor'] as Color,
                      alternateBarColor: currentCat['alternateColor'] as Color?,
                      selectedIndex: (currentCat['alternateIndex'] as int?) ?? 5,
                      valueFormatter: (v) => v.toInt().toString(),
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
                      'Categories Breakdown',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildExpenseRow(
                      dotColor: const Color(0xFFF43F5E),
                      name: 'Food & Groceries',
                      amount: 'LKR 118,500',
                      amountColor: const Color(0xFFE11D48),
                      textColor: textPrimary,
                    ),
                    const SizedBox(height: 12),
                    _buildExpenseRow(
                      dotColor: const Color(0xFF38BDF8),
                      name: 'Transport',
                      amount: 'LKR 65,000',
                      amountColor: const Color(0xFF0284C7),
                      textColor: textPrimary,
                    ),
                    const SizedBox(height: 12),
                    _buildExpenseRow(
                      dotColor: const Color(0xFFF59E0B),
                      name: 'Utilities',
                      amount: 'LKR 45,000',
                      amountColor: const Color(0xFFD97706),
                      textColor: textPrimary,
                    ),
                    const SizedBox(height: 12),
                    _buildExpenseRow(
                      dotColor: const Color(0xFF98E836),
                      name: 'Bills & Subscriptions',
                      amount: 'LKR 90,000',
                      amountColor: const Color(0xFF65A30D),
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
