import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../providers/analytics_provider.dart';

class DashboardWidgetsScreen extends ConsumerStatefulWidget {
  const DashboardWidgetsScreen({super.key});

  @override
  ConsumerState<DashboardWidgetsScreen> createState() =>
      _DashboardWidgetsScreenState();
}

class _DashboardWidgetsScreenState
    extends ConsumerState<DashboardWidgetsScreen> {
  late List<DashboardWidgetItem> _draftActive;
  late List<DashboardWidgetItem> _draftAvailable;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final current = ref.read(dashboardWidgetsProvider);
    _draftActive = [...current.activeWidgets];
    _draftAvailable = [...current.availableWidgets];
  }

  Future<void> _savePreferences(
    Color cardBg,
    Color textPrimary,
    Color accentColor,
  ) async {
    if (_isSaving) return;
    _isSaving = true;

    final activeIds = _draftActive.map((item) => item.id).toList();

    try {
      final repository = ref.read(dashboardLayoutRepositoryProvider);
      final saved = await repository.saveActiveCardIds(activeIds);

      ref
          .read(dashboardWidgetsProvider.notifier)
          .syncState(saved.activeCardIds);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: cardBg,
          content: Text(
            'Preferences saved successfully.',
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
      debugPrint(
        'Failed to save dashboard layout preferences: $error\n$stackTrace',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: cardBg,
          content: Text(
            'Failed to save dashboard layout. Please try again.',
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

  void _removeActive(String id) {
    final index = _draftActive.indexWhere((w) => w.id == id);
    if (index == -1) return;
    setState(() {
      final item = _draftActive.removeAt(index);
      _draftAvailable.add(item);
    });
  }

  void _addAvailable(String id) {
    final index = _draftAvailable.indexWhere((w) => w.id == id);
    if (index == -1) return;
    setState(() {
      final item = _draftAvailable.removeAt(index);
      _draftActive.add(item);
    });
  }

  void _resetDraft() {
    final def = ref.read(dashboardWidgetsProvider.notifier).defaultState;
    setState(() {
      _draftActive = [...def.activeWidgets];
      _draftAvailable = [...def.availableWidgets];
    });
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
                        'Dashboard Layout',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      _resetDraft();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: cardBg,
                          content: Text(
                            'Reset to default layout. Tap Save Preferences to apply.',
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
              Text(
                'Active Dashboard Layout',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              // Active Layout Display
              if (_draftActive.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: borderColor),
                  ),
                  child: Center(
                    child: Text(
                      'No active cards. Tap + below to add cards to dashboard.',
                      style: TextStyle(color: textSecondary, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                _buildActiveCardsLayout(
                  context,
                  _draftActive,
                  cardBg,
                  borderColor,
                  textPrimary,
                  textSecondary,
                  subContainer,
                  accentColor,
                ),

              const SizedBox(height: 22),

              // Section: Available Analytics to Add
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Analytics to Add',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Tap + to pin',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Available Analytics Dashboard Cards list
              if (_draftAvailable.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Center(
                    child: Text(
                      'All Analytics Dashboard Cards are currently active',
                      style: TextStyle(color: textSecondary, fontSize: 13),
                    ),
                  ),
                )
              else
                ..._draftAvailable.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Icon(item.icon, color: item.color, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _addAvailable(item.id),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: accentColor,
                                  width: 1.2,
                                ),
                              ),
                              child: Text(
                                '+ Add',
                                style: TextStyle(
                                  color: accentColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveCardsLayout(
    BuildContext context,
    List<DashboardWidgetItem> activeWidgets,
    Color cardBg,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color subContainer,
    Color accentColor,
  ) {
    final incomeItem = activeWidgets
        .where((w) => w.id == 'active_income')
        .firstOrNull;
    final expenseItem = activeWidgets
        .where((w) => w.id == 'active_expenses')
        .firstOrNull;
    final savingsItem = activeWidgets
        .where((w) => w.id == 'active_savings')
        .firstOrNull;
    final trendItem = activeWidgets
        .where((w) => w.id == 'active_trend')
        .firstOrNull;

    final otherItems = activeWidgets
        .where(
          (w) =>
              w.id != 'active_income' &&
              w.id != 'active_expenses' &&
              w.id != 'active_savings' &&
              w.id != 'active_trend',
        )
        .toList();

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
                      item: expenseItem,
                      bg: const Color(0xFFF43F5E),
                      textColor: const Color(0xFF0C0F14),
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
                  child: _buildColouredActiveCard(
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
            child: _buildTrendActiveCard(
              trendItem,
              cardBg,
              borderColor,
              textPrimary,
              textSecondary,
              subContainer,
              accentColor,
            ),
          ),

        // Other pinned active cards
        ...otherItems.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: item.color.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
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
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          item.subtitle,
                          style: TextStyle(color: textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  _buildMinusButton(item.id),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildColouredActiveCard({
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.drag_indicator_rounded,
                    size: 16,
                    color: textColor.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item.title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              _buildMinusButton(item.id),
            ],
          ),
          const SizedBox(height: 8),
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
    );
  }

  Widget _buildTrendActiveCard(
    DashboardWidgetItem item,
    Color cardBg,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color subContainer,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: accentColor.withValues(alpha: 0.4)),
                ),
                child: Center(
                  child: Icon(
                    Icons.drag_indicator_rounded,
                    color: accentColor,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _buildMinusButton(item.id),
            ],
          ),
          const SizedBox(height: 12),
          // Mini chart preview
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: subContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _miniBar(22, const Color(0xFF98E836)),
                    _miniBar(16, const Color(0xFFF43F5E)),
                    const SizedBox(width: 12),
                    _miniBar(26, const Color(0xFF98E836)),
                    _miniBar(18, const Color(0xFFF43F5E)),
                    const SizedBox(width: 12),
                    _miniBar(28, const Color(0xFF98E836)),
                    _miniBar(15, const Color(0xFFF43F5E)),
                    const SizedBox(width: 12),
                    _miniBar(34, const Color(0xFF98E836)),
                    _miniBar(20, const Color(0xFFF43F5E)),
                    const SizedBox(width: 12),
                    _miniBar(30, const Color(0xFF98E836)),
                    _miniBar(20, const Color(0xFFF43F5E)),
                    const SizedBox(width: 12),
                    _miniBar(38, const Color(0xFF98E836)),
                    _miniBar(22, const Color(0xFFF43F5E)),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            color: Color(0xFF98E836),
                            size: 7,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'In',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            color: Color(0xFFF43F5E),
                            size: 7,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Ex',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinusButton(String id) {
    return GestureDetector(
      key: ValueKey('remove_card_$id'),
      onTap: () => _removeActive(id),
      child: Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: Color(0xFF1E2638),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(Icons.remove, color: Colors.white, size: 16),
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
