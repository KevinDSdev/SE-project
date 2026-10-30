import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../models/goal_model.dart';

class GoalsState {
  final List<GoalModel> goals;
  final double portfolioTarget;
  final bool smartAutoSaveEnabled;
  final double autoSaveAmount;
  final int autoSaveDayOfMonth;

  const GoalsState({
    required this.goals,
    this.portfolioTarget = 3600000,
    this.smartAutoSaveEnabled = true,
    this.autoSaveAmount = 25000,
    this.autoSaveDayOfMonth = 25,
  });

  double get totalAccumulated =>
      goals.fold(0.0, (sum, g) => sum + g.currentAmount);

  int get overallProgressPercentage {
    if (portfolioTarget <= 0) return 0;
    return ((totalAccumulated / portfolioTarget) * 100).round();
  }

  GoalsState copyWith({
    List<GoalModel>? goals,
    double? portfolioTarget,
    bool? smartAutoSaveEnabled,
    double? autoSaveAmount,
    int? autoSaveDayOfMonth,
  }) {
    return GoalsState(
      goals: goals ?? this.goals,
      portfolioTarget: portfolioTarget ?? this.portfolioTarget,
      smartAutoSaveEnabled: smartAutoSaveEnabled ?? this.smartAutoSaveEnabled,
      autoSaveAmount: autoSaveAmount ?? this.autoSaveAmount,
      autoSaveDayOfMonth: autoSaveDayOfMonth ?? this.autoSaveDayOfMonth,
    );
  }
}

class GoalsNotifier extends Notifier<GoalsState> {
  @override
  GoalsState build() {
    return const GoalsState(
      portfolioTarget: 3600000,
      smartAutoSaveEnabled: true,
      autoSaveAmount: 25000,
      autoSaveDayOfMonth: 25,
      goals: [
        GoalModel(
          id: 'emergency_fund',
          title: 'Emergency Fund',
          subtitle: '6 Months Cushion • Auto-saving',
          currentAmount: 1450000,
          targetAmount: 1500000,
          monthlyContribution: 50000,
          color: AppColors.primary,
          iconBg: Color(0xFF1B2E15),
          icon: Icons.shield_outlined,
          badgeText: '97% Done',
          isAutoSaving: true,
        ),
        GoalModel(
          id: 'vacation_fund',
          title: 'Save for Vacation',
          subtitle: 'Ella & Mirissa Retreat • Dec 2026',
          currentAmount: 310000,
          targetAmount: 1200000,
          monthlyContribution: 25000,
          color: Color(0xFFC084FC),
          iconBg: Color(0xFF281838),
          icon: Icons.flight_rounded,
          badgeText: '26% Saved',
          isAutoSaving: false,
        ),
        GoalModel(
          id: 'vehicle_upgrade',
          title: 'Vehicle Upgrade',
          subtitle: 'Hybrid / EV Fund • Mid 2027',
          currentAmount: 690000,
          targetAmount: 2500000,
          monthlyContribution: 40000,
          color: Color(0xFF38BDF8),
          iconBg: Color(0xFF122436),
          icon: Icons.lock_outline_rounded,
          badgeText: '28% Saved',
          isAutoSaving: false,
        ),
      ],
    );
  }

  void toggleSmartAutoSave() {
    state = state.copyWith(smartAutoSaveEnabled: !state.smartAutoSaveEnabled);
  }

  void addGoal(GoalModel newGoal) {
    state = state.copyWith(goals: [...state.goals, newGoal]);
  }

  void updateGoal(GoalModel updated) {
    state = state.copyWith(
      goals: state.goals.map((g) => g.id == updated.id ? updated : g).toList(),
    );
  }

  void contributeToGoal(String id, double amount) {
    state = state.copyWith(
      goals: state.goals.map((g) {
        if (g.id == id) {
          final newCurrent = g.currentAmount + amount;
          final pct = ((newCurrent / g.targetAmount) * 100).round();
          return g.copyWith(
            currentAmount: newCurrent,
            badgeText: pct >= 100 ? '100% Done' : '$pct% Saved',
          );
        }
        return g;
      }).toList(),
    );
  }
}

final goalsProvider = NotifierProvider<GoalsNotifier, GoalsState>(
  GoalsNotifier.new,
);
