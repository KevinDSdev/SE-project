import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../services/analytics_period_helper.dart';
import '../widgets/analytics_chart_widgets.dart';

class SpendingAnomalyScreen extends ConsumerStatefulWidget {
  const SpendingAnomalyScreen({super.key});

  @override
  ConsumerState<SpendingAnomalyScreen> createState() =>
      _SpendingAnomalyScreenState();
}

class _SpendingAnomalyScreenState extends ConsumerState<SpendingAnomalyScreen> {
  int _selectedBucketIndex = -1;
  String _selectedFilter = 'Food & grocery';

  final List<String> _filters = [
    'All (4)',
    'Food & grocery',
    'Utilities',
    'Dining',
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
            _buildDetailRow(
              'Category',
              item.category,
              textColor: textPrimary,
              labelColor: textSecondary,
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              'Transaction Date',
              item.date,
              textColor: textPrimary,
              labelColor: textSecondary,
            ),
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
            child: Text('Close', style: TextStyle(color: textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(flaggedTransactionsProvider.notifier)
                  .dismissItem(item.id);
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
        Text(label, style: TextStyle(color: labelColor, fontSize: 13)),
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

    AnalyticsPeriod tempPeriod = ref.read(selectedPeriodProvider);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final buckets = AnalyticsPeriodHelper.getBucketsForPeriod(tempPeriod);

          return AlertDialog(
            backgroundColor: cardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
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
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Period Type Segmented Row: Weekly, Monthly, Yearly
                  Row(
                    children:
                        [
                          AnalyticsPeriod.weekly,
                          AnalyticsPeriod.monthly,
                          AnalyticsPeriod.yearly,
                        ].map((periodType) {
                          final isSelected = tempPeriod == periodType;
                          final typeName = periodType == AnalyticsPeriod.weekly
                              ? 'Weekly'
                              : periodType == AnalyticsPeriod.monthly
                              ? 'Monthly'
                              : 'Yearly';

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  setDialogState(() {
                                    tempPeriod = periodType;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? accentColor
                                        : (isDark
                                              ? Colors.white.withValues(
                                                  alpha: 0.08,
                                                )
                                              : Colors.black.withValues(
                                                  alpha: 0.05,
                                                )),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? accentColor
                                          : borderColor,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      typeName,
                                      style: TextStyle(
                                        color: isSelected
                                            ? const Color(0xFF0C0F14)
                                            : textPrimary,
                                        fontSize: 13,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 8),

                  // Dynamic Bucket List for chosen Type
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: buckets.length,
                      itemBuilder: (ctx, index) {
                        final b = buckets[index];
                        final isSel =
                            (tempPeriod == ref.read(selectedPeriodProvider)) &&
                            ((_selectedBucketIndex == index) ||
                                (_selectedBucketIndex == -1 &&
                                    index == buckets.length - 1));

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          title: Text(
                            b.fullLabel,
                            style: TextStyle(
                              color: isSel ? accentColor : textPrimary,
                              fontSize: 14,
                              fontWeight: isSel
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                          trailing: isSel
                              ? Icon(
                                  Icons.check_circle,
                                  color: accentColor,
                                  size: 20,
                                )
                              : null,
                          onTap: () {
                            ref
                                .read(selectedPeriodProvider.notifier)
                                .setPeriod(tempPeriod);
                            setState(() {
                              _selectedBucketIndex = index;
                            });
                            Navigator.of(ctx).pop();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnomalyVerticalBarChart({
    required List<PeriodBucket> buckets,
    required int activeIndex,
    required List<double> values,
    required double maxVal,
    required List<String> yLabels,
    required Color accentColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    const double height = 155;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            height: height - 34,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: yLabels
                  .map(
                    (lbl) => Text(
                      lbl,
                      style: const TextStyle(
                        color: Color(0xFFB0B7C3),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(buckets.length, (index) {
                      final isSelected = index == activeIndex;
                      final val = index < values.length ? values[index] : 0.0;
                      final barH = (val / maxVal) * (height - 58);
                      final formattedVal = val
                          .toInt()
                          .toString()
                          .replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (m) => '${m[1]},',
                          );

                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            setState(() {
                              _selectedBucketIndex = index;
                            });
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                formattedVal,
                                style: TextStyle(
                                  color: isSelected
                                      ? accentColor
                                      : Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: buckets.length > 4 ? 30 : 44,
                                height: barH.clamp(22, height - 58),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? accentColor
                                      : const Color(0xFF38BDF8),
                                  borderRadius: BorderRadius.circular(6),
                                  border: isSelected
                                      ? Border.all(
                                          color: Colors.white,
                                          width: 2.0,
                                        )
                                      : null,
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: accentColor.withValues(
                                              alpha: 0.4,
                                            ),
                                            blurRadius: 6,
                                            spreadRadius: 1,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(buckets.length, (index) {
                    final isSelected = index == activeIndex;
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() {
                            _selectedBucketIndex = index;
                          });
                        },
                        child: Center(
                          child: Text(
                            buckets[index].label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected
                                  ? accentColor
                                  : const Color(0xFFB0B7C3),
                              fontSize: buckets.length > 4 ? 12 : 11,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = ref.watch(accentColorProvider).color;
    final flaggedList = ref
        .watch(flaggedTransactionsProvider)
        .where((item) => !item.isDismissed)
        .toList();
    final count = flaggedList.length;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = AppColors.getBg(isDark);
    final cardBg = AppColors.getCard(isDark);
    final borderColor = AppColors.getBorder(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final textSecondary = AppColors.getTextSecondary(isDark);
    final subContainer = AppColors.getSubContainer(isDark);

    final selectedPeriod = ref.watch(selectedPeriodProvider);
    final buckets = AnalyticsPeriodHelper.getBucketsForPeriod(selectedPeriod);
    final activeIndex =
        (_selectedBucketIndex >= 0 && _selectedBucketIndex < buckets.length)
        ? _selectedBucketIndex
        : (buckets.length - 1);
    final activeBucket = buckets[activeIndex];

    // Period-dependent data
    final List<double> spikeLineValues;
    final String spikeHeaderAmount;
    final List<double> anomalyBarValues;
    final double anomalyMaxVal;
    final List<String> anomalyYLabels;
    final String anomalyCardTotal;
    final String baselineNormalText;
    final String actualSpendText;

    switch (selectedPeriod) {
      case AnalyticsPeriod.weekly:
        spikeHeaderAmount = 'LKR 45,000';
        spikeLineValues = const [32000, 36000, 34000, 45000];
        anomalyCardTotal = 'LKR 30,000';
        anomalyBarValues = const [15000, 22000, 18000, 30000];
        anomalyMaxVal = 35000;
        anomalyYLabels = const ['30k', '20k', '10k'];
        baselineNormalText = 'LKR 65,000';
        actualSpendText = 'LKR 83,500';
        break;
      case AnalyticsPeriod.yearly:
        spikeHeaderAmount = 'LKR 2,000,000';
        spikeLineValues = const [
          900000,
          1050000,
          1200000,
          1400000,
          1650000,
          2000000,
        ];
        anomalyCardTotal = 'LKR 1,500,000';
        anomalyBarValues = const [
          120000,
          150000,
          180000,
          220000,
          250000,
          310000,
        ];
        anomalyMaxVal = 350000;
        anomalyYLabels = const ['300k', '200k', '100k'];
        baselineNormalText = 'LKR 3,400,000';
        actualSpendText = 'LKR 3,822,000';
        break;
      case AnalyticsPeriod.monthly:
      default:
        spikeHeaderAmount = 'LKR 200,000';
        spikeLineValues = const [
          120000,
          125000,
          124000,
          145000,
          138000,
          200000,
        ];
        anomalyCardTotal = 'LKR 142,000';
        anomalyBarValues = const [20000, 25000, 15000, 27000, 25000, 30000];
        anomalyMaxVal = 35000;
        anomalyYLabels = const ['30k', '20k', '10k'];
        baselineNormalText = 'LKR 280,000';
        actualSpendText = 'LKR 300,000';
        break;
    }

    final chartLabels = buckets.map((b) => b.label).toList();

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
                        activeBucket.fullLabel,
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
              const SizedBox(height: 16),

              // 1. Top Spike Line Chart Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF281519) : cardBg,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFFF43F5E),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      spikeHeaderAmount,
                      style: const TextStyle(
                        color: Color(0xFFFF5C6C),
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CurvedTrendLineChart(
                      labels: chartLabels,
                      values: spikeLineValues,
                      lineColor: const Color(0xFFF43F5E),
                      selectedIndex: activeIndex,
                      height: 120,
                      valueFormatter: (v) => '',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 2. Filter Chips Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _filters.map((filter) {
                    final isSel = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFilter = filter),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFFFF6464) : cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSel
                                  ? const Color(0xFFFF6464)
                                  : borderColor,
                            ),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              color: isSel
                                  ? const Color(0xFF0C0F14)
                                  : textSecondary,
                              fontSize: 12.5,
                              fontWeight: isSel
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),

              // 3. Food & Grocery - Anomaly Bar Chart Card
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
                      'Food & Grocery - Anomaly',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      anomalyCardTotal,
                      style: const TextStyle(
                        color: Color(0xFFFF6464),
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildAnomalyVerticalBarChart(
                      buckets: buckets,
                      activeIndex: activeIndex,
                      values: anomalyBarValues,
                      maxVal: anomalyMaxVal,
                      yLabels: anomalyYLabels,
                      accentColor: accentColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 4. Period Badge (e.g. 'Month - October', 'Week - Nov 1–7', 'Year - 2026')
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  activeBucket.badgeLabel,
                  style: const TextStyle(
                    color: Color(0xFF0C0F14),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 5. Anomalies Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
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
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF43F5E),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'LKR 30,000 Spike',
                            style: TextStyle(
                              color: Color(0xFF0C0F14),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: subContainer,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.5)
                              : borderColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Normal Baseline',
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  baselineNormalText,
                                  style: const TextStyle(
                                    color: Color(0xFF38BDF8),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 32,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.35)
                                : borderColor,
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${activeBucket.label} Actual Spend',
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  actualSpendText,
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
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
              const SizedBox(height: 12),

              // 6. Flagged Transactions Section Card
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
                            ref
                                .read(flaggedTransactionsProvider.notifier)
                                .dismissAll();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'All flagged transactions dismissed.',
                                ),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Dismiss',
                              style: TextStyle(
                                color: Color(0xFF0C0F14),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
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
                        final isCeb =
                            item.title.contains('Electricity') ||
                            item.title.contains('CEB');
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GestureDetector(
                            onTap: () => _showTransactionDetails(item),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: subContainer,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: borderColor.withValues(alpha: 0.6),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        isCeb
                                            ? Icons.wb_sunny_rounded
                                            : Icons.local_pizza_rounded,
                                        color: isCeb
                                            ? const Color(0xFFD97706)
                                            : const Color(0xFFDC2626),
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
                                      color: Color(0xFFFF5C6C),
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
