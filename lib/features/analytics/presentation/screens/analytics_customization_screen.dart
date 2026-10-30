import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/slide_route.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../providers/analytics_provider.dart';
import '../widgets/analytics_chart_widgets.dart';
import 'categories_customization_screen.dart';
import 'dashboard_widgets_screen.dart';

class AnalyticsCustomizationScreen extends ConsumerWidget {
  const AnalyticsCustomizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mainStyle = ref.watch(mainChartStyleProvider);
    final subTrendStyle = ref.watch(subTrendChartStyleProvider);
    final subCategoryStyle = ref.watch(subCategoryChartStyleProvider);
    final selectedPeriod = ref.watch(selectedPeriodProvider);
    final accentColor = ref.watch(accentColorProvider).color;

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
                  const Text(
                    'Analytics Customization',
                    style: TextStyle(
                      color: AppColors.lightTextPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Section 1: Main Dashboard Customization
              const Text(
                'Main Dashboard Customization',
                style: TextStyle(
                  color: AppColors.lightTextPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
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
                          'Chart Style & Data Grouping',
                          style: TextStyle(
                            color: AppColors.lightTextPrimary,
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
                      selected: mainStyle,
                      activeColor: accentColor,
                      onSelected: (mode) {
                        ref.read(mainChartStyleProvider.notifier).setStyle(mode);
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Default Period & Saved Filters',
                      style: TextStyle(
                        color: AppColors.lightTextPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.lightSubContainer,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.lightBorder),
                      ),
                      child: Row(
                        children: [
                          _buildPeriodPill(ref, AnalyticsPeriod.weekly, 'Weekly', selectedPeriod, accentColor),
                          _buildPeriodPill(ref, AnalyticsPeriod.monthly, 'Monthly', selectedPeriod, accentColor),
                          _buildPeriodPill(ref, AnalyticsPeriod.yearly, 'Yearly', selectedPeriod, accentColor),
                          _buildPeriodPill(ref, AnalyticsPeriod.custom, 'Custom', selectedPeriod, accentColor),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Section 2: Sub Dashboard Customization
              const Text(
                'Sub Dashboard Customization',
                style: TextStyle(
                  color: AppColors.lightTextPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
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
                          'Chart Style & Data Grouping',
                          style: TextStyle(
                            color: AppColors.lightTextPrimary,
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
                      selected: subTrendStyle,
                      activeColor: const Color(0xFF38BDF8),
                      onSelected: (mode) {
                        ref.read(subTrendChartStyleProvider.notifier).setStyle(mode);
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Chart Style & Data Grouping',
                          style: TextStyle(
                            color: AppColors.lightTextPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Category Breakdown',
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
                      selected: subCategoryStyle,
                      activeColor: accentColor,
                      onSelected: (mode) {
                        ref.read(subCategoryChartStyleProvider.notifier).setStyle(mode);
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
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Customize Sectors & Categories',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: accentColor,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Navigation Card 2: Want to reorder dashboard cards?
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    slideRoute(const DashboardWidgetsScreen()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.grid_view_rounded,
                            color: accentColor,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Customize Dashboard Layout Cards',
                              style: TextStyle(
                                color: AppColors.lightTextPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Add or remove active dashboard cards',
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.lightTextSecondary,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Save & Apply Customization Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.white,
                        content: const Text(
                          'Analytics customization saved and applied.',
                          style: TextStyle(
                            color: AppColors.lightTextPrimary,
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
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: const Color(0xFF0C0F14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save & Apply Customization',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
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
    WidgetRef ref,
    AnalyticsPeriod period,
    String label,
    AnalyticsPeriod current,
    Color accentColor,
  ) {
    final isSel = current == period;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(selectedPeriodProvider.notifier).setPeriod(period);
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
                color: isSel ? const Color(0xFF0C0F14) : AppColors.lightTextSecondary,
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
