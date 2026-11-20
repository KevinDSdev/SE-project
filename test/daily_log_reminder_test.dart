import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prot/core/services/app_preferences_service.dart';
import 'package:prot/core/services/notification_service.dart';
import 'package:prot/features/settings/providers/settings_provider.dart';
import 'package:prot/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

class _ScheduledCall {
  final int id;
  final String title;
  final String body;
  final tz.TZDateTime scheduledDate;
  final AndroidScheduleMode scheduleMode;
  final String? payload;

  const _ScheduledCall({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledDate,
    required this.scheduleMode,
    this.payload,
  });
}

class _FakeNotificationPlatformClient implements NotificationPlatformClient {
  bool notificationsEnabled;
  bool permissionRequestResult;
  bool exactAlarmsAllowed;
  final String timezoneName = 'Asia/Colombo';

  int initializeCalls = 0;
  int permissionRequestCalls = 0;
  final List<AndroidNotificationChannel> createdChannels = [];
  final List<int> cancelledIds = [];
  final List<_ScheduledCall> scheduledCalls = [];
  final Map<int, _ScheduledCall> activeSchedules = {};
  final List<String> callLog = [];

  _FakeNotificationPlatformClient({
    this.notificationsEnabled = true,
    this.permissionRequestResult = true,
    this.exactAlarmsAllowed = true,
  });

  @override
  Future<bool?> initialize() async {
    initializeCalls++;
    callLog.add('initialize');
    return true;
  }

  @override
  Future<void> createNotificationChannel(
    AndroidNotificationChannel channel,
  ) async {
    createdChannels.add(channel);
    callLog.add('createChannel:${channel.id}');
  }

  @override
  Future<bool?> areNotificationsEnabled() async {
    callLog.add('areNotificationsEnabled');
    return notificationsEnabled;
  }

  @override
  Future<bool?> requestNotificationsPermission() async {
    permissionRequestCalls++;
    callLog.add('requestNotificationsPermission');
    notificationsEnabled = permissionRequestResult;
    return permissionRequestResult;
  }

  @override
  Future<bool?> canScheduleExactNotifications() async {
    callLog.add('canScheduleExactNotifications');
    return exactAlarmsAllowed;
  }

  @override
  Future<void> cancel(int id) async {
    cancelledIds.add(id);
    activeSchedules.remove(id);
    callLog.add('cancel:$id');
  }

  @override
  Future<void> zonedScheduleDaily({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required AndroidScheduleMode androidScheduleMode,
    String? payload,
  }) async {
    final call = _ScheduledCall(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      scheduleMode: androidScheduleMode,
      payload: payload,
    );
    scheduledCalls.add(call);
    activeSchedules[id] = call;
    callLog.add('schedule:$id');
  }

  @override
  Future<String> getLocalTimezoneName() async {
    return timezoneName;
  }
}

