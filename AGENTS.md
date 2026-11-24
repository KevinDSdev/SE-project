# AGENTS.md

## Project shape

- Flutter app, package name `prot`. Branding is inconsistent: UI title is `ECORP`, while services, SQLite files, and comments use `FinPulse` / `finpulse_*`. Search for all three before renaming anything.
- Supported targets are Android, iOS, and web. Windows desktop support was removed (no `windows/` folder); do not add Windows-only commands or configuration.
- This is a UI prototype, not a connected product. There is no direct HTTP/backend dependency; auth is mocked (any email plus a 6+ character password works), and transactions, budgets, goals, and custom categories are seeded in Riverpod and reset on restart.
- Persisted state is limited to theme/accent + daily reminder time (SharedPreferences, `ecorp_*` keys) and analytics customization / dashboard layout / report export preferences (SQLite on native, IndexedDB on web). Report export and bank-statement import are UI demos.

## Commands

- `flutter pub get`
- `flutter run -d chrome` (web is a real target), `flutter run -d edge`, or `flutter run` on an Android device. iOS requires macOS/Xcode.
- `flutter test` - full suite (174 tests) runs in roughly 10 seconds; no emulator or browser required.
- Single file: `flutter test test/report_export_db_test.dart`
- Single test: `flutter test test/report_export_db_test.dart --plain-name "restore persisted selections"`
- `flutter analyze` - baseline has 4 existing warnings (unused locals/fields) and exits with code 1 on the installed Flutter 3.50.1. Compare before/after instead of treating the whole output as caused by your change.
- There is no CI or pre-commit config; run verification manually.

## Architecture

- Entry flow: `lib/main.dart` → `SignUpScreen` (not onboarding) → `MainWrapper` after login/signup. `MainWrapper` hosts five `IndexedStack` tabs; Analytics and Profile each use a nested `Navigator`. There is no router package.
- Startup order in `main.dart` matters: `AppPreferencesService.init()` → `AnalyticsCustomizationRepository.instance.init()` → dashboard/report repositories → `restoreDailyLogReminderOnStartup()` → `runApp`. Repositories preload caches so Riverpod `Notifier.build()` can read synchronously.
- Persistence contract: `AnalyticsCustomizationStorage`, implemented by `analytics_customization_db.dart` (SQLite) and `analytics_customization_web_db.dart` (IndexedDB). `analytics_customization_storage_factory.dart` selects the backend with `dart.library.js_interop`, not `dart.library.html`. The three analytics repositories share one storage connection.
- Adding a persisted analytics field means updating the contract, both backends, both model/DTO mappings, both `databaseVersion` values, and the upgrade paths. Do not add new analytics settings directly to SharedPreferences; SharedPreferences is only the legacy migration source.
- Use Riverpod 3 `Notifier` / `NotifierProvider`; there is no codegen or `build_runner`. Provider `build()` methods read repository caches; async writes belong in notifier methods.
- Local notifications are Android-only (`NotificationService.isSupportedPlatform`) and no-op on web/desktop/iOS. The daily log reminder reserves ID `1001` and channel `finpulse_daily_log_reminder`; new notification features need separate ID ranges and channels.

## Testing quirks

- SQLite tests use `sqflite_common_ffi` with temp database files; web persistence tests use `newIdbFactoryMemory()`. Both run on the Dart VM.
- In tests, call `SharedPreferences.setMockInitialValues({})` and `AppPreferencesService.init()` first; call `AppPreferencesService.resetForTesting()` when simulating an app restart.
- Prefer injecting storage into repositories (e.g. `AnalyticsCustomizationRepository(db: ...)`) or using an in-memory `AnalyticsCustomizationStorage` fake. Global `instance` singletons leak state between tests; `test/dashboard_layout_screen_test.dart` has a reusable fake pattern.
- Notification tests use `NotificationService.test(client: fake, nowProvider: ...)`; do not exercise real platform channels.

## Docs

- `README.md` covers setup, architecture, persistence, and the current test/analyze baseline. Keep it in sync when commands or platform support change.
