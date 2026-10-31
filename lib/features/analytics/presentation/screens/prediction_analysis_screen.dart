import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/analytics_chart_widgets.dart';

class PredictionAnalysisScreen extends ConsumerStatefulWidget {
  const PredictionAnalysisScreen({super.key});

  @override
  ConsumerState<PredictionAnalysisScreen> createState() =>
      _PredictionAnalysisScreenState();
}

class _PredictionAnalysisScreenState
    extends ConsumerState<PredictionAnalysisScreen> {
  String _selectedCategory = 'Food & Grocery';

  final List<String> _categories = [
    'All Outflows',
    'Food & Grocery',
    'Transport',
    'Biils',
  ];

  final List<String> _months = ['Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov*'];

  // Expense forecast data (matches 12. Expenses prediction Analysis.png exactly)
  final List<double> _barValues = [
    61000,
    64000,
    59000,
    67000,
    65000,
    68000
  ];
  final List<String> _yLabels = ['50K', '60K', '75K'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = AppColors.getBg(isDark);
    final cardBg = AppColors.getCard(isDark);
    final borderColor = AppColors.getBorder(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final textSecondary = AppColors.getTextSecondary(isDark);

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

              // Filter Chips (matching 12. Expenses prediction Analysis.png)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _categories.map((cat) {
                    final isSel = _selectedCategory == cat;
                    final isAll = cat == 'All Outflows';
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSel && !isAll
                                ? const Color(0xFFF43F5E)
                                : cardBg,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: isAll
                                  ? const Color(0xFFF43F5E)
                                  : (isSel
                                      ? const Color(0xFFF43F5E)
                                      : borderColor),
                              width: isAll ? 1.5 : 1,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSel && !isAll
                                  ? Colors.black
                                  : (isAll
                                      ? const Color(0xFFF43F5E)
                                      : textSecondary),
                              fontSize: 13,
                              fontWeight:
                                  isSel ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Expected Next Month Expense Card (matching 12. Expenses prediction Analysis.png)
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
                    const Text(
                      'LKR 68,000',
                      style: TextStyle(
                        color: Color(0xFFF43F5E),
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Past 5 Months vs. Nov Forecast Chart Card
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
                    PredictionBarChartWidget(
                      months: _months,
                      values: _barValues,
                      yAxisLabels: _yLabels,
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