void main() {
  setUp(() async {
    AppPreferencesService.resetForTesting();
    SharedPreferences.setMockInitialValues({});
    await AppPreferencesService.init();
  });

  group('AppPreferencesService daily reminder persistence', () {
    test('returns null when no daily reminder time is saved', () {
      expect(AppPreferencesService.getDailyReminderHour(), isNull);
      expect(AppPreferencesService.getDailyReminderMinute(), isNull);
      expect(AppPreferencesService.getDailyReminderTime(), isNull);
    });

    test(
      'saves and loads daily reminder hour and minute persistently',
      () async {
        await AppPreferencesService.saveDailyReminderTime(hour: 7, minute: 45);

        expect(AppPreferencesService.getDailyReminderHour(), 7);
        expect(AppPreferencesService.getDailyReminderMinute(), 45);
        expect(AppPreferencesService.getDailyReminderTime(), (
          hour: 7,
          minute: 45,
        ));

        // Simulate app restart by resetting cached SharedPreferences wrapper.
        AppPreferencesService.resetForTesting();
        await AppPreferencesService.init();

        expect(AppPreferencesService.getDailyReminderTime(), (
          hour: 7,
          minute: 45,
        ));
      },
    );
  });

  group('DailyReminderTimeNotifier', () {
    test('defaults to 8:00 PM when no preference exists', () {
      final client = _FakeNotificationPlatformClient();
      final service = NotificationService.test(client: client);
      final container = ProviderContainer(
        overrides: [notificationServiceProvider.overrideWithValue(service)],
      );
      addTearDown(container.dispose);

      expect(
        container.read(dailyReminderTimeProvider),
        const TimeOfDay(hour: 20, minute: 0),
      );
    });

    test(
      'loads saved time on startup and updates saved time on change',
      () async {
        await AppPreferencesService.saveDailyReminderTime(hour: 9, minute: 15);
        final client = _FakeNotificationPlatformClient();
        final service = NotificationService.test(
          client: client,
          nowProvider: () => DateTime.utc(2026, 11, 20, 2, 0),
        );

        final container = ProviderContainer(
          overrides: [notificationServiceProvider.overrideWithValue(service)],
        );
        addTearDown(container.dispose);

        expect(
          container.read(dailyReminderTimeProvider),
          const TimeOfDay(hour: 9, minute: 15),
        );

        const updated = TimeOfDay(hour: 21, minute: 30);
        final result = await container
            .read(dailyReminderTimeProvider.notifier)
            .setTime(updated);

        expect(result.isScheduled, isTrue);
        expect(container.read(dailyReminderTimeProvider), updated);
        expect(AppPreferencesService.getDailyReminderTime(), (
          hour: 21,
          minute: 30,
        ));

        // Verify fresh ProviderContainer loads the updated persisted time.
        final restartedContainer = ProviderContainer(
          overrides: [notificationServiceProvider.overrideWithValue(service)],
        );
        addTearDown(restartedContainer.dispose);
        expect(restartedContainer.read(dailyReminderTimeProvider), updated);
      },
    );
  });

  group('NotificationService scheduling & resilience', () {
    test('cancels previous schedule before scheduling replacement and avoids duplicates', () async {
      final client = _FakeNotificationPlatformClient();
      // 2026-11-20 10:00 Asia/Colombo (+05:30) == 04:30 UTC
      final service = NotificationService.test(
        client: client,
        nowProvider: () => DateTime.utc(2026, 11, 20, 4, 30),
      );

      final first = await service.scheduleDailyLogReminder(
        const TimeOfDay(hour: 18, minute: 0),
      );
      final second = await service.scheduleDailyLogReminder(
        const TimeOfDay(hour: 21, minute: 15),
      );

      expect(first.status, NotificationScheduleStatus.scheduledExact);
      expect(second.status, NotificationScheduleStatus.scheduledExact);

      // Cancel must happen before every schedule with the reserved ID.
      expect(client.cancelledIds, [
        NotificationService.dailyLogReminderId,
        NotificationService.dailyLogReminderId,
      ]);
      expect(client.activeSchedules.length, 1);
      final active =
          client.activeSchedules[NotificationService.dailyLogReminderId]!;
      expect(active.scheduledDate.hour, 21);
      expect(active.scheduledDate.minute, 15);
      expect(active.scheduledDate.day, 20);
      expect(active.scheduleMode, AndroidScheduleMode.exactAllowWhileIdle);

      final firstCancelIdx = client.callLog.indexOf(
        'cancel:${NotificationService.dailyLogReminderId}',
      );
      final firstScheduleIdx = client.callLog.indexOf(
        'schedule:${NotificationService.dailyLogReminderId}',
      );
      expect(firstCancelIdx, lessThan(firstScheduleIdx));
    });

    test(
      'schedules for next day when selected time has already passed today',
      () async {
        final client = _FakeNotificationPlatformClient();
        // 2026-11-20 20:30 Asia/Colombo (+05:30) == 15:00 UTC
        final service = NotificationService.test(
          client: client,
          nowProvider: () => DateTime.utc(2026, 11, 20, 15, 0),
        );

        final result = await service.scheduleDailyLogReminder(
          const TimeOfDay(hour: 20, minute: 0),
        );

        expect(result.isScheduled, isTrue);
        expect(result.scheduledDate?.year, 2026);
        expect(result.scheduledDate?.month, 11);
        expect(result.scheduledDate?.day, 21);
        expect(result.scheduledDate?.hour, 20);
        expect(result.scheduledDate?.minute, 0);
      },
    );

    test(
      'falls back to inexact scheduling when exact alarms are unavailable',
      () async {
        final client = _FakeNotificationPlatformClient(
          exactAlarmsAllowed: false,
        );
        final service = NotificationService.test(
          client: client,
          nowProvider: () => DateTime.utc(2026, 11, 20, 4, 30),
        );

        final result = await service.scheduleDailyLogReminder(
          const TimeOfDay(hour: 20, minute: 0),
        );

        expect(result.status, NotificationScheduleStatus.scheduledInexact);
        expect(
          client
              .activeSchedules[NotificationService.dailyLogReminderId]
              ?.scheduleMode,
          AndroidScheduleMode.inexactAllowWhileIdle,
        );
      },
    );

    test(
      'handles notification permission denial gracefully without scheduling',
      () async {
        final client = _FakeNotificationPlatformClient(
          notificationsEnabled: false,
          permissionRequestResult: false,
        );
        final service = NotificationService.test(
          client: client,
          nowProvider: () => DateTime.utc(2026, 11, 20, 4, 30),
        );

        final container = ProviderContainer(
          overrides: [notificationServiceProvider.overrideWithValue(service)],
        );
        addTearDown(container.dispose);

        final result = await container
            .read(dailyReminderTimeProvider.notifier)
            .setTime(const TimeOfDay(hour: 19, minute: 0));

        expect(result.status, NotificationScheduleStatus.permissionDenied);
        expect(client.permissionRequestCalls, 1);
        expect(client.scheduledCalls, isEmpty);
        // Preference should still be persisted so enabling permission later keeps user choice.
        expect(AppPreferencesService.getDailyReminderTime(), (
          hour: 19,
          minute: 0,
        ));
      },
    );

    test(
      'restores saved daily reminder on startup without prompting permission',
      () async {
        await AppPreferencesService.saveDailyReminderTime(hour: 18, minute: 45);
        final client = _FakeNotificationPlatformClient(
          notificationsEnabled: true,
        );
        final service = NotificationService.test(
          client: client,
          nowProvider: () => DateTime.utc(2026, 11, 20, 4, 30),
        );

        final result = await restoreDailyLogReminderOnStartup(
          notificationService: service,
        );

        expect(result?.isScheduled, isTrue);
        expect(client.permissionRequestCalls, 0);
        expect(client.activeSchedules.length, 1);
        final active =
            client.activeSchedules[NotificationService.dailyLogReminderId]!;
        expect(active.scheduledDate.hour, 18);
        expect(active.scheduledDate.minute, 45);
      },
    );

    test(
      'startup restoration does not prompt if notifications are disabled',
      () async {
        await AppPreferencesService.saveDailyReminderTime(hour: 18, minute: 45);
        final client = _FakeNotificationPlatformClient(
          notificationsEnabled: false,
        );
        final service = NotificationService.test(client: client);

        final result = await restoreDailyLogReminderOnStartup(
          notificationService: service,
        );

        expect(result?.status, NotificationScheduleStatus.permissionDenied);
        expect(client.permissionRequestCalls, 0);
        expect(client.scheduledCalls, isEmpty);
      },
    );

    test(
      'behaves safely on unsupported platforms such as Chrome/web',
      () async {
        final client = _FakeNotificationPlatformClient();
        final service = NotificationService.test(
          client: client,
          isSupportedPlatform: false,
        );

        expect(await service.init(), isFalse);
        final result = await service.scheduleDailyLogReminder(
          const TimeOfDay(hour: 20, minute: 0),
        );
        await service.cancelDailyLogReminder();

        expect(result.status, NotificationScheduleStatus.unsupportedPlatform);
        expect(client.initializeCalls, 0);
        expect(client.scheduledCalls, isEmpty);
        expect(client.cancelledIds, isEmpty);
      },
    );
  });
}
