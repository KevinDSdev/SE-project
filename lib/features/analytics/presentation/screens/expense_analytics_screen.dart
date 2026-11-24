import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../services/analytics_period_helper.dart';
import '../widgets/analytics_chart_widgets.dart';

class ExpenseAnalyticsScreen extends ConsumerStatefulWidget {
  const ExpenseAnalyticsScreen({super.key});

  @override
  ConsumerState<ExpenseAnalyticsScreen> createState() =>
      _ExpenseAnalyticsScreenState();
}

class _ExpenseAnalyticsScreenState
    extends ConsumerState<ExpenseAnalyticsScreen> {
  String? _selectedCategoryId;

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
                            AnalyticsScreenType.expense,
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

    final trendStyle = ref.watch(subTrendChartStyleProvider);
    final categoryStyle = ref.watch(subCategoryChartStyleProvider);
    final selectedPeriod = ref.watch(
      analyticsScreenPeriodProvider(AnalyticsScreenType.expense),
    );

    final periodLabel = AnalyticsPeriodHelper.getPeriodTypeLabel(
      selectedPeriod,
    );
    final labels = AnalyticsPeriodHelper.getLabelsForPeriod(selectedPeriod);
    final lastIndex = (labels.length - 1).clamp(0, 10);

    final String totalAmountDisplay;
    final List<double> totalTrend;
    final Map<String, Map<String, dynamic>> categoryData;
    final String housingAmount;
    final String foodAmount;
    final String utilitiesAmount;
    final String transportAmount;

    switch (selectedPeriod) {
      case AnalyticsPeriod.weekly:
        totalAmountDisplay = 'LKR 83,500';
        totalTrend = const [75000, 82000, 78000, 83500];
        housingAmount = 'LKR 30,000';
        foodAmount = 'LKR 18,200';
        utilitiesAmount = 'LKR 11,200';
        transportAmount = 'LKR 8,500';
        categoryData = {
          'Food & Groceries': {
            'title': 'Food & Groceries - Weekly Spend',
            'budget': 'Budget: LKR 20K',
            'total': 'LKR 18,200',
            'values': const [14500.0, 18200.0, 12000.0, 11000.0],
            'barColor': const Color(0xFFF59E0B),
            'alternateColor': const Color(0xFFFF5C6C),
            'alternateIndex': 1,
          },
          'Transport': {
            'title': 'Transport - Fuel & Rides',
            'budget': 'Budget: LKR 10K',
            'total': 'LKR 8,500',
            'values': const [5200.0, 6100.0, 4800.0, 5500.0],
            'barColor': const Color(0xFF38BDF8),
            'alternateColor': const Color(0xFFFF5C6C),
            'alternateIndex': 1,
          },
          'Utilities': {
            'title': 'Utilities - Electricity & Water',
            'budget': 'Budget: LKR 12K',
            'total': 'LKR 11,200',
            'values': const [7200.0, 8100.0, 7400.0, 7600.0],
            'barColor': const Color(0xFFF59E0B),
            'alternateColor': const Color(0xFFFF5C6C),
            'alternateIndex': 1,
          },
          'All (6)': {
            'title': 'Total Weekly Outflow Across Categories',
            'budget': 'Budget: LKR 90K',
            'total': 'LKR 83,500',
            'values': const [75000.0, 82000.0, 78000.0, 83500.0],
            'barColor': const Color(0xFFF59E0B),
            'alternateColor': const Color(0xFFFF5C6C),
            'alternateIndex': 1,
          },
        };
        break;
      case AnalyticsPeriod.yearly:
        totalAmountDisplay = 'LKR 3,822,000';
        totalTrend = const [
          3200000,
          3500000,
          3700000,
          3900000,
          3800000,
          3822000,
        ];
        housingAmount = 'LKR 1,440,000';
        foodAmount = 'LKR 780,000';
        utilitiesAmount = 'LKR 540,000';
        transportAmount = 'LKR 390,000';
        categoryData = {
          'Food & Groceries': {
            'title': 'Food & Groceries - Annual Spend',
            'budget': 'Budget: LKR 840K',
            'total': 'LKR 780,000',
            'values': const [
              650000.0,
              680000.0,
              710000.0,
              740000.0,
              760000.0,
              780000.0,
            ],
            'barColor': const Color(0xFFF59E0B),
            'alternateColor': const Color(0xFFFF5C6C),
            'alternateIndex': 1,
          },
          'Transport': {
            'title': 'Transport - Fuel & Rides',
            'budget': 'Budget: LKR 420K',
            'total': 'LKR 390,000',
            'values': const [
              320000.0,
              340000.0,
              360000.0,
              370000.0,
              380000.0,
              390000.0,
            ],
            'barColor': const Color(0xFF38BDF8),
            'alternateColor': const Color(0xFFFF5C6C),
            'alternateIndex': 1,
          },
          'Utilities': {
            'title': 'Utilities - Electricity & Water',
            'budget': 'Budget: LKR 600K',
            'total': 'LKR 540,000',
            'values': const [
              450000.0,
              480000.0,
              500000.0,
              520000.0,
              530000.0,
              540000.0,
            ],
            'barColor': const Color(0xFFF59E0B),
            'alternateColor': const Color(0xFFFF5C6C),
            'alternateIndex': 1,
          },
          'All (6)': {
            'title': 'Total Annual Outflow Across Categories',
            'budget': 'Budget: LKR 4.2M',
            'total': 'LKR 3,822,000',
            'values': const [
              3200000.0,
              3500000.0,
              3700000.0,
              3900000.0,
              3800000.0,
              3822000.0,
            ],
            'barColor': const Color(0xFFF59E0B),
            'alternateColor': const Color(0xFFFF5C6C),
            'alternateIndex': 1,
          },
        };
        break;
      case AnalyticsPeriod.monthly:
      default:
        totalAmountDisplay = 'LKR 318,500';
        totalTrend = const [54000, 68500, 38000, 46000, 62000, 50000];
        housingAmount = 'LKR 120,000';
        foodAmount = 'LKR 65,000';
        utilitiesAmount = 'LKR 45,000';
        transportAmount = 'LKR 32,500';
        categoryData = {
          'Food & Groceries': {
            'title': 'Food & Groceries - Monthly Spend',
            'budget': 'Budget: LKR 70K',
            'total': 'LKR 65,000',
            'values': const [
              14500.0,
              18200.0,
              12000.0,
              11000.0,
              5200.0,
              4100.0,
            ],
            'barColor': const Color(0xFFF59E0B),
            'alternateColor': const Color(0xFFFF5C6C),
            'alternateIndex': 1,
          },
          'Transport': {
            'title': 'Transport - Fuel & Rides',
            'budget': 'Budget: LKR 35K',
            'total': 'LKR 32,500',
            'values': const [5200.0, 6100.0, 4800.0, 5500.0, 5900.0, 5000.0],
            'barColor': const Color(0xFF38BDF8),
            'alternateColor': const Color(0xFFFF5C6C),
            'alternateIndex': 1,
          },
          'Utilities': {
            'title': 'Utilities - Electricity & Water',
            'budget': 'Budget: LKR 50K',
            'total': 'LKR 45,000',
            'values': const [7200.0, 8100.0, 7400.0, 7600.0, 7500.0, 7200.0],
            'barColor': const Color(0xFFF59E0B),
            'alternateColor': const Color(0xFFFF5C6C),
            'alternateIndex': 1,
          },
          'All (6)': {
            'title': 'Total Monthly Outflow Across Categories',
            'budget': 'Budget: LKR 350K',
            'total': 'LKR 318,500',
            'values': const [
              54000.0,
              68500.0,
              38000.0,
              46000.0,
              62000.0,
              50000.0,
            ],
            'barColor': const Color(0xFFF59E0B),
            'alternateColor': const Color(0xFFFF5C6C),
            'alternateIndex': 1,
          },
        };
        break;
    }

    final categories = ref.watch(expenseCategoriesProvider);

    // Auto-select first category if none selected, or if selected was deleted
    if (categories.isNotEmpty) {
      if (_selectedCategoryId == null ||
          !categories.any((c) => c.id == _selectedCategoryId)) {
        _selectedCategoryId = categories.first.id;
      }
    } else {
      _selectedCategoryId = null;
    }

    final selectedCategory = categories.isNotEmpty
        ? categories.firstWhere(
            (c) => c.id == _selectedCategoryId,
            orElse: () => categories.first,
          )
        : null;

    final Map<String, dynamic> currentCat;
    if (selectedCategory == null) {
      currentCat = {
        'title': 'No Category Selected',
        'budget': 'No Budget',
        'total': 'LKR 0',
        'values': List.filled(labels.length, 0.0),
        'barColor': accentColor,
        'hasData': false,
      };
    } else if (selectedCategory.id == 'exp_1' ||
        selectedCategory.name.toLowerCase().contains('food')) {
      currentCat = categoryData['Food & Groceries']!;
    } else if (selectedCategory.id == 'exp_2' ||
        selectedCategory.name.toLowerCase().contains('transport')) {
      currentCat = categoryData['Transport']!;
    } else if (selectedCategory.id == 'exp_3' ||
        selectedCategory.name.toLowerCase().contains('utilit')) {
      currentCat = categoryData['Utilities']!;
    } else {
      currentCat = {
        'title': '${selectedCategory.name} - Spend',
        'budget': 'No Budget Set',
        'total': 'LKR 0',
        'values': List.filled(labels.length, 0.0),
        'barColor': selectedCategory.color,
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

              // Total Expenses Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF281519) : cardBg,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFFFF6464),
                    width: 1.5,
                  ),
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
                    Text(
                      totalAmountDisplay,
                      style: const TextStyle(
                        color: Color(0xFFFF6464),
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AdaptiveTrendChart(
                      mode: trendStyle,
                      labels: labels,
                      values: totalTrend,
                      color: const Color(0xFFFF6464),
                      selectedIndex: lastIndex,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Filter Chips
              if (categories.isEmpty)
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
                      'No expense categories available',
                      style: TextStyle(color: textSecondary, fontSize: 13),
                    ),
                  ),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: categories.map((cat) {
                      final isSel = _selectedCategoryId == cat.id;
                      final chipFg = isSel
                          ? (accentColor.computeLuminance() > 0.5
                                ? const Color(0xFF0C0F14)
                                : Colors.white)
                          : textSecondary;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedCategoryId = cat.id),
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
                                    color: cat.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Text(
                                  cat.name,
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
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (currentCat['hasData'] == false) ...[
                      const SizedBox(height: 6),
                      Text(
                        'No transactions recorded yet for this category',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    AdaptiveCategoryChart(
                      mode: categoryStyle,
                      months: labels,
                      values: currentCat['values'] as List<double>,
                      barColor: currentCat['barColor'] as Color,
                      alternateBarColor: currentCat['alternateColor'] as Color?,
                      selectedIndex: lastIndex,
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
                    if (categories.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'No expense categories available.',
                          style: TextStyle(color: textSecondary, fontSize: 13),
                        ),
                      )
                    else
                      ...categories.map((cat) {
                        String amt;
                        if (cat.id == 'exp_1' ||
                            cat.name.toLowerCase().contains('food')) {
                          amt = foodAmount;
                        } else if (cat.id == 'exp_2' ||
                            cat.name.toLowerCase().contains('transport')) {
                          amt = transportAmount;
                        } else if (cat.id == 'exp_3' ||
                            cat.name.toLowerCase().contains('utilit')) {
                          amt = utilitiesAmount;
                        } else {
                          amt = 'LKR 0';
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildExpenseRow(
                            dotColor: cat.color,
                            name: cat.name,
                            amount: amt,
                            amountColor: cat.color,
                            textColor: textSecondary,
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
