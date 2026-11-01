import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/shared_budget_model.dart';

class SharedBudgetNotifier extends Notifier<SharedBudget> {
  static SharedBudget get initialBudget => SharedBudget(
        id: 'sb_family_vacation',
        name: 'Family Vacation',
        goal: 'Save for a family holiday',
        period: 'October 2026',
        totalSharedFunds: 150000,
        totalUsed: 45000,
        totalAvailable: 105000,
        categories: [
          SharedBudgetCategory(
            id: 'sbc_accommodation',
            name: 'Accommodation',
            assignedAmount: 70000,
            availableAmount: 45000,
            usedAmount: 25000,
            icon: Icons.home_work_rounded,
            iconColor: const Color(0xFFEF4444),
            barColor: const Color(0xFF38BDF8),
          ),
          SharedBudgetCategory(
            id: 'sbc_transport',
            name: 'Transport',
            assignedAmount: 40000,
            availableAmount: 30000,
            usedAmount: 10000,
            icon: Icons.directions_bus_filled_rounded,
            iconColor: const Color(0xFF0284C7),
            barColor: const Color(0xFF38BDF8),
          ),
          SharedBudgetCategory(
            id: 'sbc_food',
            name: 'Food & Dining',
            assignedAmount: 25000,
            availableAmount: 15000,
            usedAmount: 10000,
            icon: Icons.restaurant_rounded,
            iconColor: const Color(0xFFEA580C),
            barColor: const Color(0xFFF59E0B),
          ),
          SharedBudgetCategory(
            id: 'sbc_activities',
            name: 'Activities',
            assignedAmount: 15000,
            availableAmount: 15000,
            usedAmount: 0,
            icon: Icons.flight_takeoff_rounded,
            iconColor: const Color(0xFF0EA5E9),
            barColor: const Color(0xFF38BDF8),
          ),
        ],
        members: [
          SharedBudgetMember(
            id: 'sbm_owner',
            name: 'You (Owner)',
            role: 'Owner',
            joinDate: 'Created Oct 2026',
            badgeText: 'OWNER',
            badgeColor: const Color(0xFF98E836),
            avatarInitials: 'Y',
            avatarColor: const Color(0xFF84CC16),
          ),
          SharedBudgetMember(
            id: 'sbm_member1',
            name: 'Family Member 1',
            role: 'Active Member',
            joinDate: 'Joined Oct 15',
            badgeText: 'MEMBER',
            badgeColor: const Color(0xFF38BDF8),
            avatarInitials: 'F1',
            avatarColor: const Color(0xFF0284C7),
          ),
          SharedBudgetMember(
            id: 'sbm_member2',
            name: 'Family Member 2',
            role: 'Active Member',
            joinDate: 'Joined Oct 18',
            badgeText: 'MEMBER',
            badgeColor: const Color(0xFF38BDF8),
            avatarInitials: 'F2',
            avatarColor: const Color(0xFF9333EA),
          ),
        ],
      );

  @override
  SharedBudget build() => initialBudget;

  void updateBudget({
    String? name,
    String? goal,
    String? period,
    double? totalSharedFunds,
    List<SharedBudgetCategory>? categories,
  }) {
    final updatedCategories = categories ?? state.categories;
    double calculatedTotalAssigned = 0;
    double calculatedTotalUsed = 0;
    for (final cat in updatedCategories) {
      calculatedTotalAssigned += cat.assignedAmount;
      calculatedTotalUsed += cat.usedAmount;
    }

    final newTotalFunds = totalSharedFunds ??
        (calculatedTotalAssigned > 0 ? calculatedTotalAssigned : state.totalSharedFunds);
    final calculatedAvailable = (newTotalFunds - calculatedTotalUsed).clamp(0.0, double.infinity);

    state = state.copyWith(
      name: name ?? state.name,
      goal: goal ?? state.goal,
      period: period ?? state.period,
      totalSharedFunds: newTotalFunds,
      totalUsed: calculatedTotalUsed,
      totalAvailable: calculatedAvailable,
      categories: updatedCategories,
    );
  }

  void addMember(String emailOrPhone) {
    final newMember = SharedBudgetMember(
      id: 'sbm_${DateTime.now().millisecondsSinceEpoch}',
      name: emailOrPhone.contains('@')
          ? emailOrPhone.split('@').first
          : emailOrPhone,
      role: 'Active Member',
      joinDate: 'Joined Just Now',
      badgeText: 'MEMBER',
      badgeColor: const Color(0xFF38BDF8),
      avatarInitials: emailOrPhone.isNotEmpty
          ? emailOrPhone.substring(0, 1).toUpperCase()
          : 'M',
      avatarColor: const Color(0xFF0284C7),
    );

    state = state.copyWith(
      members: [...state.members, newMember],
    );
  }

  void removeMember(String memberId) {
    state = state.copyWith(
      members: state.members.where((m) => m.id != memberId).toList(),
    );
  }

  void resetToDefault() {
    state = initialBudget;
  }
}

final sharedBudgetProvider =
    NotifierProvider<SharedBudgetNotifier, SharedBudget>(
  SharedBudgetNotifier.new,
);
