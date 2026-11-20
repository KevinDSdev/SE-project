import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../providers/analytics_provider.dart';
import '../widgets/analytics_chart_widgets.dart';

class PredictionAnalysisScreen extends ConsumerStatefulWidget {
  const PredictionAnalysisScreen({super.key});

  @override
  ConsumerState<PredictionAnalysisScreen> createState() =>
      _PredictionAnalysisScreenState();
}

class _PredictionAnalysisScreenState
    extends ConsumerState<PredictionAnalysisScreen> {
  String? _selectedCategoryId;

  final List<String> _months = ['Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov*'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = AppColors.getBg(isDark);
    final cardBg = AppColors.getCard(isDark);
    final borderColor = AppColors.getBorder(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final textSecondary = AppColors.getTextSecondary(isDark);
    final accentColor = ref.watch(accentColorProvider).color;

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

    final String expectedNextMonthDisplay;
    final String? forecastSubtitle;
    final List<double> barValues;
    final List<String> yLabels;
    final bool hasHistoricalData;

    if (selectedCategory == null) {
      expectedNextMonthDisplay = 'Unavailable';
      forecastSubtitle = 'No expense categories available';
      barValues = const [0, 0, 0, 0, 0, 0];
      yLabels = const ['0', '0', '0'];
      hasHistoricalData = false;
    } else if (selectedCategory.id == 'exp_1' ||
        selectedCategory.name.toLowerCase().contains('food')) {
      expectedNextMonthDisplay = 'LKR 68,000';
      forecastSubtitle = null;
      barValues = const [61000, 64000, 59000, 67000, 65000, 68000];
      yLabels = const ['50K', '60k', '75K'];
      hasHistoricalData = true;
    } else if (selectedCategory.id == 'exp_2' ||
        selectedCategory.name.toLowerCase().contains('transport')) {
      expectedNextMonthDisplay = 'LKR 35,000';
      forecastSubtitle = null;
      barValues = const [28000, 31000, 30000, 34000, 32000, 35000];
      yLabels = const ['25K', '30k', '40K'];
      hasHistoricalData = true;
    } else if (selectedCategory.id == 'exp_3' ||
        selectedCategory.name.toLowerCase().contains('utilit')) {
      expectedNextMonthDisplay = 'LKR 48,000';
      forecastSubtitle = null;
      barValues = const [42000, 44000, 41000, 46000, 45000, 48000];
      yLabels = const ['35K', '45k', '55K'];
      hasHistoricalData = true;
    } else {
      expectedNextMonthDisplay = 'Unavailable';
      forecastSubtitle =
          'Historical transaction data required to generate forecast';
      barValues = const [0, 0, 0, 0, 0, 0];
      yLabels = const ['0', '0', '0'];
      hasHistoricalData = false;
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
                  Expanded(
                    child: Text(
                      'Expenses Prediction Analysis',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

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
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategoryId = cat.id;
                            });
                          },
                          child: Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
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
                                    fontSize: 12.5,
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
              const SizedBox(height: 20),

              // Expected Next Month Expense Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expected Next Month Expense',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      expectedNextMonthDisplay,
                      style: const TextStyle(
                        color: Color(0xFFF43F5E),
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (forecastSubtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        forecastSubtitle,
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Past 5 Months vs. Forecast Chart Card
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
                        Text(
                          'Past 5 Months vs. Nov Forecast',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (hasHistoricalData)
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF38BDF8),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Actual',
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF43F5E),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Est.',
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
                    if (!hasHistoricalData)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'Historical transaction records required to calculate category prediction curve.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                    else
                      PredictionBarChartWidget(
                        months: _months,
                        values: barValues,
                        yAxisLabels: yLabels,
                        forecastColor: const Color(0xFFF43F5E),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
