import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/navigation_provider.dart';
import '../../analytics/presentation/analytics_screen.dart';
import 'budget_setup_screen.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  final currencyFormat = NumberFormat('#,##0', 'en_US');

  // Budget progress data matching design
  final double totalIncome = 100000;
  final double totalAssigned = 100000;
  final double totalUsed = 42000;
  final double totalAvailable = 58000;
  final double unassigned = 0;

  @override
  Widget build(BuildContext context) {
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
                      child: const Center(
                        child: Icon(
                          Icons.edit_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Right Button 2: View Transaction History
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
                          Icons.history_rounded,
                          color: AppColors.primary,
                          size: 22,
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
                    // Subtitle: OCTOBER 2026 • ZERO-BASED BUDGET PROGRESS
                    const Center(
                      child: Text(
                        'OCTOBER 2026 • ZERO-BASED BUDGET PROGRESS',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Top Summary Card (Zero-Based Budget Progress)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
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
                          // Header: Total Income & Assigned (Wraps to new line if screen is narrow)
                          SizedBox(
                            width: double.infinity,
                            child: Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                Text(
                                  'Total Income: LKR ${currencyFormat.format(totalIncome)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Assigned: LKR ${currencyFormat.format(totalAssigned)} (100%)',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Full Progress Bar
                          Container(
                            width: double.infinity,
                            height: 7,
                            decoration: BoxDecoration(
                              color: const Color(0xFF222938),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: 1.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 3 Metric Boxes: Total Used, Total Available, Unassigned
                          Row(
                            children: [
                              // Total Used
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1C1917),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFF38281B),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Total Used',
                                        style: TextStyle(
                                          color: Color(0xFFF59E0B),
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'LKR ${currencyFormat.format(totalUsed)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Total Available
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF142416),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFF1E3F22),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Total Available',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'LKR ${currencyFormat.format(totalAvailable)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Unassigned
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF142416),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFF1E3F22),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Unassigned',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'LKR ${currencyFormat.format(unassigned)}',
                                            style: const TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          const Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: AppColors.primary,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Zero-based badge bottom text
                          const Center(
                            child: Text(
                              '✓ ZERO-BASED BUDGET: 100% OF INCOME FULLY ASSIGNED',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Info Callout Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF142416),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Your monthly income is fully allocated. LKR 58,000 remains available across your budget categories.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Section Heading: CATEGORY PROGRESS (5 CATEGORIES)
                    const Text(
                      'CATEGORY PROGRESS (5 CATEGORIES)',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Category Card 1: Bills
                    _buildCategoryCard(
                      title: 'Bills',
                      assigned: 30000,
                      available: 15000,
                      used: 15000,
                      percentSpent: 50,
                      icon: Icons.electric_bolt_rounded,
                      iconColor: const Color(0xFFFBBF24),
                      iconBg: const Color(0xFF222B3D),
                      progressColor: const Color(0xFF38BDF8),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AnalyticsScreen(
                              initialCategory: HistoryCategoryFilter.utilities,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),

                    // Category Card 2: Groceries
                    _buildCategoryCard(
                      title: 'Groceries',
                      assigned: 25000,
                      available: 13000,
                      used: 12000,
                      percentSpent: 48,
                      icon: Icons.shopping_cart_outlined,
                      iconColor: const Color(0xFFF59E0B),
                      iconBg: const Color(0xFF2E2218),
                      progressColor: const Color(0xFFF59E0B),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AnalyticsScreen(
                              initialCategory: HistoryCategoryFilter.groceries,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),

                    // Category Card 3: Transport
                    _buildCategoryCard(
                      title: 'Transport',
                      assigned: 15000,
                      available: 10000,
                      used: 5000,
                      percentSpent: 33,
                      icon: Icons.directions_car_filled_rounded,
                      iconColor: const Color(0xFFEF4444),
                      iconBg: const Color(0xFF1E2838),
                      progressColor: const Color(0xFF38BDF8),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AnalyticsScreen(
                              initialCategory: HistoryCategoryFilter.transport,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),

                    // Category Card 4: Savings
                    _buildCategoryCard(
                      title: 'Savings',
                      assigned: 20000,
                      available: 10000,
                      used: 10000,
                      percentSpent: 50,
                      icon: Icons.account_balance_rounded,
                      iconColor: AppColors.primary,
                      iconBg: const Color(0xFF1E2D18),
                      progressColor: AppColors.primary,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AnalyticsScreen(
                              initialCategory: HistoryCategoryFilter.savings,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),

                    // Category Card 5: Entertainment
                    _buildCategoryCard(
                      title: 'Entertainment',
                      assigned: 10000,
                      available: 10000,
                      used: 0,
                      percentSpent: 0,
                      icon: Icons.movie_creation_outlined,
                      iconColor: const Color(0xFFC084FC),
                      iconBg: const Color(0xFF2C1E38),
                      progressColor: const Color(0xFF222938),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AnalyticsScreen(
                              initialCategory: HistoryCategoryFilter.entertainment,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
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
    required int percentSpent,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required Color progressColor,
    required VoidCallback onTap,
  }) {
    final progress = (used / assigned).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
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
          children: [
          // Row 1: Icon, Title, Assigned & Available Amount
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
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
                      color: AppColors.primary,
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
          const SizedBox(height: 12),

          // Row 2: Progress bar
          Container(
            width: double.infinity,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2432),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Row 3: Used Amount & Percent Spent
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Used: LKR ${currencyFormat.format(used)}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$percentSpent% spent',
                style: TextStyle(
                  color: percentSpent == 0
                      ? AppColors.textSecondary
                      : progressColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}
