import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/slide_route.dart';
import '../../analytics/presentation/screens/analytics_customization_screen.dart';
import '../../analytics/presentation/screens/dashboard_widgets_screen.dart';
import '../providers/settings_provider.dart';
import 'screens/app_info_screen.dart';
import 'widgets/set_reminder_dialog.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final selectedAccent = ref.watch(accentColorProvider);
    final accentColor = selectedAccent.color;
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final reminderTime = ref.watch(dailyReminderTimeProvider);
    final gpsEnabled = ref.watch(gpsSuggestionsProvider);
    final cloudSync = ref.watch(cloudSyncProvider);
    final biometrics = ref.watch(biometricsProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Back Button & Title
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.lightBorder),
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: AppColors.lightTextPrimary,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'App Settings',
                        style: TextStyle(
                          color: AppColors.lightTextPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Application preferences, security, sync & appearance',
                        style: TextStyle(
                          color: AppColors.lightTextSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // SECTION 1: THEME & APPEARANCE (Light theme only, no dark toggle)
              _buildSectionHeader('THEME & APPEARANCE'),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: Column(
                  children: [
                    // Primary Accent Color
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Primary Accent Color',
                                style: TextStyle(
                                  color: AppColors.lightTextPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                selectedAccent.name,
                                style: const TextStyle(
                                  color: AppColors.lightTextSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: kAccentColors.map((opt) {
                              final isSel =
                                  opt.color.toARGB32() == accentColor.toARGB32();
                              return GestureDetector(
                                onTap: () {
                                  ref
                                      .read(accentColorProvider.notifier)
                                      .setColor(opt);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: opt.color,
                                    shape: BoxShape.circle,
                                    border: isSel
                                        ? Border.all(
                                            color: AppColors.lightTextPrimary,
                                            width: 2.5,
                                          )
                                        : Border.all(
                                            color: AppColors.lightBorder,
                                            width: 1,
                                          ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    _buildDivider(),

                    // Set Layout / Customize Cards
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.of(context).push(
                          slideRoute(const DashboardWidgetsScreen()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Customize Cards / Dashboard Layout',
                              style: TextStyle(
                                color: AppColors.lightTextPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.lightTextSecondary,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildDivider(),

                    // Customize Analytical Dashboard
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.of(context).push(
                          slideRoute(const AnalyticsCustomizationScreen()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Customize Analytical Dashboard',
                              style: TextStyle(
                                color: AppColors.lightTextPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.lightTextSecondary,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // SECTION 2: NOTIFICATIONS & REMINDERS
              _buildSectionHeader('NOTIFICATIONS & REMINDERS'),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: Column(
                  children: [
                    // Notifications & Alerts
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Notifications & Alerts',
                                  style: TextStyle(
                                    color: AppColors.lightTextPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Transaction alerts and bill due dates',
                                  style: TextStyle(
                                    color: AppColors.lightTextSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: notificationsEnabled,
                            onChanged: (val) {
                              ref
                                  .read(notificationsEnabledProvider.notifier)
                                  .setVal(val);
                            },
                          ),
                        ],
                      ),
                    ),
                    _buildDivider(),

                    // Daily Log Reminder Time
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Daily Log Reminder Time',
                                style: TextStyle(
                                  color: AppColors.lightTextPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Everyday at 8:00 PM Sri Lanka Time',
                                style: TextStyle(
                                  color: AppColors.lightTextSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: reminderTime,
                              );
                              if (picked != null) {
                                ref
                                    .read(dailyReminderTimeProvider.notifier)
                                    .setTime(picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: accentColor,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                reminderTime.format(context),
                                style: TextStyle(
                                  color: accentColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildDivider(),

                    // Set Reminder
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const SetReminderDialog(),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Set Reminder',
                                  style: TextStyle(
                                    color: AppColors.lightTextPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Configure personal financial reminder schedules',
                                  style: TextStyle(
                                    color: AppColors.lightTextSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.lightTextSecondary,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildDivider(),

                    // GPS Location Suggestions
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF43F5E).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: Color(0xFFF43F5E),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'GPS Location Suggestions',
                                  style: TextStyle(
                                    color: AppColors.lightTextPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Notify to log expenses near malls & stores',
                                  style: TextStyle(
                                    color: AppColors.lightTextSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: gpsEnabled,
                            onChanged: (val) {
                              ref
                                  .read(gpsSuggestionsProvider.notifier)
                                  .setVal(val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // SECTION 3: DATA SYNC & STORAGE
              _buildSectionHeader('DATA SYNC & STORAGE'),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: Column(
                  children: [
                    // Cloud Real-time Auto-Sync
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Cloud Real-time Auto-Sync',
                                  style: TextStyle(
                                    color: AppColors.lightTextPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Encrypted synchronization across devices',
                                  style: TextStyle(
                                    color: AppColors.lightTextSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: cloudSync,
                            onChanged: (val) {
                              ref.read(cloudSyncProvider.notifier).setVal(val);
                            },
                          ),
                        ],
                      ),
                    ),
                    _buildDivider(),

                    // Local Encrypted Database
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Local Encrypted Database',
                                style: TextStyle(
                                  color: AppColors.lightTextPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '142 records stored securely',
                                style: TextStyle(
                                  color: AppColors.lightTextSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Active',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // SECTION 4: SECURITY & PRIVACY
              _buildSectionHeader('SECURITY & PRIVACY'),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Biometric Face ID / Fingerprint',
                              style: TextStyle(
                                color: AppColors.lightTextPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Require biometric confirmation to open app',
                              style: TextStyle(
                                color: AppColors.lightTextSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: biometrics,
                        onChanged: (val) {
                          ref.read(biometricsProvider.notifier).setVal(val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // SECTION 5: APP INFORMATION
              _buildSectionHeader('APP INFORMATION'),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: Column(
                  children: [
                    // App Information
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.of(context).push(
                          slideRoute(const AppInfoScreen()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'App Information',
                                  style: TextStyle(
                                    color: AppColors.lightTextPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Learn more about application & privacy',
                                  style: TextStyle(
                                    color: AppColors.lightTextSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: accentColor,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'About',
                                style: TextStyle(
                                  color: accentColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildDivider(),

                    // System Version
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'System Version',
                            style: TextStyle(
                              color: AppColors.lightTextPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'V.1.1',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.lightTextSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColors.lightBorder,
    );
  }
}
