import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prot/core/providers/theme_provider.dart';
import 'package:prot/core/services/app_preferences_service.dart';
import 'package:prot/features/settings/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    AppPreferencesService.resetForTesting();
    SharedPreferences.setMockInitialValues({});
    await AppPreferencesService.init();
  });

  Future<ProviderContainer> simulateAppRestart(
    ProviderContainer oldContainer,
  ) async {
    oldContainer.dispose();
    AppPreferencesService.resetForTesting();
    await AppPreferencesService.init();
    final newContainer = ProviderContainer();
    addTearDown(newContainer.dispose);
    return newContainer;
  }

  group('Dark Mode persistence', () {
    test('defaults to Dark Mode when no preference exists', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(AppPreferencesService.getDarkMode(), isNull);
      expect(container.read(themeModeProvider), ThemeMode.dark);
    });

    test('saves Dark Mode asynchronously', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(themeModeProvider.notifier).setDarkMode(false);
      expect(container.read(themeModeProvider), ThemeMode.light);
      expect(AppPreferencesService.getDarkMode(), isFalse);

      await container.read(themeModeProvider.notifier).setDarkMode(true);
      expect(container.read(themeModeProvider), ThemeMode.dark);
      expect(AppPreferencesService.getDarkMode(), isTrue);
    });

    test('saves Light Mode asynchronously', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(themeModeProvider.notifier)
          .setThemeMode(ThemeMode.light);
      expect(container.read(themeModeProvider), ThemeMode.light);
      expect(AppPreferencesService.getDarkMode(), isFalse);
    });

    test('toggleTheme persists toggled state asynchronously', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(themeModeProvider), ThemeMode.dark);

      await container.read(themeModeProvider.notifier).toggleTheme();
      expect(container.read(themeModeProvider), ThemeMode.light);
      expect(AppPreferencesService.getDarkMode(), isFalse);

      await container.read(themeModeProvider.notifier).toggleTheme();
      expect(container.read(themeModeProvider), ThemeMode.dark);
      expect(AppPreferencesService.getDarkMode(), isTrue);
    });

    test('restores Light Mode after recreating provider', () async {
      final container = ProviderContainer();
      await container.read(themeModeProvider.notifier).setDarkMode(false);

      final restarted = await simulateAppRestart(container);
      expect(restarted.read(themeModeProvider), ThemeMode.light);
      expect(AppPreferencesService.getDarkMode(), isFalse);
    });

    test('restores Dark Mode after recreating provider', () async {
      final container = ProviderContainer();
      await container.read(themeModeProvider.notifier).setDarkMode(false);
      await container.read(themeModeProvider.notifier).setDarkMode(true);

      final restarted = await simulateAppRestart(container);
      expect(restarted.read(themeModeProvider), ThemeMode.dark);
      expect(AppPreferencesService.getDarkMode(), isTrue);
    });
  });

  group('Primary Accent Colour persistence', () {
    test('defaults to Neon Lime Green when no preference exists', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final accent = container.read(accentColorProvider);
      expect(AppPreferencesService.getAccentColor(), isNull);
      expect(accent.name, 'Neon Lime Green');
      expect(accent.color, const Color(0xFF98E836));
    });

    test('saves and restores Electric Blue', () async {
      final container = ProviderContainer();
      final electricBlue = kAccentColors.firstWhere(
        (c) => c.name == 'Electric Blue',
      );

      await container.read(accentColorProvider.notifier).setColor(electricBlue);
      expect(container.read(accentColorProvider).name, 'Electric Blue');
      expect(
        AppPreferencesService.getAccentColor(),
        electricBlue.color.toARGB32(),
      );

      final restarted = await simulateAppRestart(container);
      final restored = restarted.read(accentColorProvider);
      expect(restored.name, 'Electric Blue');
      expect(restored.color, const Color(0xFF38BDF8));
    });

    test('saves and restores Royal Purple', () async {
      final container = ProviderContainer();
      final royalPurple = kAccentColors.firstWhere(
        (c) => c.name == 'Royal Purple',
      );

      await container.read(accentColorProvider.notifier).setColor(royalPurple);
      expect(container.read(accentColorProvider).name, 'Royal Purple');
      expect(
        AppPreferencesService.getAccentColor(),
        royalPurple.color.toARGB32(),
      );

      final restarted = await simulateAppRestart(container);
      final restored = restarted.read(accentColorProvider);
      expect(restored.name, 'Royal Purple');
      expect(restored.color, const Color(0xFF9353D3));
    });

    test('saves and restores Vivid Coral', () async {
      final container = ProviderContainer();
      final vividCoral = kAccentColors.firstWhere(
        (c) => c.name == 'Vivid Coral',
      );

      await container.read(accentColorProvider.notifier).setColor(vividCoral);
      expect(container.read(accentColorProvider).name, 'Vivid Coral');
      expect(
        AppPreferencesService.getAccentColor(),
        vividCoral.color.toARGB32(),
      );

      final restarted = await simulateAppRestart(container);
      final restored = restarted.read(accentColorProvider);
      expect(restored.name, 'Vivid Coral');
      expect(restored.color, const Color(0xFFF43F5E));
    });

    test(
      'invalid stored colour falls back safely to default Neon Lime Green',
      () async {
        AppPreferencesService.resetForTesting();
        SharedPreferences.setMockInitialValues({
          'ecorp_accent_color': 0xFF123456,
        });
        await AppPreferencesService.init();

        final container = ProviderContainer();
        addTearDown(container.dispose);

        final restored = container.read(accentColorProvider);
        expect(restored.name, 'Neon Lime Green');
        expect(restored.color, const Color(0xFF98E836));
      },
    );
  });

  group('Theme and Accent Colour integration', () {
    test('changing the theme does not overwrite the accent colour', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final vividCoral = kAccentColors.firstWhere(
        (c) => c.name == 'Vivid Coral',
      );
      await container.read(accentColorProvider.notifier).setColor(vividCoral);
      await container.read(themeModeProvider.notifier).setDarkMode(false);

      expect(container.read(themeModeProvider), ThemeMode.light);
      expect(container.read(accentColorProvider).name, 'Vivid Coral');
      expect(
        AppPreferencesService.getAccentColor(),
        vividCoral.color.toARGB32(),
      );
      expect(AppPreferencesService.getDarkMode(), isFalse);
    });

    test('changing the accent colour does not overwrite the theme', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(themeModeProvider.notifier).setDarkMode(false);
      final royalPurple = kAccentColors.firstWhere(
        (c) => c.name == 'Royal Purple',
      );
      await container.read(accentColorProvider.notifier).setColor(royalPurple);

      expect(container.read(themeModeProvider), ThemeMode.light);
      expect(container.read(accentColorProvider).name, 'Royal Purple');
      expect(AppPreferencesService.getDarkMode(), isFalse);
      expect(
        AppPreferencesService.getAccentColor(),
        royalPurple.color.toARGB32(),
      );
    });

    test(
      'both settings can be changed independently and survive restart',
      () async {
        final container = ProviderContainer();
        final electricBlue = kAccentColors.firstWhere(
          (c) => c.name == 'Electric Blue',
        );

        await container.read(themeModeProvider.notifier).setDarkMode(false);
        await container
            .read(accentColorProvider.notifier)
            .setColor(electricBlue);

        final firstRestart = await simulateAppRestart(container);
        expect(firstRestart.read(themeModeProvider), ThemeMode.light);
        expect(firstRestart.read(accentColorProvider).name, 'Electric Blue');
        expect(
          firstRestart.read(accentColorProvider).color,
          const Color(0xFF38BDF8),
        );

        // Change only theme back to dark, accent should remain Electric Blue
        await firstRestart.read(themeModeProvider.notifier).setDarkMode(true);
        final secondRestart = await simulateAppRestart(firstRestart);
        expect(secondRestart.read(themeModeProvider), ThemeMode.dark);
        expect(secondRestart.read(accentColorProvider).name, 'Electric Blue');
        expect(
          secondRestart.read(accentColorProvider).color,
          const Color(0xFF38BDF8),
        );
      },
    );
  });
}
