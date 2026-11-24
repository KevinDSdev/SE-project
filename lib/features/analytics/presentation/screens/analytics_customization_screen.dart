import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/slide_route.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../models/analytics_customization_preferences.dart';
import '../../providers/analytics_provider.dart';
import '../widgets/analytics_chart_widgets.dart';
import 'categories_customization_screen.dart';
import 'dashboard_widgets_screen.dart';

class AnalyticsCustomizationScreen extends ConsumerStatefulWidget {
  const AnalyticsCustomizationScreen({super.key});

  @override
  ConsumerState<AnalyticsCustomizationScreen> createState() =>
      _AnalyticsCustomizationScreenState();
}

class _AnalyticsCustomizationScreenState
    extends ConsumerState<AnalyticsCustomizationScreen> {
  late ChartVisualMode _draftMainStyle;
  late ChartVisualMode _draftSubTrendStyle;
  late ChartVisualMode _draftSubCategoryStyle;
  late AnalyticsPeriod _draftPeriod;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _draftMainStyle = ref.read(mainChartStyleProvider);
    _draftSubTrendStyle = ref.read(subTrendChartStyleProvider);
    _draftSubCategoryStyle = ref.read(subCategoryChartStyleProvider);
    _draftPeriod = ref.read(savedDefaultPeriodProvider);
  }

  Future<void> _savePreferences(
    Color cardBg,
    Color textPrimary,
    Color accentColor,
  ) async {
    if (_isSaving) return;
    _isSaving = true;

    final preferences = AnalyticsCustomizationPreferences(
      mainChartStyle: _draftMainStyle,
      defaultPeriod: _draftPeriod,
      subTrendChartStyle: _draftSubTrendStyle,
      subCategoryChartStyle: _draftSubCategoryStyle,
    );

    try {
      final repository = ref.read(analyticsCustomizationRepositoryProvider);
      await repository.saveAll(preferences);

      ref.read(mainChartStyleProvider.notifier).syncState(_draftMainStyle);
      ref
          .read(subTrendChartStyleProvider.notifier)
          .syncState(_draftSubTrendStyle);
      ref
          .read(subCategoryChartStyleProvider.notifier)
          .syncState(_draftSubCategoryStyle);
      ref.read(savedDefaultPeriodProvider.notifier).syncState(_draftPeriod);
      ref.read(selectedPeriodProvider.notifier).syncState(_draftPeriod);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: cardBg,
          content: Text(
            'Analytics preferences saved successfully.',
            style: TextStyle(
              color: textPrimary,
              fontSize: 13,
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
      Navigator.of(context).pop();
    } catch (error, stackTrace) {
      debugPrint('Failed to save analytics preferences: $error\n$stackTrace');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: cardBg,
          content: Text(
            'Failed to save analytics preferences. Please try again.',
            style: TextStyle(
              color: textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFF43F5E)),
          ),
        ),
      );
    } finally {
      _isSaving = false;
    }
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
                    'Analytics Customization',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Section 1: Main Dashboard Customization
              Text(
                'Main Dashboard Customization',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
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
                          'Chart Style & Data Grouping',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Visual Mode',
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ChartStylePicker(
                      selected: _draftMainStyle,
                      activeColor: accentColor,
                      onSelected: (mode) {
                        setState(() => _draftMainStyle = mode);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Default Period & Saved Filters Card
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
                    Text(
                      'Default Period & Saved Filters',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: subContainer,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: accentColor, width: 1.2),
                      ),
                      child: Row(
                        children: [
                          _buildPeriodPill(
                            AnalyticsPeriod.weekly,
                            'Weekly',
                            _draftPeriod,
                            accentColor,
                            textSecondary,
                          ),
                          _buildPeriodPill(
                            AnalyticsPeriod.monthly,
                            'Monthly',
                            _draftPeriod,
                            accentColor,
                            textSecondary,
                          ),
                          _buildPeriodPill(
                            AnalyticsPeriod.yearly,
                            'Yearly',
                            _draftPeriod,
                            accentColor,
                            textSecondary,
                          ),
                          _buildPeriodPill(
                            AnalyticsPeriod.custom,
                            'Custom',
                            _draftPeriod,
                            accentColor,
                            textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Section 2: Sub Dashboard Customization
              Text(
                'Sub Dashboard Customization',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
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
                          'Chart Style & Data Grouping',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Overall Trend',
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ChartStylePicker(
                      selected: _draftSubTrendStyle,
                      activeColor: const Color(0xFF38BDF8),
                      onSelected: (mode) {
                        setState(() => _draftSubTrendStyle = mode);
                      },
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Category Breakdown',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ChartStylePicker(
                      selected: _draftSubCategoryStyle,
                      activeColor: accentColor,
                      onSelected: (mode) {
                        setState(() => _draftSubCategoryStyle = mode);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Navigation Card 1: Customize Sectors & Categories
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    slideRoute(
                      const CategoriesCustomizationScreen(
                        initialTab: CustomizationTab.incomeMethods,
                      ),
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
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        'Customize Sectors & Categories',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color: accentColor,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Navigation Card 2: Set Dashboard Layout
              GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .push(slideRoute(const DashboardWidgetsScreen()));
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        'Set Dashboard Layout',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color: accentColor,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Save Preferences Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () =>
                      _savePreferences(cardBg, textPrimary, accentColor),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: const Color(0xFF0C0F14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save Preferences',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodPill(
    AnalyticsPeriod period,
    String label,
    AnalyticsPeriod current,
    Color accentColor,
    Color textSecondary,
  ) {
    final isSel = current == period;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _draftPeriod = period);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSel ? accentColor : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSel ? const Color(0xFF0C0F14) : textSecondary,
                fontSize: 12,
                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
