import 'package:flutter/material.dart';
import '../dashboard/presentation/dashboard_screen.dart';
import '../debt_bnpl/presentation/debt_dashboard_screen.dart';
import '../settings/presentation/settings_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 1; // Default tab: Budget

  final List<Widget> _screens = [
    const DashboardScreen(),       // Tab 0: Overview
    const DebtDashboardScreen(),   // Tab 1: Budget
    const Center(child: Text('Analytics Screen', style: TextStyle(color: Colors.white))), // Tab 2: Analytics
    const Center(child: Text('Goals Screen', style: TextStyle(color: Colors.white))),     // Tab 3: Goals
    const SettingsScreen(),        // Tab 4: Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1420),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildCustomBottomNavBar(),
    );
  }

  Widget _buildCustomBottomNavBar() {
    const primaryLime = Color(0xFFA6E22E);
    const navBgColor = Color(0xFF0F1420);

    final navItems = [
      _NavItem(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: 'Overview',
      ),
      _NavItem(
        icon: Icons.access_time_rounded,
        selectedIcon: Icons.access_time_filled_rounded,
        label: 'Budget',
      ),
      _NavItem(
        icon: Icons.bar_chart_rounded,
        selectedIcon: Icons.bar_chart_rounded,
        label: 'Analytics',
      ),
      _NavItem(
        icon: Icons.track_changes_rounded,
        selectedIcon: Icons.track_changes_rounded,
        label: 'Goals',
      ),
      _NavItem(
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
        label: 'Profile',
      ),
    ];

    return Container(
      height: 80,
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      decoration: const BoxDecoration(
        color: navBgColor,
        border: Border(top: BorderSide(color: Colors.white12, width: 0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(navItems.length, (index) {
              final isSelected = _currentIndex == index;
              final item = navItems[index];

              return InkWell(
                onTap: () => setState(() => _currentIndex = index),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected ? primaryLime : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSelected ? item.selectedIcon : item.icon,
                        color: isSelected ? const Color(0xFF0F1420) : Colors.white54,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected ? primaryLime : Colors.white54,
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          Container(
            width: 130,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}