import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../settings/providers/settings_provider.dart';
import '../models/shared_budget_model.dart';
import '../providers/shared_budget_provider.dart';
import 'create_shared_budget_screen.dart';
import 'shared_budget_members_screen.dart';

/// Screen 06A – Shared Budget Overview
/// Faithfully reproduces Figma Screen 06A from "06A - Shared Budget Overview.png"
class SharedBudgetOverviewScreen extends ConsumerStatefulWidget {
  final SharedBudget? initialBudget;

  const SharedBudgetOverviewScreen({
    super.key,
    this.initialBudget,
  });

  @override
  ConsumerState<SharedBudgetOverviewScreen> createState() =>
      _SharedBudgetOverviewScreenState();
}

class _SharedBudgetOverviewScreenState
    extends ConsumerState<SharedBudgetOverviewScreen> {
  final currencyFormat = NumberFormat('#,##0', 'en_US');

  @override
  Widget build(BuildContext context) {
    final accentColor = ref.watch(accentColorProvider).color;
    final SharedBudget sharedBudget =
        widget.initialBudget ?? ref.watch(sharedBudgetProvider);

    final progress = sharedBudget.totalSharedFunds > 0
        ? (sharedBudget.totalUsed / sharedBudget.totalSharedFunds)
            .clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0C0F14),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  // Back button '<'
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
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

                  // Title: "Shared Budgets"
                  const Text(
                    'Shared Budgets',
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

            // Main Scrollable Area
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Top Hero Card: Shared Budget Summary
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
                          // Header: Title & Members Pill
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sharedBudget.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      sharedBudget.goal.startsWith('Goal:')
                                          ? sharedBudget.goal
                                          : 'Goal: ${sharedBudget.goal}',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF132030),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFF38BDF8),
                                    width: 1.2,
                                  ),
                                ),
                                child: Text(
                                  '${sharedBudget.members.length} Members',
                                  style: const TextStyle(
                                    color: Color(0xFF38BDF8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox(
                              height: 8,
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: const Color(0xFF1F2536),
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(accentColor),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 3 Metric Pills
                          Row(
                            children: [
                              // Metric 1: Shared Funds (Lime green)
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
                                        'Shared Funds',
                                        style: TextStyle(
                                          color: accentColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'LKR ${currencyFormat.format(sharedBudget.totalSharedFunds)}',
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

                              // Metric 2: Total Used (Amber)
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
                                        'LKR ${currencyFormat.format(sharedBudget.totalUsed)}',
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

                              // Metric 3: Total Available (Coral Red)
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
                                        'Total Available',
                                        style: TextStyle(
                                          color: Color(0xFFEF4444),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'LKR ${currencyFormat.format(sharedBudget.totalAvailable)}',
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

                    // Section Header: SHARED CATEGORIES (X CATEGORIES)
                    Text(
                      'SHARED CATEGORIES (${sharedBudget.categories.length} CATEGORIES)',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Category Cards List
                    ...sharedBudget.categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildCategoryCard(category),
                      );
                    }),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Actions: Manage Members & Edit Budget + Allocate Funds
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Row of Manage Members & Edit Budget
                  Row(
                    children: [
                      // Manage Members Button (Green border)
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFF1F222B),
                              foregroundColor: Colors.white,
                              side: BorderSide(
                                color: accentColor,
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SharedBudgetMembersScreen(
                                    budget: sharedBudget,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'Manage Members',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Edit Budget Button (Dark button)
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFF1F222B),
                              foregroundColor: Colors.white,
                              side: const BorderSide(
                                color: Color(0xFF282D3B),
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CreateSharedBudgetScreen(
                                    budget: sharedBudget,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'Edit Budget',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Allocate Funds Button (Solid Lime Green)
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Allocate Funds',
                              style: TextStyle(
                                color: Color(0xFF0C0F14),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            backgroundColor: accentColor,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Allocate Funds',
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

  Widget _buildCategoryCard(SharedBudgetCategory category) {
    final progress = category.assignedAmount > 0
        ? (category.usedAmount / category.assignedAmount).clamp(0.0, 1.0)
        : 0.0;

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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    category.icon,
                    color: category.iconColor,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Assigned: LKR ${currencyFormat.format(category.assignedAmount)}',
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
                    'LKR ${currencyFormat.format(category.availableAmount)}',
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
                valueColor: AlwaysStoppedAnimation<Color>(category.barColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
