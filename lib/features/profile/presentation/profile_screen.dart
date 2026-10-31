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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = AppColors.getBg(isDark);
    final cardBg = AppColors.getCard(isDark);
    final borderColor = AppColors.getBorder(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final textSecondary = AppColors.getTextSecondary(isDark);

    return Scaffold(
      backgroundColor: bg,
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
                  Text(
                    'Profile',
                    style: TextStyle(
                      color: textPrimary,
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
                        color: cardBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor),
                      ),
                      child: Icon(
                        Icons.settings_outlined,
                        color: textSecondary,
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
                  color: cardBg,
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
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            userEmail,
                            style: TextStyle(
                              color: textSecondary,
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
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Linked Banks',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '3 Accounts',
                            style: TextStyle(
                              color: textPrimary,
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
                      color: borderColor,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Budget Mode',
                            style: TextStyle(
                              color: textSecondary,
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
                      color: borderColor,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'CRIB Score',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5),
                          RichText(
                            text: TextSpan(
                              text: '785 ',
                              style: TextStyle(
                                color: textPrimary,
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
                  color: cardBg,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    // Bank Accounts
                    _buildGroupTile(
                      icon: Icons.home_rounded,
                      iconColor: const Color(0xFF38BDF8),
                      title: 'Bank Accounts',
                      subtitle: 'Commercial Bank, Sampath, HNB',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onTap: () {},
                    ),
                    _buildDivider(borderColor),
                    // Bank SMS Auto-Sync
                    _buildGroupTile(
                      icon: Icons.chat_bubble_outline_rounded,
                      iconColor: accentColor,
                      title: 'Bank SMS Auto-Sync',
                      subtitle: 'Auto-log transactions from bank SMS',
                      subtitleColor: const Color(0xFF65A30D),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
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
                    _buildDivider(borderColor),
                    // Primary Currency
                    _buildGroupTile(
                      icon: Icons.currency_exchange_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      title: 'Primary Currency',
                      subtitle: 'Sri Lankan Rupee (LKR / Rs.)',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onTap: () {},
                    ),
                    _buildDivider(borderColor),
                    // Budget Limit Alerts
                    _buildGroupTile(
                      icon: Icons.notifications_none_rounded,
                      iconColor: const Color(0xFF9353D3),
                      title: 'Budget Limit Alerts',
                      subtitle: 'Notify at 80% and 100% threshold',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      trailing: Switch.adaptive(
                        value: _budgetAlertsEnabled,
                        activeThumbColor: Colors.white,
                        activeTrackColor: accentColor,
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
                  color: cardBg,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    // App Settings
                    _buildGroupTile(
                      icon: Icons.settings_outlined,
                      iconColor: accentColor,
                      title: 'App Settings',
                      subtitle: 'Preferences, accent color & notifications',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onTap: () {
                        Navigator.of(context).push(
                          slideRoute(const SettingsScreen()),
                        );
                      },
                    ),
                    _buildDivider(borderColor),
                    // Download Statements
                    _buildGroupTile(
                      icon: Icons.description_outlined,
                      iconColor: const Color(0xFF64748B),
                      title: 'Download Statements',
                      subtitle: 'Monthly PDF & CSV tax reports',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onTap: () {
                        Navigator.of(context).push(
                          slideRoute(const ReportExportScreen()),
                        );
                      },
                    ),
                    _buildDivider(borderColor),
                    // Transaction History
                    _buildGroupTile(
                      icon: Icons.receipt_long_outlined,
                      iconColor: const Color(0xFF9353D3),
                      title: 'Transaction History',
                      subtitle: 'Overall information of transaction History',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
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
    required Color textPrimary,
    required Color textSecondary,
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
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: subtitleColor ?? textSecondary,
                        fontSize: 12,
                        fontWeight: subtitleColor != null ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_right_rounded,
                    color: textSecondary,
                    size: 22,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(Color borderColor) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 68,
      endIndent: 16,
      color: borderColor,
    );
  }
}
