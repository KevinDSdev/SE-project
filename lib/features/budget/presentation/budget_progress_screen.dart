import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../core/providers/navigation_provider.dart';
import 'budget_template_selection_screen.dart';
import 'shared_budget_overview_screen.dart';

/// Screen 04 - Budget Progress Display
/// Recreated to match Figma reference image '04 - Budget Progress Display.png'
class BudgetProgressScreen extends ConsumerStatefulWidget {
  final double? totalIncome;
  final double? totalAssigned;
  final double? totalUsed;
  final double? totalAvailable;
  final double? unassigned;

  const BudgetProgressScreen({
    super.key,
    this.totalIncome,
    this.totalAssigned,
    this.totalUsed,
    this.totalAvailable,
    this.unassigned,
  });

  @override
  ConsumerState<BudgetProgressScreen> createState() =>
      _BudgetProgressScreenState();
}

class _BudgetProgressScreenState extends ConsumerState<BudgetProgressScreen> {
  final currencyFormat = NumberFormat('#,##0', 'en_US');

  late double _totalIncome;
  late double _totalAssigned;
  late double _totalUsed;
  late double _totalAvailable;
  late double _unassigned;

  @override
  void initState() {
    super.initState();
    // Default values strictly matching Figma Screen 04
    _totalIncome = widget.totalIncome ?? 100000;
    _totalAssigned = widget.totalAssigned ?? 100000;
    _totalUsed = widget.totalUsed ?? 42000;
    _totalAvailable = widget.totalAvailable ?? 58000;
    _unassigned = widget.unassigned ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = ref.watch(accentColorProvider).color;

    return Scaffold(
      backgroundColor: const Color(0xFF0C0F14),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar with single Back button and centered/left-aligned title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  // Back button '<'
                  GestureDetector(
                    onTap: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        ref.read(selectedTabProvider.notifier).setTab(0);
                      }
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF161922),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF262C38)),
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

                  // Screen Title: "Budget Progress"
                  const Text(
                    'Budget Progress',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Top Summary Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131722),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xFF1E2332),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row: Total Income & Assigned
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Income: LKR ${currencyFormat.format(_totalIncome)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Assigned: LKR ${currencyFormat.format(_totalAssigned)}',
                                style: TextStyle(
                                  color: accentColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Top Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox(
                              height: 8,
                              child: LinearProgressIndicator(
                                value: _totalIncome > 0
                                    ? (_totalUsed / _totalIncome).clamp(0.0, 1.0)
                                    : 0.0,
                                backgroundColor: const Color(0xFF1F2536),
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(accentColor),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 3 Metric Cards: Total Used, Total Available, Unassigned
                          Row(
                            children: [
                              // Metric 1: Total Used (Amber)
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF171A24),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFF59E0B),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Total Used',
                                        style: TextStyle(
                                          color: Color(0xFFF59E0B),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'LKR ${currencyFormat.format(_totalUsed)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Metric 2: Total Available (Lime Green)
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF171A24),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: accentColor,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Total Available',
                                        style: TextStyle(
                                          color: accentColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'LKR ${currencyFormat.format(_totalAvailable)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Metric 3: Unassigned (Coral Red)
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF171A24),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFEF4444),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Unassigned',
                                        style: TextStyle(
                                          color: Color(0xFFEF4444),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'LKR ${currencyFormat.format(_unassigned)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section Header: "CATEGORY PROGRESS (5 CATEGORIES)"
                    const Text(
                      'CATEGORY PROGRESS (5 CATEGORIES)',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 1. Bills
                    _buildCategoryCard(
                      title: 'Bills',
                      assigned: 30000,
                      available: 15000,
                      used: 15000,
                      iconWidget: _buildCardIcon(
                        icon: Icons.receipt_long_rounded,
                        iconColor: const Color(0xFF6366F1),
                        bgColor: Colors.white,
                      ),
                      barColor: const Color(0xFF38BDF8),
                    ),
                    const SizedBox(height: 12),

                    // 2. Groceries
                    _buildCategoryCard(
                      title: 'Groceries',
                      assigned: 25000,
                      available: 13000,
                      used: 12000,
                      iconWidget: _buildCardIcon(
                        icon: Icons.shopping_basket_rounded,
                        iconColor: const Color(0xFFEA580C),
                        bgColor: Colors.white,
                      ),
                      barColor: const Color(0xFFF59E0B),
                    ),
                    const SizedBox(height: 12),

                    // 3. Transport
                    _buildCategoryCard(
                      title: 'Transport',
                      assigned: 15000,
                      available: 10000,
                      used: 5000,
                      iconWidget: _buildCardIcon(
                        icon: Icons.directions_bus_filled_rounded,
                        iconColor: const Color(0xFF0284C7),
                        bgColor: Colors.white,
                      ),
                      barColor: const Color(0xFF38BDF8),
                    ),
                    const SizedBox(height: 12),

                    // 4. Savings
                    _buildCategoryCard(
                      title: 'Savings',
                      assigned: 20000,
                      available: 10000,
                      used: 10000,
                      iconWidget: _buildCardIcon(
                        icon: Icons.savings_rounded,
                        iconColor: const Color(0xFF0D9488),
                        bgColor: Colors.white,
                      ),
                      barColor: accentColor,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Action Buttons matching Screen 04 design: Shared Budget & Budget Templates
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Button 1: Shared Budget
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: const Color(0xFF0C0F14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SharedBudgetOverviewScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Shared Budget',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Button 2: Budget Templates
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: const Color(0xFF0C0F14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const BudgetTemplateSelectionScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Budget Templates',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
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

  Widget _buildCardIcon({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Icon(
          icon,
          color: iconColor,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required double assigned,
    required double available,
    required double used,
    required Widget iconWidget,
    required Color barColor,
  }) {
    final progress = assigned > 0 ? (used / assigned).clamp(0.0, 1.0) : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131722),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF1E2332),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              iconWidget,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Assigned: LKR ${currencyFormat.format(assigned)}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'LKR ${currencyFormat.format(available)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'available',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 6,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFF1F2536),
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
