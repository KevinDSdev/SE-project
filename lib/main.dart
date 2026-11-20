import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/theme_provider.dart';
import 'core/services/app_preferences_service.dart';
import 'core/theme/app_theme.dart';
import 'features/analytics/data/analytics_customization_repository.dart';
import 'features/analytics/data/dashboard_layout_repository.dart';
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
  } catch (error, stackTrace) {
    debugPrint(
      'Analytics customization database initialization failed: $error\n'
      '$stackTrace',
    );
  }
  runApp(const ProviderScope(child: FinPulseApp()));
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
