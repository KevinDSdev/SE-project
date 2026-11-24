import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/theme_provider.dart';
import 'core/services/app_preferences_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/analytics/data/analytics_customization_repository.dart';
import 'features/analytics/data/dashboard_layout_repository.dart';
import 'features/analytics/data/report_export_repository.dart';
import 'features/auth/presentation/signup_screen.dart';
import 'features/settings/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppPreferencesService.init();
  try {
    await AnalyticsCustomizationRepository.instance.init();
    try {
      await DashboardLayoutRepository.instance.init();
    } catch (error, stackTrace) {
      debugPrint(
        'Dashboard layout persistence initialization failed: $error\n'
        '$stackTrace',
      );
    }
    try {
      await ReportExportRepository.instance.init();
    } catch (error, stackTrace) {
      debugPrint(
        'Report export persistence initialization failed: $error\n'
        '$stackTrace',
      );
    }
  } catch (error, stackTrace) {
    debugPrint(
      'Analytics customization database initialization failed: $error\n'
      '$stackTrace',
    );
  }
  await restoreDailyLogReminderOnStartup();
  runApp(const ProviderScope(child: FinPulseApp()));
}

/// Initializes [NotificationService] and restores the persisted daily log
/// reminder schedule during application startup.
Future<DailyReminderScheduleResult?> restoreDailyLogReminderOnStartup({
  NotificationService? notificationService,
}) async {
  final service = notificationService ?? NotificationService.instance;
  try {
    await service.init();
    final savedReminder = AppPreferencesService.getDailyReminderTime();
    final reminderTime = savedReminder != null
        ? TimeOfDay(hour: savedReminder.hour, minute: savedReminder.minute)
        : DailyReminderTimeNotifier.defaultTime;
    return await service.restoreDailyLogReminder(reminderTime);
  } catch (error, stackTrace) {
    debugPrint(
      'Notification service initialization failed: $error\n'
      '$stackTrace',
    );
    return null;
  }
}

class FinPulseApp extends ConsumerWidget {
  const FinPulseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accentOption = ref.watch(accentColorProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'ECORP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightThemeWith(accentOption.color),
      darkTheme: AppTheme.darkThemeWith(accentOption.color),
      themeMode: themeMode,
      home: const SignUpScreen(),
    );
  }
}
