import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prot/features/navigation/main_wrapper.dart';
import 'core/constants/app_strings.dart';
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
//import 'package:prot/features/debt_bnpl/presentation/debt_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: ProtApp(),
    ),
  );
}

class ProtApp extends ConsumerWidget {
  const ProtApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home:  MainWrapper(),
    );
  }
}
