import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../providers/analytics_provider.dart';
import '../widgets/analytics_chart_widgets.dart';

class SpendingAnomalyScreen extends ConsumerStatefulWidget {
  const SpendingAnomalyScreen({super.key});

  @override
  ConsumerState<SpendingAnomalyScreen> createState() =>
      _SpendingAnomalyScreenState();
}

class _SpendingAnomalyScreenState extends ConsumerState<SpendingAnomalyScreen> {
  String _selectedPeriodLabel = 'Monthly : 2026';

  final List<String> _months = ['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'];
  final List<double> _spikeLineValues = [
    120000,
    125000,
    124000,
    145000,
    138000,
    200000
  ];

  void _showTransactionDetails(FlaggedTransactionItem item) {
    final accentColor = ref.read(accentColorProvider).color;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppColors.getCard(isDark);
    final borderColor = AppColors.getBorder(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final textSecondary = AppColors.getTextSecondary(isDark);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: borderColor),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF43F5E).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFF43F5E),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Category', item.category, textColor: textPrimary, labelColor: textSecondary),
            const SizedBox(height: 10),
            _buildDetailRow('Transaction Date', item.date, textColor: textPrimary, labelColor: textSecondary),
            const SizedBox(height: 10),
            _buildDetailRow(
              '6-Month Baseline',
              'LKR ${item.baseline.toInt()}',
              valueColor: const Color(0xFF0284C7),
              textColor: textPrimary,
              labelColor: textSecondary,
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              'Oct Actual Charged',
              'LKR ${item.amount.toInt()}',
              valueColor: const Color(0xFFF43F5E),
              textColor: textPrimary,
              labelColor: textSecondary,
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              'Detected Spike',
              '+LKR ${(item.amount - item.baseline).toInt()} (+${(((item.amount - item.baseline) / item.baseline) * 100).toStringAsFixed(0)}%)',
              valueColor: const Color(0xFFF43F5E),
              isBold: true,
              textColor: textPrimary,
              labelColor: textSecondary,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Close',
              style: TextStyle(color: textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(flaggedTransactionsProvider.notifier).dismissItem(item.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: cardBg,
                  content: Text(
                    'Marked "${item.title}" as reviewed.',
                    style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: accentColor),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: const Color(0xFF0C0F14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Mark Reviewed',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
    required Color textColor,
    required Color labelColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? textColor,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showPeriodPicker() {
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
              trailing: _selectedPeriodLabel == period
                  ? Icon(Icons.check, color: accentColor)
                  : null,
              onTap: () {
                setState(() => _selectedPeriodLabel = period);
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
    final flaggedList = ref.watch(flaggedTransactionsProvider);
    final count = flaggedList.length;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = AppColors.getBg(isDark);
    final cardBg = AppColors.getCard(isDark);
    final borderColor = AppColors.getBorder(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final textSecondary = AppColors.getTextSecondary(isDark);
    final subContainer = AppColors.getSubContainer(isDark);

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
                        'Anomaly Analysis',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: _showPeriodPicker,
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
                        _selectedPeriodLabel,
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

              Text(
                'Unusual Spendings',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              // Overview Metric Card
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
                          '$count Anomalies',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF43F5E),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'LKR 49,700 Spike',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: subContainer,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '6-Mo Normal Avg',
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'LKR 289,300',
                                  style: TextStyle(
                                    color: Color(0xFF0284C7),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 34,
                            color: borderColor,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Oct Actual Spend',
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'LKR 339,000',
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Spike Line Chart Card
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
                      'LKR 200,000',
                      style: TextStyle(
                        color: Color(0xFFE11D48),
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CurvedTrendLineChart(
                      labels: _months,
                      values: _spikeLineValues,
                      lineColor: const Color(0xFFF43F5E),
                      selectedIndex: 5,
                      valueFormatter: (v) => '',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Category Baseline vs. Actual Card
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
                          'Category Spike Breakdown',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.circle, color: Color(0xFF38BDF8), size: 8),
                            const SizedBox(width: 4),
                            Text(
                              'Baseline',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.circle, color: Color(0xFFF43F5E), size: 8),
                            const SizedBox(width: 4),
                            Text(
                              'Oct Spend',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const AnomalyComparisonBar(
                      category: 'Shopping',
                      baseline: 25000,
                      actual: 74700,
                      baselineLabel: 'LKR 25K',
                      actualLabel: 'LKR 74.7K (+198%)',
                    ),
                    const SizedBox(height: 14),
                    const AnomalyComparisonBar(
                      category: 'Dining Out',
                      baseline: 30000,
                      actual: 48000,
                      baselineLabel: 'LKR 30K',
                      actualLabel: 'LKR 48K (+60%)',
                    ),
                    const SizedBox(height: 14),
                    const AnomalyComparisonBar(
                      category: 'Utilities',
                      baseline: 28000,
                      actual: 31000,
                      baselineLabel: 'LKR 28K',
                      actualLabel: 'LKR 31K (+10%)',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Flagged Transactions Section Card (matching 14. Spending Anomaly Analysis.png)
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
                          'Flagged Transactions',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            ref.read(flaggedTransactionsProvider.notifier).dismissAll();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('All flagged transactions dismissed.'),
                                backgroundColor: cardBg,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: accentColor),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'Dismiss',
                              style: TextStyle(
                                color: Color(0xFF0C0F14),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (flaggedList.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'All flagged transactions have been reviewed.',
                            style: TextStyle(color: textSecondary),
                          ),
                        ),
                      )
                    else
                      ...flaggedList.map((item) {
                        final isCeb = item.title.contains('Electricity') || item.title.contains('CEB');
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GestureDetector(
                            onTap: () => _showTransactionDetails(item),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: subContainer,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: borderColor.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: isCeb ? const Color(0xFFFEF3C7) : const Color(0xFFFEE2E2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        isCeb ? Icons.bolt_rounded : Icons.local_pizza_rounded,
                                        color: isCeb ? const Color(0xFFD97706) : const Color(0xFFDC2626),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: TextStyle(
                                        color: textPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'LKR ${item.amount.toInt().toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}',
                                    style: const TextStyle(
                                      color: Color(0xFFF43F5E),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
}
