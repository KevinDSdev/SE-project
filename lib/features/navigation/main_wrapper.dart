import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers/navigation_provider.dart';
import '../analytics/presentation/financial_analytics_screen.dart';
import '../budget/presentation/budget_screen.dart';
import '../dashboard/presentation/dashboard_screen.dart';
import '../goals/presentation/goals_screen.dart';
import '../profile/presentation/profile_screen.dart';
import '../settings/providers/settings_provider.dart';

class MainWrapper extends ConsumerStatefulWidget {
  const MainWrapper({super.key});

  @override
  ConsumerState<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends ConsumerState<MainWrapper> {
  final GlobalKey<NavigatorState> _analyticsNavKey =
      GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _profileNavKey =
      GlobalKey<NavigatorState>();

  late final List<Widget> _screens = [
    const DashboardScreen(),
    const BudgetScreen(),
    _TabNavigator(
      navigatorKey: _analyticsNavKey,
      initialScreen: const FinancialAnalyticsScreen(),
    ),
    const GoalsScreen(),
    _TabNavigator(
      navigatorKey: _profileNavKey,
      initialScreen: const ProfileScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(selectedTabProvider);
    final accentColor = ref.watch(accentColorProvider).color;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (currentIndex == 2 &&
            _analyticsNavKey.currentState?.canPop() == true) {
          _analyticsNavKey.currentState?.pop();
        } else if (currentIndex == 4 &&
            _profileNavKey.currentState?.canPop() == true) {
          _profileNavKey.currentState?.pop();
        } else if (currentIndex != 0) {
          ref.read(selectedTabProvider.notifier).setTab(0);
        } else {
          // Allow app to exit if at the root of Overview tab
          Navigator.of(context, rootNavigator: true).maybePop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.lightBg,
        body: IndexedStack(index: currentIndex, children: _screens),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: AppColors.lightBorder,
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
                    accentColor: accentColor,
                  ),
                  _buildNavItem(
                    ref: ref,
                    index: 1,
                    label: 'Budget',
                    selectedIcon: Icons.access_time_filled_rounded,
                    unselectedIcon: Icons.access_time_rounded,
                    isSelected: currentIndex == 1,
                    accentColor: accentColor,
                  ),
                  _buildNavItem(
                    ref: ref,
                    index: 2,
                    label: 'Analytics',
                    selectedIcon: Icons.bar_chart_rounded,
                    unselectedIcon: Icons.bar_chart_outlined,
                    isSelected: currentIndex == 2,
                    accentColor: accentColor,
                  ),
                  _buildNavItem(
                    ref: ref,
                    index: 3,
                    label: 'Goals',
                    selectedIcon: Icons.track_changes_rounded,
                    unselectedIcon: Icons.adjust_rounded,
                    isSelected: currentIndex == 3,
                    accentColor: accentColor,
                  ),
                  _buildNavItem(
                    ref: ref,
                    index: 4,
                    label: 'Profile',
                    selectedIcon: Icons.person_rounded,
                    unselectedIcon: Icons.person_outline_rounded,
                    isSelected: currentIndex == 4,
                    accentColor: accentColor,
                  ),
                ],
              ),
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
    required Color accentColor,
  }) {
    final currentIndex = ref.watch(selectedTabProvider);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (currentIndex == index) {
          if (index == 2 && _analyticsNavKey.currentState?.canPop() == true) {
            _analyticsNavKey.currentState?.popUntil((route) => route.isFirst);
          } else if (index == 4 &&
              _profileNavKey.currentState?.canPop() == true) {
            _profileNavKey.currentState?.popUntil((route) => route.isFirst);
          }
        } else {
          ref.read(selectedTabProvider.notifier).setTab(index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected)
            Container(
              width: 44,
              height: 38,
              decoration: BoxDecoration(
                color: accentColor,
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
              color: isSelected ? accentColor : const Color(0xFF6B7280),
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget initialScreen;

  const _TabNavigator({
    required this.navigatorKey,
    required this.initialScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => initialScreen,
        );
      },
    );
  }
}
