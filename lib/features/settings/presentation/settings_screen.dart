import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/slide_route.dart';
import '../../../core/providers/theme_provider.dart';
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
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final selectedAccent = ref.watch(accentColorProvider);
    final accentColor = selectedAccent.color;
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final reminderTime = ref.watch(dailyReminderTimeProvider);
    final gpsEnabled = ref.watch(gpsSuggestionsProvider);
    final cloudSync = ref.watch(cloudSyncProvider);
    final biometrics = ref.watch(biometricsProvider);

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
                        color: cardBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor),
                      ),
                      child: Icon(
                        Icons.chevron_left_rounded,
                        color: textPrimary,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'App Settings',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Application preferences, security, sync & notifications',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // SECTION 1: THEME & APPEARANCE
              _buildSectionHeader('THEME & APPEARANCE', textSecondary),
              const SizedBox(height: 8),

              // 1. Dark Mode Theme Tile
              _buildSettingCard(
                cardBg: cardBg,
                borderColor: borderColor,
                child: Row(
                  children: [
                    Icon(
                      Icons.nightlight_round,
                      color: accentColor,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Dark Mode Theme',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Switch.adaptive(
                      value: isDark,
                      activeColor: Colors.white,
                      activeTrackColor: accentColor,
                      onChanged: (val) {
                        ref.read(themeModeProvider.notifier).setDarkMode(val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 2. Primary Accent Color Tile
              _buildSettingCard(
                cardBg: cardBg,
                borderColor: borderColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Primary Accent Color',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          selectedAccent.name,
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: kAccentColors.map((opt) {
                        final isSel = opt.color.toARGB32() == accentColor.toARGB32();
                        return GestureDetector(
                          onTap: () {
                            ref
                                .read(accentColorProvider.notifier)
                                .setColor(opt);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 10),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: opt.color,
                              shape: BoxShape.circle,
                              border: isSel
                                  ? Border.all(
                                      color: Colors.white,
                                      width: 2.5,
                                    )
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 3. Customize Widgets Tile
              _buildSettingCard(
                cardBg: cardBg,
                borderColor: borderColor,
                onTap: () {
                  Navigator.of(context).push(
                    slideRoute(const DashboardWidgetsScreen()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Customize Widgets',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 4. Customize Analytical Dashboard Tile
              _buildSettingCard(
                cardBg: cardBg,
                borderColor: borderColor,
                onTap: () {
                  Navigator.of(context).push(
                    slideRoute(const AnalyticsCustomizationScreen()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Customize Analytical Dashboard',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // SECTION 2: NOTIFICATIONS & REMINDERS
              _buildSectionHeader('NOTIFICATIONS & REMINDERS', textSecondary),
              const SizedBox(height: 8),

              // 5. Notifications & Alerts
              _buildSettingCard(
                cardBg: cardBg,
                borderColor: borderColor,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notifications & Alerts',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Transaction alerts and bill due dates',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: notificationsEnabled,
                      activeColor: Colors.white,
                      activeTrackColor: accentColor,
                      onChanged: (val) {
                        ref
                            .read(notificationsEnabledProvider.notifier)
                            .setEnabled(val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 6. Daily Log Reminder Time
              _buildSettingCard(
                cardBg: cardBg,
                borderColor: borderColor,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Log Reminder Time',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Everyday at ${reminderTime.format(context)} Sri Lanka Time',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
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
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: accentColor, width: 1.2),
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
              const SizedBox(height: 10),

              // 7. Set Reminder
              _buildSettingCard(
                cardBg: cardBg,
                borderColor: borderColor,
                onTap: () => SetReminderDialog.show(context),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Set Reminder',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Set own reminders',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: accentColor,
                      size: 24,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 8. GPS Location Suggestions
              _buildSettingCard(
                cardBg: cardBg,
                borderColor: borderColor,
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.location_on,
                          color: Color(0xFFEF4444),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GPS Location Suggestions',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Notify to log expenses near malls & stores',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: gpsEnabled,
                      activeColor: Colors.white,
                      activeTrackColor: accentColor,
                      onChanged: (val) {
                        ref
                            .read(gpsSuggestionsProvider.notifier)
                            .setEnabled(val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // SECTION 3: DATA SYNC & STORAGE
              _buildSectionHeader('DATA SYNC & STORAGE', textSecondary),
              const SizedBox(height: 8),

              // 9. Cloud Real-time Auto-Sync
              _buildSettingCard(
                cardBg: cardBg,
                borderColor: borderColor,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cloud Real-time Auto-Sync',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Encrypted synchronization across devices',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: cloudSync,
                      activeColor: Colors.white,
                      activeTrackColor: accentColor,
                      onChanged: (val) {
                        ref.read(cloudSyncProvider.notifier).setEnabled(val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 10. Local Encrypted Database
              _buildSettingCard(
                cardBg: cardBg,
                borderColor: borderColor,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Local Encrypted Database',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '142 records',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
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
              const SizedBox(height: 20),

              // SECTION 4: SECURITY & PRIVACY
              _buildSectionHeader('SECURITY & PRIVACY', textSecondary),
              const SizedBox(height: 8),

              // 11. Biometric Face ID / Fingerprint
              _buildSettingCard(
                cardBg: cardBg,
                borderColor: borderColor,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Biometric Face ID / Fingerprint',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Require biometric confirmation to open app',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: biometrics,
                      activeColor: Colors.white,
                      activeTrackColor: accentColor,
                      onChanged: (val) {
                        ref.read(biometricsProvider.notifier).setEnabled(val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // SECTION 5: APP INFORMATION
              _buildSectionHeader('APP INFORMATION', textSecondary),
              const SizedBox(height: 8),

              // 12. App Information
              _buildSettingCard(
                cardBg: cardBg,
                borderColor: borderColor,
                onTap: () {
                  Navigator.of(context).push(
                    slideRoute(const AppInfoScreen()),
                  );
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'App Information',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Learn more about application',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: accentColor, width: 1.2),
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
              const SizedBox(height: 10),

              // 13. System Version
              _buildSettingCard(
                cardBg: cardBg,
                borderColor: borderColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'System Version',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildSettingCard({
    required Color cardBg,
    required Color borderColor,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: child,
      ),
    );
  }
}
