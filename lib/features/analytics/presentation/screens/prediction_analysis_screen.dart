import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/analytics_chart_widgets.dart';

enum PredictionMode { expenses, income }

class PredictionAnalysisScreen extends ConsumerStatefulWidget {
  final PredictionMode initialMode;

  const PredictionAnalysisScreen({
    super.key,
    this.initialMode = PredictionMode.expenses,
  });

  @override
  ConsumerState<PredictionAnalysisScreen> createState() =>
      _PredictionAnalysisScreenState();
}

class _PredictionAnalysisScreenState
    extends ConsumerState<PredictionAnalysisScreen> {
  late PredictionMode _currentMode;
  String _selectedExpenseCategory = 'Food & Grocery';
  String _selectedIncomeCategory = 'Salary';

  final List<String> _expenseCategories = [
    'All Outflows',
    'Food & Grocery',
    'Transport',
    'Bills',
  ];

  final List<String> _incomeCategories = [
    'All Inflows',
    'Salary',
    'Freelance',
    'Rental',
  ];

  final List<String> _months = ['Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov*'];

  // Expense forecast data
  final List<double> _expenseBarValues = [
    61000,
    64000,
    59000,
    67000,
    65000,
    68000
  ];
  final List<String> _expenseYLabels = ['50K', '60K', '75K'];

  // Income forecast data
  final List<double> _incomeBarValues = [
    75000,
    80000,
    60000,
    90000,
    85000,
    100000
  ];
  final List<String> _incomeYLabels = ['50K', '80K', '90K'];

  @override
  void initState() {
    super.initState();
    _currentMode = widget.initialMode;
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = _currentMode == PredictionMode.expenses;

    return Scaffold(
      backgroundColor: AppColors.lightBg,
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isExpense
                          ? 'Expenses Prediction Analysis'
                          : 'Income Prediction Analysis',
                      style: const TextStyle(
                        color: AppColors.lightTextPrimary,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Segmented Forecast Mode Switcher
              Container(
                height: 46,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(
                            () => _currentMode = PredictionMode.expenses),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isExpense
                                ? const Color(0xFFF43F5E)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              'Expenses Forecast',
                              style: TextStyle(
                                color: isExpense
                                    ? Colors.white
                                    : AppColors.lightTextSecondary,
                                fontSize: 13,
                                fontWeight: isExpense
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(
                            () => _currentMode = PredictionMode.income),
                        child: Container(
                          decoration: BoxDecoration(
                            color: !isExpense
                                ? const Color(0xFF98E836)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              'Income Forecast',
                              style: TextStyle(
                                color: !isExpense
                                    ? const Color(0xFF0C0F14)
                                    : AppColors.lightTextSecondary,
                                fontSize: 13,
                                fontWeight: !isExpense
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Forecast Total Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isExpense
                        ? const Color(0xFFF43F5E)
                        : const Color(0xFF98E836),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isExpense ? 'PROJECTED EXPENSES' : 'PROJECTED INFLOW',
                          style: TextStyle(
                            color: isExpense
                                ? const Color(0xFFE11D48)
                                : const Color(0xFF65A30D),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isExpense
                                ? const Color(0xFFF43F5E).withValues(alpha: 0.15)
                                : const Color(0xFF98E836).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isExpense ? 'High Conf. 88%' : 'High Conf. 92%',
                            style: TextStyle(
                              color: isExpense
                                  ? const Color(0xFFE11D48)
                                  : const Color(0xFF65A30D),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isExpense ? 'LKR 330,000' : 'LKR 540,000',
                      style: TextStyle(
                        color: isExpense
                            ? const Color(0xFFE11D48)
                            : const Color(0xFF65A30D),
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isExpense
                          ? 'Estimated variance: ± LKR 8,500 based on previous 5 months'
                          : 'Estimated variance: ± LKR 12,000 based on incoming milestones',
                      style: const TextStyle(
                        color: AppColors.lightTextSecondary,
                        fontSize: 12,
                      ),
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
                  children: (isExpense
                          ? _expenseCategories
                          : _incomeCategories)
                      .map((cat) {
                    final isSel = (isExpense
                            ? _selectedExpenseCategory
                            : _selectedIncomeCategory) ==
                        cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isExpense) {
                              _selectedExpenseCategory = cat;
                            } else {
                              _selectedIncomeCategory = cat;
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: isSel
                                ? (isExpense
                                    ? const Color(0xFFF43F5E)
                                    : const Color(0xFF98E836))
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSel
                                  ? (isExpense
                                      ? const Color(0xFFF43F5E)
                                      : const Color(0xFF98E836))
                                  : AppColors.lightBorder,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSel
                                  ? (isExpense
                                      ? Colors.white
                                      : const Color(0xFF0C0F14))
                                  : AppColors.lightTextSecondary,
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
              const SizedBox(height: 18),

              // Forecast Chart Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
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
                        Text(
                          isExpense
                              ? 'Nov 2026 Expected Outflow'
                              : 'Nov 2026 Expected Inflow',
                          style: const TextStyle(
                            color: AppColors.lightTextPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isExpense
                                    ? const Color(0xFFF43F5E)
                                    : const Color(0xFF98E836),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Forecast',
                              style: TextStyle(
                                color: isExpense
                                    ? const Color(0xFFE11D48)
                                    : const Color(0xFF65A30D),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    PredictionBarChartWidget(
                      months: _months,
                      values:
                          isExpense ? _expenseBarValues : _incomeBarValues,
                      yAxisLabels:
                          isExpense ? _expenseYLabels : _incomeYLabels,
                      forecastColor: isExpense
                          ? const Color(0xFFF43F5E)
                          : const Color(0xFF98E836),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Detected Probabilities Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isExpense
                          ? 'Detected Spending Probabilities'
                          : 'Detected Inflow Probabilities',
                      style: const TextStyle(
                        color: AppColors.lightTextPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (isExpense) ...[
                      _buildProbabilityItem(
                        percentage: '60%',
                        label: 'Single Bill Under LKR 5,000',
                        badgeColor: const Color(0xFF98E836),
                        borderColor: const Color(0xFF98E836),
                      ),
                      const SizedBox(height: 10),
                      _buildProbabilityItem(
                        percentage: '20%',
                        label: 'First Weekend Bulk Spend',
                        badgeColor: const Color(0xFF38BDF8),
                        borderColor: const Color(0xFF38BDF8),
                      ),
                      const SizedBox(height: 10),
                      _buildProbabilityItem(
                        percentage: '25%',
                        label: 'Late-Month Surge Over LKR 70K',
                        badgeColor: const Color(0xFFF59E0B),
                        borderColor: const Color(0xFFF59E0B),
                      ),
                    ] else ...[
                      _buildProbabilityItem(
                        percentage: '98%',
                        label: 'Base Salary End Of The Month',
                        badgeColor: const Color(0xFF98E836),
                        borderColor: const Color(0xFF98E836),
                      ),
                      const SizedBox(height: 10),
                      _buildProbabilityItem(
                        percentage: '85%',
                        label: 'Rental Deposit Before Day 10',
                        badgeColor: const Color(0xFF38BDF8),
                        borderColor: const Color(0xFF38BDF8),
                      ),
                      const SizedBox(height: 10),
                      _buildProbabilityItem(
                        percentage: '65%',
                        label: 'Freelance Payout',
                        badgeColor: const Color(0xFF9353D3),
                        borderColor: const Color(0xFF9353D3),
                      ),
                    ],
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

  Widget _buildProbabilityItem({
    required String percentage,
    required String label,
    required Color badgeColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.lightSubContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              percentage,
              style: const TextStyle(
                color: Color(0xFF0C0F14),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.lightTextPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
