import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../core/providers/navigation_provider.dart';
import '../../analytics/presentation/analytics_screen.dart';
import 'budget_setup_screen.dart';

class BudgetProgressScreen extends ConsumerStatefulWidget {
  const BudgetProgressScreen({super.key});

  @override
  ConsumerState<BudgetProgressScreen> createState() => _BudgetProgressScreenState();
}

class _BudgetProgressScreenState extends ConsumerState<BudgetProgressScreen> {
  final currencyFormat = NumberFormat('#,##0', 'en_US');

  // Budget progress data matching design
  final double totalIncome = 100000;
  final double totalAssigned = 100000;
  final double totalUsed = 42000;
  final double totalAvailable = 58000;
  final double unassigned = 0;

  @override
  Widget build(BuildContext context) {
    final accentColor = ref.watch(accentColorProvider).color;
    return Scaffold(
      backgroundColor: const Color(0xFF0C0F14),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar with TWO buttons on top right
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  // Back button
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
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),

                  // Title: "Budget Progress"
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Budget Progress',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  // Right Button 1: Edit Budget
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const BudgetSetupScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF161922),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.edit_outlined,
                          color: accentColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Right Button 2: Analytics Link
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AnalyticsScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF161922),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.bar_chart_rounded,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
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
                    const SizedBox(height: 4),

                    // Subtitle: OCTOBER 2026 • ZERO-BASED BUDGET PROGRESS
                    Center(
                      child: Text(
                        'OCTOBER 2026 • ZERO-BASED BUDGET PROGRESS',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Top Summary Card (Zero-Based Budget Progress)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131722),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFF1E2332),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total Income',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'LKR ${currencyFormat.format(totalIncome)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'Assigned Budget',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'LKR ${currencyFormat.format(totalAssigned)}',
                                    style: TextStyle(
                                      color: accentColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              height: 10,
                              child: LinearProgressIndicator(
                                value: totalUsed / totalIncome,
                                backgroundColor: const Color(0xFF1F2536),
                                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // 3 Metric Pills
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF191D2A),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFF262E42),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Total Used',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'LKR ${currencyFormat.format(totalUsed)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF191D2A),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: accentColor.withValues(alpha: 0.35),
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
                                      const SizedBox(height: 4),
                                      Text(
                                        'LKR ${currencyFormat.format(totalAvailable)}',
                                        style: TextStyle(
                                          color: accentColor,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF191D2A),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFF262E42),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Unassigned',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'LKR ${currencyFormat.format(unassigned)}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                        ),
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

                    // Category Progress Header
                    const Text(
                      'CATEGORY PROGRESS (5 CATEGORIES)',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Category Cards
                    _buildCategoryCard(
                      title: 'Bills',
                      assigned: 30000,
                      available: 15000,
                      used: 15000,
                      icon: Icons.receipt_long_rounded,
                      barColor: const Color(0xFF38BDF8),
                      iconColor: const Color(0xFF38BDF8),
                      bgColor: const Color(0xFF162738),
                    ),
                    const SizedBox(height: 12),

                    _buildCategoryCard(
                      title: 'Groceries',
                      assigned: 25000,
                      available: 13000,
                      used: 12000,
                      icon: Icons.shopping_basket_rounded,
                      barColor: const Color(0xFFF59E0B),
                      iconColor: const Color(0xFFF59E0B),
                      bgColor: const Color(0xFF2E2218),
                    ),
                    const SizedBox(height: 12),

                    _buildCategoryCard(
                      title: 'Transport',
                      assigned: 15000,
                      available: 10000,
                      used: 5000,
                      icon: Icons.directions_car_rounded,
                      barColor: const Color(0xFF38BDF8),
                      iconColor: const Color(0xFF38BDF8),
                      bgColor: const Color(0xFF162738),
                    ),
                    const SizedBox(height: 12),

                    _buildCategoryCard(
                      title: 'Savings',
                      assigned: 20000,
                      available: 10000,
                      used: 10000,
                      icon: Icons.savings_rounded,
                      barColor: accentColor,
                      iconColor: accentColor,
                      bgColor: const Color(0xFF142416),
                    ),
                    const SizedBox(height: 24),

                    // Zero-Based Budget Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131722),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFF1E2332),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: accentColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '✓ ZERO-BASED BUDGET: 100% ASSIGNED',
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Your income is fully allocated across categories.',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required double assigned,
    required double available,
    required double used,
    required IconData icon,
    required Color barColor,
    required Color iconColor,
    required Color bgColor,
  }) {
    final progress = (used / assigned).clamp(0.0, 1.0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
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
