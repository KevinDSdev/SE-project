import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/app_preferences_service.dart';

class AccentColorOption {
  final String name;
  final Color color;

  const AccentColorOption({required this.name, required this.color});
}

const List<AccentColorOption> kAccentColors = [
  AccentColorOption(name: 'Neon Lime Green', color: Color(0xFF98E836)),
  AccentColorOption(name: 'Electric Blue', color: Color(0xFF38BDF8)),
  AccentColorOption(name: 'Royal Purple', color: Color(0xFF9353D3)),
  AccentColorOption(name: 'Vivid Coral', color: Color(0xFFF43F5E)),
];

class AccentColorNotifier extends Notifier<AccentColorOption> {
  @override
  AccentColorOption build() {
    final savedVal = AppPreferencesService.getAccentColor();
    if (savedVal != null) {
      for (final opt in kAccentColors) {
        if (opt.color.toARGB32() == savedVal) {
          return opt;
        }
      }
    }
    return kAccentColors[0];
  }

  void setColor(AccentColorOption option) {
    state = option;
    AppPreferencesService.saveAccentColor(option.color.toARGB32());
  }
}

final accentColorProvider =
    NotifierProvider<AccentColorNotifier, AccentColorOption>(
  AccentColorNotifier.new,
);

class NotificationsEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
  void setVal(bool val) => state = val;
  void setEnabled(bool val) => state = val;
}

final notificationsEnabledProvider =
    NotifierProvider<NotificationsEnabledNotifier, bool>(
  NotificationsEnabledNotifier.new,
);

class DailyReminderTimeNotifier extends Notifier<TimeOfDay> {
  @override
  TimeOfDay build() => const TimeOfDay(hour: 20, minute: 0);

  void setTime(TimeOfDay time) => state = time;
}

final dailyReminderTimeProvider =
    NotifierProvider<DailyReminderTimeNotifier, TimeOfDay>(
  DailyReminderTimeNotifier.new,
);

class GpsSuggestionsNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
  void setVal(bool val) => state = val;
  void setEnabled(bool val) => state = val;
}

final gpsSuggestionsProvider =
    NotifierProvider<GpsSuggestionsNotifier, bool>(
  GpsSuggestionsNotifier.new,
);

class CloudSyncNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
  void setVal(bool val) => state = val;
  void setEnabled(bool val) => state = val;
}

final cloudSyncProvider =
    NotifierProvider<CloudSyncNotifier, bool>(
  CloudSyncNotifier.new,
);

class BiometricsNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
  void setVal(bool val) => state = val;
  void setEnabled(bool val) => state = val;
}

final biometricsProvider =
    NotifierProvider<BiometricsNotifier, bool>(
  BiometricsNotifier.new,
);

class CustomReminderItem {
  final String id;
  final String title;
  final TimeOfDay time;
  final String recurrence;

  const CustomReminderItem({
    required this.id,
    required this.title,
    required this.time,
    required this.recurrence,
  });
}

class CustomRemindersNotifier extends Notifier<List<CustomReminderItem>> {
  @override
  List<CustomReminderItem> build() => const [
        CustomReminderItem(
          id: 'rem_1',
          title: 'Daily Budget Review',
          time: TimeOfDay(hour: 20, minute: 0),
          recurrence: 'Everyday',
        ),
      ];

  void addReminder(String title, TimeOfDay time, String recurrence) {
    state = [
      ...state,
      CustomReminderItem(
        id: 'rem_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        time: time,
        recurrence: recurrence,
      ),
    ];
  }
}

final customRemindersProvider =
    NotifierProvider<CustomRemindersNotifier, List<CustomReminderItem>>(
  CustomRemindersNotifier.new,
);
