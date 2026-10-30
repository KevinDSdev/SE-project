import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppColors.lightBorder),
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
                style: const TextStyle(
                  color: AppColors.lightTextPrimary,
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
            _buildDetailRow('Category', item.category),
            const SizedBox(height: 10),
            _buildDetailRow('Transaction Date', item.date),
            const SizedBox(height: 10),
            _buildDetailRow(
              '6-Month Baseline',
              'LKR ${item.baseline.toInt()}',
              valueColor: const Color(0xFF0284C7),
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              'Oct Actual Charged',
              'LKR ${item.amount.toInt()}',
              valueColor: const Color(0xFFF43F5E),
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              'Detected Spike',
              '+LKR ${(item.amount - item.baseline).toInt()} (+${(((item.amount - item.baseline) / item.baseline) * 100).toStringAsFixed(0)}%)',
              valueColor: const Color(0xFFF43F5E),
              isBold: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.lightTextSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(flaggedTransactionsProvider.notifier).dismissItem(item.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.white,
                  content: Text(
                    'Marked "${item.title}" as reviewed.',
                    style: const TextStyle(
                      color: AppColors.lightTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFF98E836)),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF98E836),
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
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.lightTextSecondary,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.lightTextPrimary,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showPeriodPicker() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
        title: const Text(
          'Select Period',
          style: TextStyle(
            color: AppColors.lightTextPrimary,
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
                style: const TextStyle(
                  color: AppColors.lightTextPrimary,
                  fontSize: 14,
                ),
              ),
              trailing: _selectedPeriodLabel == period
                  ? const Icon(Icons.check, color: Color(0xFF98E836))
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
    final flaggedList = ref.watch(flaggedTransactionsProvider);
    final count = flaggedList.length;

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
                      const Text(
                        'Spending Anomaly Analysis',
                        style: TextStyle(
                          color: AppColors.lightTextPrimary,
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
                        color: const Color(0xFF98E836),
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

              // Overview Metric Card
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
                    const Text(
                      'Unusual Spendings',
                      style: TextStyle(
                        color: AppColors.lightTextSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$count Anomalies',
                          style: const TextStyle(
                            color: AppColors.lightTextPrimary,
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
                        color: AppColors.lightSubContainer,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.lightBorder),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  '6-Mo Normal Avg',
                                  style: TextStyle(
                                    color: AppColors.lightTextSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
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
                            color: AppColors.lightBorder,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Oct Actual Spend',
                                  style: TextStyle(
                                    color: AppColors.lightTextSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'LKR 339,000',
                                  style: TextStyle(
                                    color: AppColors.lightTextPrimary,
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
                  color: Colors.white,
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
                        const Text(
                          'Category Spike Breakdown',
                          style: TextStyle(
                            color: AppColors.lightTextPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: const [
                            Icon(Icons.circle, color: Color(0xFF38BDF8), size: 8),
                            SizedBox(width: 4),
                            Text(
                              'Baseline',
                              style: TextStyle(
                                color: AppColors.lightTextSecondary,
                                fontSize: 10,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.circle, color: Color(0xFFF43F5E), size: 8),
                            SizedBox(width: 4),
                            Text(
                              'Oct Spend',
                              style: TextStyle(
                                color: AppColors.lightTextSecondary,
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

              // Flagged Transactions Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Flagged Transactions',
                    style: TextStyle(
                      color: AppColors.lightTextPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '$count detected',
                    style: const TextStyle(
                      color: Color(0xFFE11D48),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (flaggedList.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: const Center(
                    child: Text(
                      'All flagged transactions have been reviewed.',
                      style: TextStyle(color: AppColors.lightTextSecondary),
                    ),
                  ),
                )
              else
                ...flaggedList.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => _showTransactionDetails(item),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFF43F5E).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF43F5E).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFFF43F5E),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      color: AppColors.lightTextPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item.date} • ${item.category}',
                                    style: const TextStyle(
                                      color: AppColors.lightTextSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'LKR ${item.amount.toInt()}',
                                  style: const TextStyle(
                                    color: Color(0xFFE11D48),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '+${(((item.amount - item.baseline) / item.baseline) * 100).toStringAsFixed(0)}% spike',
                                  style: const TextStyle(
                                    color: AppColors.lightTextSecondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
