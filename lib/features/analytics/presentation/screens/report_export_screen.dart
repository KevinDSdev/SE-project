import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../services/analytics_period_helper.dart';
import '../../services/export_requirements_validator.dart';
import 'select_export_requirement_screen.dart';

class ReportExportScreen extends ConsumerStatefulWidget {
  const ReportExportScreen({super.key});

  @override
  ConsumerState<ReportExportScreen> createState() => _ReportExportScreenState();
}

class _ReportExportScreenState extends ConsumerState<ReportExportScreen>
    with WidgetsBindingObserver {
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exportPreferencesProvider.notifier).refreshPeriodRollover();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(exportPreferencesProvider.notifier).refreshPeriodRollover();
    }
  }

  Future<void> _pickCustomDateRange(Color accentColor) async {
    final currentStart =
        ref.read(exportPreferencesProvider).startDate ??
        AnalyticsPeriodHelper.now;
    final currentEnd =
        ref.read(exportPreferencesProvider).endDate ??
        AnalyticsPeriodHelper.now;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppColors.getCard(isDark);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDateRange: DateTimeRange(
        start: currentStart,
        end: currentEnd.isBefore(currentStart) ? currentStart : currentEnd,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: accentColor,
                    onPrimary: const Color(0xFF0C0F14),
                    surface: cardBg,
                    onSurface: Colors.white,
                  )
                : ColorScheme.light(
                    primary: accentColor,
                    onPrimary: Colors.white,
                    surface: cardBg,
                    onSurface: const Color(0xFF0C0F14),
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      await ref
          .read(exportPreferencesProvider.notifier)
          .setCustomDateRange(picked.start, picked.end);
    }
  }

  void _showPeriodPicker(Color accentColor) {
    final prefs = ref.read(exportPreferencesProvider);
    final periodType = prefs.periodType;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppColors.getCard(isDark);
    final borderColor = AppColors.getBorder(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final textSecondary = AppColors.getTextSecondary(isDark);

    if (periodType == 'Custom') {
      _pickCustomDateRange(accentColor);
      return;
    }

    final List<PeriodBucket> buckets;
    final String pickerTitle;
    final String pickerSubtitle;

    switch (periodType) {
      case 'Weekly':
        buckets = AnalyticsPeriodHelper.getExportWeeklyBuckets();
        pickerTitle = 'Select Calendar Week';
        pickerSubtitle = 'Latest 6 weeks (Monday to Sunday)';
        break;
      case 'Yearly':
        buckets = AnalyticsPeriodHelper.getExportYearlyBuckets();
        pickerTitle = 'Select Calendar Year';
        pickerSubtitle = 'Latest 6 calendar years';
        break;
      case 'Monthly':
      default:
        buckets = AnalyticsPeriodHelper.getExportMonthlyBuckets();
        pickerTitle = 'Select Calendar Month';
        pickerSubtitle = 'Latest 6 calendar months';
        break;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: borderColor),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pickerTitle,
              style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              pickerSubtitle,
              style: TextStyle(
                color: textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: buckets.reversed.map((bucket) {
              final isSel = prefs.period == bucket.label;
              final isCurrent = bucket == buckets.last;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSel ? accentColor.withValues(alpha: 0.12) : null,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSel
                        ? accentColor
                        : borderColor.withValues(alpha: 0.5),
                  ),
                ),
                child: ListTile(
                  dense: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          bucket.label,
                          style: TextStyle(
                            color: isSel ? accentColor : textPrimary,
                            fontSize: 13.5,
                            fontWeight: isSel
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'CURRENT',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: isSel
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: accentColor,
                          size: 20,
                        )
                      : null,
                  onTap: () {
                    ref
                        .read(exportPreferencesProvider.notifier)
                        .setPeriod(
                          bucket.label,
                          bucket.startDate,
                          bucket.endDate,
                        );
                    Navigator.of(ctx).pop();
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showAccountPicker(Color accentColor) {
    final currentAccount = ref.read(exportPreferencesProvider).account;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppColors.getCard(isDark);
    final borderColor = AppColors.getBorder(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: borderColor),
        ),
        title: Text(
          'Select Account',
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
                'BOC',
                'Commercial Bank',
                'Hatton National Bank',
                'Cash Wallet',
                'All Accounts (Consolidated)',
              ].map((acc) {
                final isSel = currentAccount == acc;
                return ListTile(
                  title: Text(
                    acc,
                    style: TextStyle(
                      color: isSel ? accentColor : textPrimary,
                      fontSize: 14,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  trailing: isSel
                      ? Icon(Icons.check, color: accentColor)
                      : null,
                  onTap: () {
                    ref
                        .read(exportPreferencesProvider.notifier)
                        .setAccount(acc);
                    Navigator.of(ctx).pop();
                  },
                );
              }).toList(),
        ),
      ),
    );
  }

  bool _validateRequirementsBeforeExport(Color accentColor) {
    final prefs = ref.read(exportPreferencesProvider);
    final isValid = ExportRequirementsValidator.hasValidRequirements(
      prefs.selectedRequirements,
    );

    if (!isValid) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final cardBg = AppColors.getCard(isDark);
      final textPrimary = AppColors.getTextPrimary(isDark);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: cardBg,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFF43F5E), width: 1.2),
          ),
          content: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFF43F5E),
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  ExportRequirementsValidator.validationErrorMessage,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          action: SnackBarAction(
            label: 'Select Sections',
            textColor: accentColor,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SelectExportRequirementScreen(),
                ),
              );
            },
          ),
          duration: const Duration(seconds: 4),
        ),
      );
      return false;
    }
    return true;
  }

  void _generateReport(ExportPreferencesState prefs, Color accentColor) async {
    if (!_validateRequirementsBeforeExport(accentColor)) {
      return;
    }
    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _isGenerating = false);

    final ext = prefs.format.contains('PDF')
        ? 'pdf'
        : (prefs.format.contains('Excel') ? 'xlsx' : 'csv');
    final fileName = 'ECORP_Report_${prefs.period.replaceAll(' ', '_')}.$ext';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppColors.getCard(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final textSecondary = AppColors.getTextSecondary(isDark);
    final subContainer = AppColors.getSubContainer(isDark);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: accentColor),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: accentColor, size: 26),
            const SizedBox(width: 10),
            Text(
              'Report Ready',
              style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'File: $fileName',
              style: TextStyle(
                color: accentColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _infoRow(
              'Format',
              prefs.format,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            _infoRow(
              'Scope',
              prefs.period,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            _infoRow(
              'Account',
              prefs.account,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            _infoRow(
              'Included',
              '${prefs.selectedRequirements.length} analytics modules',
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: subContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Demo notice: The report structure has been compiled. In full production, this saves directly to your device downloads folder.',
                style: TextStyle(color: textSecondary, fontSize: 11),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: const Color(0xFF0C0F14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Done',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _shareToWhatsApp(Color accentColor) {
    if (!_validateRequirementsBeforeExport(accentColor)) {
      return;
    }
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
            const Icon(Icons.share_rounded, color: Color(0xFF25D366), size: 24),
            const SizedBox(width: 10),
            Text(
              'Share to WhatsApp',
              style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ready to send generated summary report via WhatsApp.',
              style: TextStyle(color: textPrimary, fontSize: 14),
            ),
            const SizedBox(height: 10),
            Text(
              'Demo notice: In production this will invoke the WhatsApp sharing intent with encrypted attachment.',
              style: TextStyle(color: textSecondary, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: cardBg,
                  content: Text(
                    'WhatsApp share intent simulated.',
                    style: TextStyle(color: textPrimary),
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
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Share Now',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value, {
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: textSecondary, fontSize: 12)),
          Text(
            value,
            style: TextStyle(
              color: textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exportPrefs = ref.watch(exportPreferencesProvider);
    final accentColor = ref.watch(accentColorProvider).color;

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
                    'Export',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Section: CHOOSE EXPORT FORMAT
              Text(
                'CHOOSE EXPORT FORMAT',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    _buildFormatCard(
                      ref: ref,
                      title: 'PDF Report',
                      subtitle: 'Charts & Insights',
                      icon: Icons.picture_as_pdf_rounded,
                      iconColor: const Color(0xFFF43F5E),
                      formatKey: 'PDF Report',
                      selectedFormat: exportPrefs.format,
                      accentColor: accentColor,
                      cardBg: cardBg,
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 10),
                    _buildFormatCard(
                      ref: ref,
                      title: 'Excel (.XLSX)',
                      subtitle: 'Pivots & Ledger',
                      icon: Icons.table_view_rounded,
                      iconColor: const Color(0xFF98E836),
                      formatKey: 'Excel (.XLSX)',
                      selectedFormat: exportPrefs.format,
                      accentColor: accentColor,
                      cardBg: cardBg,
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 10),
                    _buildFormatCard(
                      ref: ref,
                      title: 'Raw Data',
                      subtitle: 'Comma-separated',
                      icon: Icons.description_rounded,
                      iconColor: const Color(0xFF38BDF8),
                      formatKey: 'Raw Data',
                      selectedFormat: exportPrefs.format,
                      accentColor: accentColor,
                      cardBg: cardBg,
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section: EXPORT SCOPE & FILTERS
              Text(
                'EXPORT SCOPE & FILTERS',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: "Time Period" label + Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Time Period',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            exportPrefs.periodType.toUpperCase(),
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 4 Compact Period Option Tabs
                    Row(
                      children: [
                        _buildPeriodTab(
                          label: 'Weekly',
                          icon: Icons.view_week_rounded,
                          isSelected: exportPrefs.periodType == 'Weekly',
                          onTap: () => ref
                              .read(exportPreferencesProvider.notifier)
                              .setPeriodType('Weekly'),
                          accentColor: accentColor,
                          cardBg: cardBg,
                          borderColor: borderColor,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildPeriodTab(
                          label: 'Monthly',
                          icon: Icons.calendar_month_rounded,
                          isSelected: exportPrefs.periodType == 'Monthly',
                          onTap: () => ref
                              .read(exportPreferencesProvider.notifier)
                              .setPeriodType('Monthly'),
                          accentColor: accentColor,
                          cardBg: cardBg,
                          borderColor: borderColor,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildPeriodTab(
                          label: 'Yearly',
                          icon: Icons.calendar_today_rounded,
                          isSelected: exportPrefs.periodType == 'Yearly',
                          onTap: () => ref
                              .read(exportPreferencesProvider.notifier)
                              .setPeriodType('Yearly'),
                          accentColor: accentColor,
                          cardBg: cardBg,
                          borderColor: borderColor,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildPeriodTab(
                          label: 'Custom',
                          icon: Icons.date_range_rounded,
                          isSelected: exportPrefs.periodType == 'Custom',
                          onTap: () {
                            ref
                                .read(exportPreferencesProvider.notifier)
                                .setPeriodType('Custom');
                            _pickCustomDateRange(accentColor);
                          },
                          accentColor: accentColor,
                          cardBg: cardBg,
                          borderColor: borderColor,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isDark: isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Active Selection Card
                    if (exportPrefs.periodType == 'Custom')
                      _buildCustomDateRangeCard(
                        exportPrefs: exportPrefs,
                        accentColor: accentColor,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        isDark: isDark,
                        onTap: () => _pickCustomDateRange(accentColor),
                      )
                    else
                      _buildPeriodDropdownCard(
                        exportPrefs: exportPrefs,
                        accentColor: accentColor,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        isDark: isDark,
                        onTap: () => _showPeriodPicker(accentColor),
                      ),

                    const SizedBox(height: 16),
                    Container(height: 1, color: borderColor),
                    const SizedBox(height: 12),

                    // Accounts Section
                    InkWell(
                      onTap: () => _showAccountPicker(accentColor),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: accentColor.withValues(
                                        alpha: 0.12,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.account_balance_rounded,
                                      color: accentColor,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Accounts',
                                          style: TextStyle(
                                            color: textPrimary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          'Scope of included bank accounts',
                                          style: TextStyle(
                                            color: textSecondary,
                                            fontSize: 11,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      exportPrefs.account,
                                      style: TextStyle(
                                        color: accentColor,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: accentColor,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section: INCLUDED REPORT SECTIONS & DETAILS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'INCLUDED REPORT SECTIONS & DETAILS',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SelectExportRequirementScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: accentColor, width: 1.2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Select Analysis to Export',
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: accentColor,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),

              // Generate & Download Report Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isGenerating
                      ? null
                      : () => _generateReport(exportPrefs, accentColor),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: const Color(0xFF0C0F14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isGenerating
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Color(0xFF0C0F14),
                          ),
                        )
                      : const Text(
                          'Generate & Download Report',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 14),

              // Share to WhatsApp Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => _shareToWhatsApp(accentColor),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textPrimary,
                    backgroundColor: cardBg,
                    side: BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Share to WhatsApp',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormatCard({
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String formatKey,
    required String selectedFormat,
    required Color accentColor,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
  }) {
    final isSelected = selectedFormat == formatKey;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(exportPreferencesProvider.notifier).setFormat(formatKey);
        },
        child: Container(
          height: 112,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: 0.14)
                : (isDark ? const Color(0xFF141820) : cardBg),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? accentColor
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.65)
                        : borderColor),
              width: isSelected ? 1.8 : 1,
            ),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: iconColor, size: 28),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isSelected ? textPrimary : textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isSelected ? accentColor : textSecondary,
                          fontSize: 9.5,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
              if (isSelected)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check,
                        color: Color(0xFF0C0F14),
                        size: 13,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodTab({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color accentColor,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: 0.16)
                : (isDark ? const Color(0xFF141820) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? accentColor : borderColor,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? accentColor : textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? textPrimary : textSecondary,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodDropdownCard({
    required ExportPreferencesState exportPrefs,
    required Color accentColor,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final periodType = exportPrefs.periodType;
    final String subtitle;
    final IconData icon;

    switch (periodType) {
      case 'Weekly':
        subtitle = 'CALENDAR WEEK (MONDAY – SUNDAY)';
        icon = Icons.view_week_rounded;
        break;
      case 'Yearly':
        subtitle = 'CALENDAR YEAR';
        icon = Icons.calendar_today_rounded;
        break;
      case 'Monthly':
      default:
        subtitle = 'CALENDAR MONTH';
        icon = Icons.calendar_month_rounded;
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141820) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    exportPrefs.period,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    'Select',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: accentColor,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomDateRangeCard({
    required ExportPreferencesState exportPrefs,
    required Color accentColor,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final start = exportPrefs.startDate;
    final end = exportPrefs.endDate;
    final startStr = start != null
        ? DateFormat('MMM d, yyyy').format(start)
        : 'Pick start';
    final endStr = end != null
        ? DateFormat('MMM d, yyyy').format(end)
        : 'Pick end';
    final daysCount = (start != null && end != null)
        ? end.difference(start).inDays + 1
        : null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141820) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accentColor.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'START DATE',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 13,
                              color: accentColor,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                startStr,
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: accentColor,
                    size: 18,
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'END DATE',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 13,
                              color: accentColor,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                endStr,
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (daysCount != null)
                  Text(
                    '$daysCount days selected',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                else
                  const SizedBox.shrink(),
                Row(
                  children: [
                    Icon(
                      Icons.edit_calendar_rounded,
                      size: 14,
                      color: accentColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Tap to change dates',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
