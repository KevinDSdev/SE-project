import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/app_preferences_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/signup_screen.dart';
import 'features/settings/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppPreferencesService.init();
  runApp(
    const ProviderScope(
      child: FinPulseApp(),
    ),
  );
}

class FinPulseApp extends ConsumerWidget {
  const FinPulseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accentOption = ref.watch(accentColorProvider);

    return MaterialApp(
      title: 'ECORP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightThemeWith(accentOption.color),
      themeMode: ThemeMode.light,
      home: const SignUpScreen(),
    );
  }
}
