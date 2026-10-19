# Prot - Flutter Android & iOS Mobile Application

A cross-platform mobile application starter built with **Flutter 3.47**, **Dart 3.13**, and **Riverpod 3** state management. Designed for both **Android** and **iOS** with clean architecture, responsive layouts, and interactive dark/light mode switching.

---

## Architecture & Project Structure

```text
lib/
├── main.dart                               # App entry point with ProviderScope
├── core/
│   ├── constants/
│   │   ├── app_colors.dart                 # Indigo/Cyan/Rose palette, light & dark neutrals
│   │   └── app_strings.dart                # Centralized string constants
│   ├── providers/
│   │   └── theme_provider.dart             # Riverpod Notifier for ThemeMode (System, Light, Dark)
│   └── theme/
│       └── app_theme.dart                  # Material 3 light & dark ThemeData definitions
└── features/
    ├── onboarding/
    │   ├── models/onboarding_item.dart     # Onboarding carousel slide model
    │   └── presentation/onboarding_screen.dart # Interactive walkthrough with dots & skip
    ├── auth/
    │   ├── providers/auth_provider.dart    # Riverpod authentication state & notifier
    │   └── presentation/
    │       ├── login_screen.dart           # Sign-in form with validation & demo credentials
    │       └── register_screen.dart        # User registration screen
    ├── dashboard/
    │   └── presentation/dashboard_screen.dart  # Metric cards, KPI tiles, quick actions, activity
    ├── explore/
    │   └── presentation/explore_screen.dart    # Search, category chips, module blueprints
    ├── activity/
    │   └── presentation/activity_screen.dart   # Build events, alerts, and timeline
    ├── settings/
    │   └── presentation/settings_screen.dart   # Theme mode selector, user profile, sign out
    └── navigation/
        └── main_wrapper.dart               # Bottom navigation bar with persistent tabs
```

---

## Quick Start & Running Locally

Flutter is installed at `D:\flutter\bin` and is configured in your user `PATH`.

### 1. Test Instantly on Chrome / Edge (Recommended First Step)
To test the UI, interactions, and Riverpod state right away without waiting for an Android emulator:
```bash
flutter run -d chrome
```

### 2. Run on Android
1. Install [Android Studio](https://developer.android.com/studio) to install the Android SDK and create an Android Virtual Device (AVD).
2. Start your emulator or plug in an Android phone with USB Debugging enabled.
3. Verify connection:
   ```bash
   flutter devices
   ```
4. Run the app:
   ```bash
   flutter run
   ```

### 3. Run on iOS
> *Note: Building for iOS requires macOS with Xcode installed.*
1. Push this project to GitHub/Git.
2. Clone onto your Mac.
3. Install CocoaPods dependencies:
   ```bash
   cd ios && pod install && cd ..
   ```
4. Run in iOS Simulator:
   ```bash
   flutter run -d iphone
   ```

---

## Code Quality & Verification

- **Code Analysis**:
  ```bash
  flutter analyze
  ```
  *(Status: 0 issues found)*

- **Automated Tests**:
  ```bash
  flutter test
  ```
  *(Status: All tests passed)*
