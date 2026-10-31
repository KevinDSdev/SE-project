import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../settings/providers/settings_provider.dart';
import '../models/goal_model.dart';
import '../providers/goals_provider.dart';
import 'widgets/goal_detail_sheet.dart';
import 'widgets/new_goal_sheet.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsState = ref.watch(goalsProvider);
    final accentColor = ref.watch(accentColorProvider).color;
    final currencyFormat = NumberFormat('#,###');

    return Scaffold(
      backgroundColor: const Color(0xFF0C0F14),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: "Savings Goals" & "+ New Goal" button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Savings Goals',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const NewGoalSheet(),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B2E15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF28481D),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_rounded,
                            color: accentColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'New Goal',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Total Savings Accumulated Card
              _buildTotalSavingsCard(context, goalsState, currencyFormat),
              const SizedBox(height: 24),

              // Active Goals Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Active Goals',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${goalsState.goals.length} Targets',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Active Goals List
              ...goalsState.goals.map((goal) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildGoalCard(context, ref, goal, currencyFormat),
                );
              }),
              const SizedBox(height: 4),

              // Smart Payday Auto-Save Card
              _buildSmartAutoSaveCard(context, ref, goalsState, currencyFormat),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalSavingsCard(
    BuildContext context,
    GoalsState state,
    NumberFormat currencyFormat,
  ) {
    final accentColor = Theme.of(context).colorScheme.primary;
    final totalAccumulated = state.totalAccumulated;
    final target = state.portfolioTarget;
    final percentReached = state.overallProgressPercentage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131722),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF1E2434), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Savings Accumulated',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'LKR ${currencyFormat.format(totalAccumulated)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Target: ',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: 'LKR ${currencyFormat.format(target)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$percentReached% Reached',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Multi-segment Progress Bar matching design
          _buildSegmentedProgressBar(state),
        ],
      ),
    );
  }

  Widget _buildSegmentedProgressBar(GoalsState state) {
    final target = state.portfolioTarget;
    final remaining = (target - state.totalAccumulated).clamp(
      0.0,
      double.infinity,
    );

    // List of active goal segments
    final segments = <Widget>[];

    for (int i = 0; i < state.goals.length; i++) {
      final goal = state.goals[i];
      final flexValue = (goal.currentAmount / 1000).round();
      if (flexValue > 0) {
        if (segments.isNotEmpty) {
          segments.add(const SizedBox(width: 4));
        }
        segments.add(
          Flexible(
            flex: flexValue,
            child: Container(
              height: 7,
              decoration: BoxDecoration(
                color: goal.color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      }
    }

    // Remaining track segment
    final remainingFlex = (remaining / 1000).round();
    if (remainingFlex > 0) {
      if (segments.isNotEmpty) {
        segments.add(const SizedBox(width: 4));
      }
      segments.add(
        Flexible(
          flex: remainingFlex,
          child: Container(
            height: 7,
            decoration: BoxDecoration(
              color: const Color(0xFF1C2232),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      );
    }

    if (segments.isEmpty) {
      return Container(
        height: 7,
        decoration: BoxDecoration(
          color: const Color(0xFF1C2232),
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    return Row(children: segments);
  }

  Widget _buildGoalCard(
    BuildContext context,
    WidgetRef ref,
    GoalModel goal,
    NumberFormat currencyFormat,
  ) {
    final formattedMonthly = _formatMonthly(goal.monthlyContribution);

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => GoalDetailSheet(goal: goal),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF131722),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF1E2332), width: 1.2),
        ),
        child: Column(
          children: [
            // Row 1: Icon, Title + Subtitle, Badge
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: goal.iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(goal.icon, color: goal.color, size: 22),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        goal.subtitle,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (goal.badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: goal.iconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      goal.badgeText!,
                      style: TextStyle(
                        color: goal.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Row 2: Current / Target Amount & Monthly Contribution
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text:
                            'LKR ${currencyFormat.format(goal.currentAmount)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextSpan(
                        text: ' / ${currencyFormat.format(goal.targetAmount)}',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  formattedMonthly,
                  style: TextStyle(
                    color: goal.color,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Row 3: Progress Bar
            Container(
              width: double.infinity,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF1E2434),
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: goal.progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: goal.color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartAutoSaveCard(
    BuildContext context,
    WidgetRef ref,
    GoalsState state,
    NumberFormat currencyFormat,
  ) {
    final accentColor = Theme.of(context).colorScheme.primary;
    final isEnabled = state.smartAutoSaveEnabled;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF131722),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E2332), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF1B2E15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.bolt_rounded,
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
                  'Smart Payday Auto-Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Deposits LKR ${currencyFormat.format(state.autoSaveAmount)} on the ${state.autoSaveDayOfMonth}th',
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Custom animated toggle switch matching the design exactly
          GestureDetector(
            onTap: () {
              ref.read(goalsProvider.notifier).toggleSmartAutoSave();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isEnabled ? accentColor : const Color(0xFF222838),
              ),
              alignment: isEnabled
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isEnabled
                      ? const Color(0xFF0C0F14)
                      : const Color(0xFF646B79),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatMonthly(double monthly) {
    if (monthly >= 1000) {
      final kValue = (monthly / 1000).toStringAsFixed(0);
      return '+LKR ${kValue}K/mo';
    }
    return '+LKR ${monthly.toInt()}/mo';
  }
}
