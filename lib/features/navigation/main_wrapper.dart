import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/navigation_provider.dart';
import '../dashboard/presentation/dashboard_screen.dart';
import '../budget/presentation/budget_screen.dart';
import '../analytics/presentation/analytics_screen.dart';
import '../goals/presentation/goals_screen.dart';
import '../profile/presentation/profile_screen.dart';

class MainWrapper extends ConsumerWidget {
  const MainWrapper({super.key});

  final List<Widget> _screens = const [
    DashboardScreen(),
    BudgetScreen(),
    AnalyticsScreen(),
    GoalsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(selectedTabProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.darkBg,
          border: Border(
            top: BorderSide(
              color: AppColors.darkBorder.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  ref: ref,
                  index: 0,
                  label: 'Overview',
                  selectedIcon: Icons.home_rounded,
                  unselectedIcon: Icons.home_outlined,
                  isSelected: currentIndex == 0,
                ),
                _buildNavItem(
                  ref: ref,
                  index: 1,
                  label: 'Budget',
                  selectedIcon: Icons.access_time_filled_rounded,
                  unselectedIcon: Icons.access_time_rounded,
                  isSelected: currentIndex == 1,
                ),
                _buildNavItem(
                  ref: ref,
                  index: 2,
                  label: 'Analytics',
                  selectedIcon: Icons.bar_chart_rounded,
                  unselectedIcon: Icons.bar_chart_outlined,
                  isSelected: currentIndex == 2,
                ),
                _buildNavItem(
                  ref: ref,
                  index: 3,
                  label: 'Goals',
                  selectedIcon: Icons.track_changes_rounded,
                  unselectedIcon: Icons.adjust_rounded,
                  isSelected: currentIndex == 3,
                ),
                _buildNavItem(
                  ref: ref,
                  index: 4,
                  label: 'Profile',
                  selectedIcon: Icons.person_rounded,
                  unselectedIcon: Icons.person_outline_rounded,
                  isSelected: currentIndex == 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required WidgetRef ref,
    required int index,
    required String label,
    required IconData selectedIcon,
    required IconData unselectedIcon,
    required bool isSelected,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        ref.read(selectedTabProvider.notifier).setTab(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected)
            Container(
              width: 44,
              height: 38,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  selectedIcon,
                  color: const Color(0xFF0C0F14),
                  size: 22,
                ),
              ),
            )
          else
            SizedBox(
              width: 44,
              height: 38,
              child: Center(
                child: Icon(
                  unselectedIcon,
                  color: const Color(0xFF6B7280),
                  size: 22,
                ),
              ),
            ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : const Color(0xFF6B7280),
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
