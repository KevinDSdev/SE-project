import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/navigation_provider.dart';
import 'analytics_screen.dart';

enum AnalyticsPeriod { weekly, monthly, yearly }

class FinancialAnalyticsScreen extends ConsumerStatefulWidget {
  const FinancialAnalyticsScreen({super.key});

  @override
  ConsumerState<FinancialAnalyticsScreen> createState() =>
      _FinancialAnalyticsScreenState();
}

class _FinancialAnalyticsScreenState
    extends ConsumerState<FinancialAnalyticsScreen> {
  AnalyticsPeriod _selectedPeriod = AnalyticsPeriod.monthly;
  int _selectedMonthIndex = 5; // Default Oct (index 5)
  final _currencyFormat = NumberFormat('#,###');

  final List<Map<String, dynamic>> _monthlyData = [
    {'month': 'May', 'income': 420000.0, 'expense': 280000.0, 'inRatio': 0.65, 'exRatio': 0.45},
    {'month': 'Jun', 'income': 450000.0, 'expense': 295000.0, 'inRatio': 0.70, 'exRatio': 0.48},
    {'month': 'Jul', 'income': 470000.0, 'expense': 260000.0, 'inRatio': 0.73, 'exRatio': 0.42},
    {'month': 'Aug', 'income': 510000.0, 'expense': 290000.0, 'inRatio': 0.82, 'exRatio': 0.47},
    {'month': 'Sep', 'income': 490000.0, 'expense': 305000.0, 'inRatio': 0.78, 'exRatio': 0.49},
    {'month': 'Oct', 'income': 535000.0, 'expense': 318500.0, 'inRatio': 0.95, 'exRatio': 0.55},
  ];

  @override
  Widget build(BuildContext context) {
    final activeMonth = _monthlyData[_selectedMonthIndex];
    final activeIncome = activeMonth['income'] as double;
    final activeExpense = activeMonth['expense'] as double;
    final activeSavings = activeIncome - activeExpense;
    final monthName = activeMonth['month'] as String;

    return Scaffold(
      backgroundColor: const Color(0xFF0C0F14),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Back Button & Title
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        ref.read(selectedTabProvider.notifier).setTab(0);
                      }
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF161922),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF262B36),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.chevron_left_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Financial Analytics',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Period Selector (Weekly, Monthly, Yearly)
              _buildPeriodSelector(),
              const SizedBox(height: 18),

              // 3 Metric Cards: Income, Expenses, Savings
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Income',
                      amount: activeIncome,
                      dotColor: AppColors.primary,
                      borderColor: AppColors.primary,
                      onTap: () => _showBreakdownSheet('Income', activeIncome, AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Expenses',
                      amount: activeExpense,
                      dotColor: const Color(0xFFEF4444),
                      borderColor: const Color(0xFFEF4444),
                      onTap: () => _showBreakdownSheet('Expenses', activeExpense, const Color(0xFFEF4444)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Savings',
                      amount: activeSavings,
                      dotColor: const Color(0xFF38BDF8),
                      borderColor: const Color(0xFF38BDF8),
                      onTap: () => _showBreakdownSheet('Savings', activeSavings, const Color(0xFF38BDF8)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Income vs Expenses Chart Card
              _buildIncomeVsExpensesCard(activeMonth, monthName, activeSavings),
              const SizedBox(height: 18),

              // 2x2 Quick Action Cards Grid
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      title: 'AI Forecast',
                      subtitle: 'Projections',
                      borderColor: AppColors.primary,
                      titleColor: AppColors.primary,
                      icon: Icons.auto_awesome_rounded,
                      onTap: _showAIForecastModal,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionCard(
                      title: 'Transaction History',
                      subtitle: '142 records',
                      borderColor: AppColors.primary,
                      titleColor: AppColors.primary,
                      icon: Icons.receipt_long_rounded,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AnalyticsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      title: 'Import Statements',
                      subtitle: 'PDF, XLS',
                      borderColor: const Color(0xFF38BDF8),
                      titleColor: const Color(0xFF38BDF8),
                      icon: Icons.upload_file_rounded,
                      onTap: _showImportModal,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionCard(
                      title: 'Export Hub',
                      subtitle: 'PDF, CSV',
                      borderColor: const Color(0xFF38BDF8),
                      titleColor: const Color(0xFF38BDF8),
                      icon: Icons.download_rounded,
                      onTap: _showExportModal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Full Width "Customize Analytics Dashboard" Card
              _buildCustomizeCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0F14),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          _buildPeriodTab('Weekly', AnalyticsPeriod.weekly),
          _buildPeriodTab('Monthly', AnalyticsPeriod.monthly),
          _buildPeriodTab('Yearly', AnalyticsPeriod.yearly),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(String label, AnalyticsPeriod period) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = period),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF0C0F14) : const Color(0xFF8E95A3),
                fontSize: 13.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required double amount,
    required Color dotColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF131722),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  title,
                  style: TextStyle(
                    color: dotColor,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'LKR',
              style: TextStyle(
                color: dotColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 1),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                _currencyFormat.format(amount),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Breakdown',
              style: TextStyle(
                color: dotColor,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeVsExpensesCard(
    Map<String, dynamic> activeMonth,
    String monthName,
    double activeSavings,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF131722),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1E2332),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title & In/Ex Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Income vs Expenses (May – Oct)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'In',
                    style: TextStyle(
                      color: Color(0xFF8E95A3),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFA855F7),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Ex',
                    style: TextStyle(
                      color: Color(0xFF8E95A3),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Subtitle: Net Surplus
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$monthName Net Surplus: ',
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: '+LKR ${_currencyFormat.format(activeSavings)}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Bar Chart with 6 months
          SizedBox(
            height: 130,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_monthlyData.length, (index) {
                final item = _monthlyData[index];
                final isSelected = index == _selectedMonthIndex;
                final inRatio = item['inRatio'] as double;
                final exRatio = item['exRatio'] as double;
                final month = item['month'] as String;

                return GestureDetector(
                  onTap: () => setState(() => _selectedMonthIndex = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: isSelected
                          ? Border.all(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              width: 1,
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Dual Bars: Green (In) & Purple (Ex)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 14,
                              height: 95 * inRatio,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 14,
                              height: 95 * exRatio,
                              decoration: BoxDecoration(
                                color: const Color(0xFFA855F7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          month,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : const Color(0xFF8E95A3),
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w800 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required Color borderColor,
    required Color titleColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF131722),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: const Color(0xFF1E293B),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF8E95A3),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomizeCard() {
    return GestureDetector(
      onTap: _showCustomizeModal,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF131722),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(
                  Icons.tune_rounded,
                  color: Color(0xFF1E293B),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Customize Analytics Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBreakdownSheet(String type, double amount, Color color) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Color(0xFF121620),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Color(0xFF1E2332), width: 1.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF262B36),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$type Breakdown',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: LKR ${_currencyFormat.format(amount)}',
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            _buildBreakdownItem('Salary & Dividends', amount * 0.75, color),
            const SizedBox(height: 10),
            _buildBreakdownItem('Freelance & Side Hustles', amount * 0.25, color),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownItem(String label, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
          Text(
            'LKR ${_currencyFormat.format(amount)}',
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _showAIForecastModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Color(0xFF121620),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Color(0xFF1E2332), width: 1.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF262B36),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 22),
                SizedBox(width: 10),
                Text(
                  'AI Forecast & Projections',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Based on your spending pace, you will finish October with an estimated net surplus of LKR 235,000 (+8% compared to last month).',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showImportModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Color(0xFF121620),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Color(0xFF1E2332), width: 1.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF262B36),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Import Statements',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            _buildDialogTile(Icons.picture_as_pdf_rounded, 'Import Bank PDF Statement'),
            const SizedBox(height: 10),
            _buildDialogTile(Icons.table_chart_rounded, 'Import Excel / CSV Sheet'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showExportModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Color(0xFF121620),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Color(0xFF1E2332), width: 1.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF262B36),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Export Financial Data',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            _buildDialogTile(Icons.picture_as_pdf_rounded, 'Export as PDF Report'),
            const SizedBox(height: 10),
            _buildDialogTile(Icons.table_view_rounded, 'Export as CSV Spreadsheet'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showCustomizeModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Color(0xFF121620),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Color(0xFF1E2332), width: 1.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF262B36),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Customize Dashboard',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            _buildDialogTile(Icons.view_quilt_rounded, 'Rearrange Analytics Widgets'),
            const SizedBox(height: 10),
            _buildDialogTile(Icons.currency_exchange_rounded, 'Currency & Decimal Settings'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogTile(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF262C3D)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
