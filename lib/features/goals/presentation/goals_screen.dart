import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = AppColors.getBg(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final textSecondary = AppColors.getTextSecondary(isDark);

    return Scaffold(
      backgroundColor: bg,
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
                  Text(
                    'Savings Goals',
                    style: TextStyle(
                      color: textPrimary,
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
                        color: isDark
                            ? const Color(0xFF1B2E15)
                            : accentColor.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF28481D)
                              : accentColor.withValues(alpha: 0.5),
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
                  Text(
                    'Active Goals',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${goalsState.goals.length} Targets',
                    style: TextStyle(
                      color: textSecondary,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppColors.getCard(isDark);
    final borderColor = AppColors.getBorder(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final textSecondary = AppColors.getTextSecondary(isDark);
    final subContainer = AppColors.getSubContainer(isDark);
    final totalAccumulated = state.totalAccumulated;
    final target = state.portfolioTarget;
    final percentReached = state.overallProgressPercentage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Savings Accumulated',
            style: TextStyle(
              color: textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'LKR ${currencyFormat.format(totalAccumulated)}',
            style: TextStyle(
              color: textPrimary,
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
                    TextSpan(
                      text: 'Target: ',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: 'LKR ${currencyFormat.format(target)}',
                      style: TextStyle(
                        color: textPrimary,
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
          _buildSegmentedProgressBar(state, subContainer),
        ],
      ),
    );
  }

  Widget _buildSegmentedProgressBar(GoalsState state, Color subContainer) {
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
              color: subContainer,
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
          color: subContainer,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppColors.getCard(isDark);
    final borderColor = AppColors.getBorder(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final textSecondary = AppColors.getTextSecondary(isDark);
    final subContainer = AppColors.getSubContainer(isDark);

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
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.2),
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
                    color: isDark
                        ? goal.iconBg
                        : goal.color.withValues(alpha: 0.14),
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
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        goal.subtitle,
                        style: TextStyle(
                          color: textSecondary,
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
                      color: isDark
                          ? goal.iconBg
                          : goal.color.withValues(alpha: 0.14),
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
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextSpan(
                        text: ' / ${currencyFormat.format(goal.targetAmount)}',
                        style: TextStyle(
                          color: textSecondary,
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
                color: subContainer,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppColors.getCard(isDark);
    final borderColor = AppColors.getBorder(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final textSecondary = AppColors.getTextSecondary(isDark);
    final subContainer = AppColors.getSubContainer(isDark);
    final isEnabled = state.smartAutoSaveEnabled;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1B2E15)
                  : accentColor.withValues(alpha: 0.16),
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
                Text(
                  'Smart Payday Auto-Save',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Deposits LKR ${currencyFormat.format(state.autoSaveAmount)} on the ${state.autoSaveDayOfMonth}th',
                  style: TextStyle(
                    color: textSecondary,
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
                color: isEnabled ? accentColor : subContainer,
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
