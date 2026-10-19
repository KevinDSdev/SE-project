import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final events = [
      {
        'title': 'New Build Succeeded',
        'desc': 'Target: Android APK (debug) completed in 42s',
        'time': '10m ago',
        'icon': Icons.android_rounded,
        'color': AppColors.success,
      },
      {
        'title': 'iOS Podfile Linked',
        'desc': 'Runner workspace configured with CocoaPods specifications',
        'time': '1h ago',
        'icon': Icons.apple_rounded,
        'color': AppColors.info,
      },
      {
        'title': 'Riverpod State Initialized',
        'desc': 'Auth & Theme providers mounted in ProviderScope',
        'time': '2h ago',
        'icon': Icons.hub_rounded,
        'color': AppColors.primary,
      },
      {
        'title': 'Security Audit Passed',
        'desc': 'No vulnerabilities detected in 38 direct dependencies',
        'time': 'Yesterday',
        'icon': Icons.shield_rounded,
        'color': AppColors.secondary,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity & Alerts'),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          itemCount: events.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final ev = events[index];
            final color = ev['color'] as Color;

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(ev['icon'] as IconData, color: color, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                ev['title'] as String,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                ev['time'] as String,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ev['desc'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
