import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../providers/analytics_provider.dart';

class DashboardWidgetsScreen extends ConsumerWidget {
  const DashboardWidgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final widgetsState = ref.watch(dashboardWidgetsProvider);
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
                        'Dashboard Layout',
                        style: TextStyle(
                          color: AppColors.lightTextPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      ref.read(dashboardWidgetsProvider.notifier).reset();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.white,
                          content: const Text(
                            'Dashboard cards reset to default layout.',
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
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Reset',
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
              const SizedBox(height: 20),

              // Section: Active Dashboard Layout
              const Text(
                'Active Dashboard Layout',
                style: TextStyle(
                  color: AppColors.lightTextPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              // Active Layout Display
              if (widgetsState.activeWidgets.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: const Center(
                    child: Text(
                      'No active cards. Tap + below to add cards to dashboard.',
                      style: TextStyle(
                        color: AppColors.lightTextSecondary,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                _buildActiveCardsLayout(context, ref, widgetsState.activeWidgets),

              const SizedBox(height: 22),

              // Section: Available Widgets to Add
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Available Widgets to Add',
                    style: TextStyle(
                      color: AppColors.lightTextPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Tap + to pin',
                    style: TextStyle(
                      color: AppColors.lightTextSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Available widgets list
              if (widgetsState.availableWidgets.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: const Center(
                    child: Text(
                      'All widgets are currently active on dashboard.',
                      style: TextStyle(
                        color: AppColors.lightTextSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                )
              else
                ...widgetsState.availableWidgets.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.lightBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: item.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              item.icon,
                              color: item.color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                color: AppColors.lightTextPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              ref
                                  .read(dashboardWidgetsProvider.notifier)
                                  .addAvailable(item.id);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: accentColor,
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add,
                                    size: 14,
                                    color: accentColor,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Add',
                                    style: TextStyle(
                                      color: accentColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 24),

              // Save Preferences Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(dashboardWidgetsProvider.notifier).savePreferences();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.white,
                        content: const Text(
                          'Preferences saved successfully.',
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
                    'Save Preferences',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
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

  Widget _buildActiveCardsLayout(
    BuildContext context,
    WidgetRef ref,
    List<DashboardWidgetItem> activeWidgets,
  ) {
    // Separate small summary cards vs large/full cards
    final incomeItem = activeWidgets.where((w) => w.id == 'active_income').firstOrNull;
    final expenseItem = activeWidgets.where((w) => w.id == 'active_expenses').firstOrNull;
    final savingsItem = activeWidgets.where((w) => w.id == 'active_savings').firstOrNull;
    final trendItem = activeWidgets.where((w) => w.id == 'active_trend').firstOrNull;

    // Additional active widgets
    final otherItems = activeWidgets.where((w) =>
        w.id != 'active_income' &&
        w.id != 'active_expenses' &&
        w.id != 'active_savings' &&
        w.id != 'active_trend').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: Income & Expenses side-by-side if active
        if (incomeItem != null || expenseItem != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                if (incomeItem != null)
                  Expanded(
                    child: _buildColouredActiveCard(
                      ref: ref,
                      item: incomeItem,
                      bg: const Color(0xFF98E836),
                      textColor: const Color(0xFF0C0F14),
                    ),
                  ),
                if (incomeItem != null && expenseItem != null)
                  const SizedBox(width: 12),
                if (expenseItem != null)
                  Expanded(
                    child: _buildColouredActiveCard(
                      ref: ref,
                      item: expenseItem,
                      bg: const Color(0xFFF43F5E),
                      textColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ),

        // Row 2: Savings card
        if (savingsItem != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  flex: expenseItem == null && incomeItem == null ? 1 : 1,
                  child: _buildColouredActiveCard(
                    ref: ref,
                    item: savingsItem,
                    bg: const Color(0xFF38BDF8),
                    textColor: const Color(0xFF0C0F14),
                  ),
                ),
                const SizedBox(width: 12),
                const Spacer(),
              ],
            ),
          ),

        // Row 3: Income vs Expenses Trend Card
        if (trendItem != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildTrendActiveCard(context, ref, trendItem),
          ),

        // Other pinned active cards
        ...otherItems.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon, color: item.color, size: 20),
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
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          item.subtitle,
                          style: const TextStyle(
                            color: AppColors.lightTextSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildMinusButton(ref, item.id),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildColouredActiveCard({
    required WidgetRef ref,
    required DashboardWidgetItem item,
    required Color bg,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.grid_view_rounded,
                      size: 13,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      item.title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          _buildMinusButton(ref, item.id),
        ],
      ),
    );
  }

  Widget _buildTrendActiveCard(
    BuildContext context,
    WidgetRef ref,
    DashboardWidgetItem item,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF98E836).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.bar_chart_rounded,
                    color: Color(0xFF98E836),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    color: AppColors.lightTextPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _buildMinusButton(ref, item.id),
            ],
          ),
          const SizedBox(height: 12),
          // Mini chart preview
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.lightSubContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _miniBar(16, const Color(0xFF98E836)),
                    _miniBar(12, const Color(0xFFF43F5E)),
                    const SizedBox(width: 8),
                    _miniBar(20, const Color(0xFF98E836)),
                    _miniBar(15, const Color(0xFFF43F5E)),
                    const SizedBox(width: 8),
                    _miniBar(22, const Color(0xFF98E836)),
                    _miniBar(16, const Color(0xFFF43F5E)),
                    const SizedBox(width: 8),
                    _miniBar(26, const Color(0xFF98E836)),
                    _miniBar(18, const Color(0xFFF43F5E)),
                  ],
                ),
                Row(
                  children: const [
                    Icon(Icons.circle, color: Color(0xFF98E836), size: 7),
                    SizedBox(width: 4),
                    Text(
                      'In',
                      style: TextStyle(
                        color: AppColors.lightTextSecondary,
                        fontSize: 10,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.circle, color: Color(0xFFF43F5E), size: 7),
                    SizedBox(width: 4),
                    Text(
                      'Ex',
                      style: TextStyle(
                        color: AppColors.lightTextSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinusButton(WidgetRef ref, String id) {
    return GestureDetector(
      onTap: () {
        ref.read(dashboardWidgetsProvider.notifier).removeActive(id);
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(
          color: Color(0xFF1E2638),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.remove,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _miniBar(double h, Color color) {
    return Container(
      width: 5,
      height: h,
      margin: const EdgeInsets.only(right: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
