import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/goal_model.dart';
import '../../providers/goals_provider.dart';

class GoalDetailSheet extends ConsumerStatefulWidget {
  final GoalModel goal;

  const GoalDetailSheet({super.key, required this.goal});

  @override
  ConsumerState<GoalDetailSheet> createState() => _GoalDetailSheetState();
}

class _GoalDetailSheetState extends ConsumerState<GoalDetailSheet> {
  final _amountController = TextEditingController();
  final _currencyFormat = NumberFormat('#,###');

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _contribute(double amount) {
    ref.read(goalsProvider.notifier).contributeToGoal(widget.goal.id, amount);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added LKR ${_currencyFormat.format(amount)} to ${widget.goal.title}!',
        ),
        backgroundColor: const Color(0xFF1B2E15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;
    final remaining = (goal.targetAmount - goal.currentAmount).clamp(0.0, double.infinity);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF121620),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Color(0xFF1E2332), width: 1.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF262B36),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: goal.iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(goal.icon, color: goal.color, size: 22),
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
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      goal.subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (goal.badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          const SizedBox(height: 20),

          // Progress overview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F2C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF262C3D)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Saved so far',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    Text(
                      'LKR ${_currencyFormat.format(goal.currentAmount)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Remaining Target',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    Text(
                      'LKR ${_currencyFormat.format(remaining)}',
                      style: TextStyle(
                        color: goal.color,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF252C3D),
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
          const SizedBox(height: 20),

          const Text(
            'Quick Deposit to Goal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildQuickDepositButton(10000, '+10K'),
              const SizedBox(width: 8),
              _buildQuickDepositButton(25000, '+25K'),
              const SizedBox(width: 8),
              _buildQuickDepositButton(50000, '+50K'),
            ],
          ),
          const SizedBox(height: 14),

          // Custom amount deposit
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1F2C),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF262C3D)),
                  ),
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Custom amount (LKR)',
                      hintStyle: TextStyle(
                        color: Color(0xFF646B79),
                        fontSize: 13,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 14),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(_amountController.text.trim());
                  if (amount != null && amount > 0) {
                    _contribute(amount);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: goal.color,
                  foregroundColor: const Color(0xFF0C0F14),
                  elevation: 0,
                  minimumSize: const Size(80, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickDepositButton(double amount, String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _contribute(amount),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F2C),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF262C3D)),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
