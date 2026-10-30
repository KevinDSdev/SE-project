import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/slide_route.dart';
import '../../analytics/presentation/analytics_screen.dart';
import '../../analytics/presentation/screens/report_export_screen.dart';
import '../../auth/presentation/login_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../settings/providers/settings_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _budgetAlertsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final userName = user?.name ?? 'Kavinda Perera';
    final userEmail = user?.email ?? 'kavinda.perera@email.lk';
    final accentColor = ref.watch(accentColorProvider).color;

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      color: AppColors.lightTextPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.of(context).push(
                        slideRoute(const SettingsScreen()),
                      );
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.lightBorder),
                      ),
                      child: const Icon(
                        Icons.settings_outlined,
                        color: AppColors.lightTextSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // User Profile Card (Reference: Profile Screen (LKR).png)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: accentColor, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: accentColor, width: 2),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.person,
                          color: accentColor,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              color: AppColors.lightTextPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            userEmail,
                            style: const TextStyle(
                              color: AppColors.lightTextSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Stats Row (Linked Banks, Budget Mode, CRIB Score)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: const [
                          Text(
                            'Linked Banks',
                            style: TextStyle(
                              color: AppColors.lightTextSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '3 Accounts',
                            style: TextStyle(
                              color: AppColors.lightTextPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 28,
                      color: AppColors.lightBorder,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'Budget Mode',
                            style: TextStyle(
                              color: AppColors.lightTextSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Auto-Track',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 28,
                      color: AppColors.lightBorder,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'CRIB Score',
                            style: TextStyle(
                              color: AppColors.lightTextSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5),
                          RichText(
                            text: TextSpan(
                              text: '785 ',
                              style: const TextStyle(
                                color: AppColors.lightTextPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Good',
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Grouped Section 1: Financial Preferences Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: Column(
                  children: [
                    // Bank Accounts
                    _buildGroupTile(
                      icon: Icons.home_rounded,
                      iconColor: const Color(0xFF38BDF8),
                      title: 'Bank Accounts',
                      subtitle: 'Commercial Bank, Sampath, HNB',
                      onTap: () {},
                    ),
                    _buildDivider(),
                    // Bank SMS Auto-Sync
                    _buildGroupTile(
                      icon: Icons.chat_bubble_outline_rounded,
                      iconColor: const Color(0xFF98E836),
                      title: 'Bank SMS Auto-Sync',
                      subtitle: 'Auto-log transactions from bank SMS',
                      subtitleColor: const Color(0xFF65A30D),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Setup',
                          style: TextStyle(
                            color: Color(0xFF0C0F14),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      onTap: () {},
                    ),
                    _buildDivider(),
                    // Primary Currency
                    _buildGroupTile(
                      icon: Icons.currency_exchange_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      title: 'Primary Currency',
                      subtitle: 'Sri Lankan Rupee (LKR / Rs.)',
                      onTap: () {},
                    ),
                    _buildDivider(),
                    // Budget Limit Alerts
                    _buildGroupTile(
                      icon: Icons.notifications_none_rounded,
                      iconColor: const Color(0xFF9353D3),
                      title: 'Budget Limit Alerts',
                      subtitle: 'Notify at 80% and 100% threshold',
                      trailing: Switch(
                        value: _budgetAlertsEnabled,
                        onChanged: (val) {
                          setState(() => _budgetAlertsEnabled = val);
                        },
                      ),
                      onTap: () {
                        setState(() => _budgetAlertsEnabled = !_budgetAlertsEnabled);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Grouped Section 2: App & Reports Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: Column(
                  children: [
                    // App Settings
                    _buildGroupTile(
                      icon: Icons.settings_outlined,
                      iconColor: const Color(0xFF98E836),
                      title: 'App Settings',
                      subtitle: 'Preferences, accent color & notifications',
                      onTap: () {
                        Navigator.of(context).push(
                          slideRoute(const SettingsScreen()),
                        );
                      },
                    ),
                    _buildDivider(),
                    // Download Statements
                    _buildGroupTile(
                      icon: Icons.description_outlined,
                      iconColor: const Color(0xFF64748B),
                      title: 'Download Statements',
                      subtitle: 'Monthly PDF & CSV tax reports',
                      onTap: () {
                        Navigator.of(context).push(
                          slideRoute(const ReportExportScreen()),
                        );
                      },
                    ),
                    _buildDivider(),
                    // Transaction History
                    _buildGroupTile(
                      icon: Icons.receipt_long_outlined,
                      iconColor: const Color(0xFF9353D3),
                      title: 'Transaction History',
                      subtitle: 'Overall information of transaction History',
                      onTap: () {
                        Navigator.of(context).push(
                          slideRoute(const AnalyticsScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Log Out Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFF43F5E),
                    size: 20,
                  ),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(
                      color: Color(0xFFF43F5E),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFFF43F5E),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Color? subtitleColor,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(icon, color: iconColor, size: 22),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.lightTextPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: subtitleColor ?? AppColors.lightTextSecondary,
                        fontSize: 12,
                        fontWeight: subtitleColor != null ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              trailing ??
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.lightTextSecondary,
                    size: 22,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 68,
      endIndent: 16,
      color: AppColors.lightBorder,
    );
  }
}
