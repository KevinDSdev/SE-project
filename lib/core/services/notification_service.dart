import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Outcome of attempting to schedule or restore a notification.
enum NotificationScheduleStatus {
  scheduledExact,
  scheduledInexact,
  permissionDenied,
  unsupportedPlatform,
  failed,
}

/// Detailed result returned when scheduling the daily log reminder.
class DailyReminderScheduleResult {
  final NotificationScheduleStatus status;
  final tz.TZDateTime? scheduledDate;
  final String? errorMessage;

  const DailyReminderScheduleResult({
    required this.status,
    this.scheduledDate,
    this.errorMessage,
  });

  bool get isScheduled =>
      status == NotificationScheduleStatus.scheduledExact ||
      status == NotificationScheduleStatus.scheduledInexact;
}

/// Platform abstraction for local notification operations so [NotificationService]
/// can be unit-tested without requiring real Android platform channels.
abstract class NotificationPlatformClient {
  Future<bool?> initialize();

  Future<void> createNotificationChannel(AndroidNotificationChannel channel);

  Future<bool?> areNotificationsEnabled();

  Future<bool?> requestNotificationsPermission();

  Future<bool?> canScheduleExactNotifications();

  Future<void> cancel(int id);

  Future<void> zonedScheduleDaily({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required AndroidScheduleMode androidScheduleMode,
    String? payload,
  });

  Future<String> getLocalTimezoneName();
}

class _FlutterLocalNotificationsClient implements NotificationPlatformClient {
  _FlutterLocalNotificationsClient({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  AndroidFlutterLocalNotificationsPlugin? get _androidPlugin => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<bool?> initialize() {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const settings = InitializationSettings(android: androidSettings);
    return _plugin.initialize(settings: settings);
  }

  @override
  Future<void> createNotificationChannel(
    AndroidNotificationChannel channel,
  ) async {
    await _androidPlugin?.createNotificationChannel(channel);
  }

  @override
  Future<bool?> areNotificationsEnabled() async {
    return _androidPlugin?.areNotificationsEnabled();
  }

  @override
  Future<bool?> requestNotificationsPermission() async {
    return _androidPlugin?.requestNotificationsPermission();
  }

  @override
  Future<bool?> canScheduleExactNotifications() async {
    return _androidPlugin?.canScheduleExactNotifications();
  }

  @override
  Future<void> cancel(int id) {
    return _plugin.cancel(id: id);
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
  }) {
    return _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: androidScheduleMode,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  @override
  Future<String> getLocalTimezoneName() async {
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    return timezoneInfo.identifier;
  }
}

/// Shared local notification service for FinPulse.
///
/// Notification ID reservations (to avoid collisions across features):
/// - `1001`: Daily Log Reminder (Settings module)
/// - Other modules (custom reminders, bill reminders, scanned-bill alerts)
///   should reserve separate ID ranges (e.g. 2000+, 3000+, 4000+) and channels.
class NotificationService {
  NotificationService._([
    this._isSupportedPlatformOverride,
    NotificationPlatformClient? client,
    DateTime Function()? nowProvider,
  ]) : _client = client ?? _FlutterLocalNotificationsClient(),
       _nowProvider = nowProvider ?? DateTime.now;

  /// Creates an isolated instance for unit/widget testing.
  @visibleForTesting
  factory NotificationService.test({
    required NotificationPlatformClient client,
    DateTime Function()? nowProvider,
    bool isSupportedPlatform = true,
  }) {
    return NotificationService._(isSupportedPlatform, client, nowProvider);
  }

  static final NotificationService instance = NotificationService._();

  /// Reserved notification ID for the Daily Log Reminder.
  static const int dailyLogReminderId = 1001;

  /// Dedicated Android notification channel for the Daily Log Reminder.
  static const String dailyLogReminderChannelId = 'finpulse_daily_log_reminder';
  static const String dailyLogReminderChannelName = 'Daily Log Reminder';
  static const String dailyLogReminderChannelDescription =
      'Daily reminders to add your financial logs in FinPulse.';

  static const String dailyLogReminderTitle = 'Daily Financial Log Reminder';
  static const String dailyLogReminderBody =
      'Take a moment to record today\'s income and expenses in FinPulse.';
  static const String dailyLogReminderPayload = 'daily_log_reminder';

  static const String _fallbackTimezone = 'Asia/Colombo';

  final NotificationPlatformClient _client;
  final DateTime Function() _nowProvider;
  final bool? _isSupportedPlatformOverride;

  bool _isInitialized = false;
  bool _timeZonesInitialized = false;

  bool get isSupportedPlatform {
    if (_isSupportedPlatformOverride != null) {
      return _isSupportedPlatformOverride;
    }
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  }

  bool get isInitialized => _isInitialized;

  /// Initializes timezone data, local timezone, plugin bindings, and channels.
  Future<bool> init() async {
    if (!isSupportedPlatform) {
      return false;
    }
    if (_isInitialized) {
      return true;
    }

    await _configureLocalTimeZone();

    await _client.initialize();

    const channel = AndroidNotificationChannel(
      dailyLogReminderChannelId,
      dailyLogReminderChannelName,
      description: dailyLogReminderChannelDescription,
      importance: Importance.high,
      enableVibration: true,
    );
    await _client.createNotificationChannel(channel);

    _isInitialized = true;
    return true;
  }

  Future<void> _configureLocalTimeZone() async {
    if (!_timeZonesInitialized) {
      tz_data.initializeTimeZones();
      _timeZonesInitialized = true;
    }

    try {
      final tzName = await _client.getLocalTimezoneName();
      if (tzName.isNotEmpty) {
        tz.setLocalLocation(tz.getLocation(tzName));
        return;
      }
    } catch (error) {
      debugPrint('Failed to resolve device timezone: $error');
    }

    try {
      tz.setLocalLocation(tz.getLocation(_fallbackTimezone));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  /// Calculates the next valid occurrence of [time] in the configured local
  /// timezone. If [time] has already passed (or equals now) today, returns
  /// tomorrow at [time].
  tz.TZDateTime calculateNextDailyOccurrence(TimeOfDay time) {
    final now = tz.TZDateTime.from(_nowProvider(), tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + 1,
        time.hour,
        time.minute,
      );
    }
    return scheduled;
  }

  /// Cancels any previously scheduled Daily Log Reminder notification.
  Future<void> cancelDailyLogReminder() async {
    if (!isSupportedPlatform) {
      return;
    }
    if (!_isInitialized) {
      await init();
    }
    await _client.cancel(dailyLogReminderId);
  }

  /// Schedules (or replaces) the daily repeating notification for [time].
  ///
  /// Cancels any previous schedule with [dailyLogReminderId] first to guarantee
  /// no duplicate notifications exist.
  Future<DailyReminderScheduleResult> scheduleDailyLogReminder(
    TimeOfDay time, {
    bool requestPermission = true,
  }) async {
    if (!isSupportedPlatform) {
      return const DailyReminderScheduleResult(
        status: NotificationScheduleStatus.unsupportedPlatform,
      );
    }

    try {
      if (!_isInitialized) {
        await init();
      }

      var hasPermission = await _client.areNotificationsEnabled();
      if (hasPermission == false && requestPermission) {
        hasPermission = await _client.requestNotificationsPermission();
      }

      if (hasPermission == false) {
        return const DailyReminderScheduleResult(
          status: NotificationScheduleStatus.permissionDenied,
          errorMessage: 'Notification permission was denied.',
        );
      }

      // Cancel previous daily reminder before scheduling to prevent duplicates.
      await _client.cancel(dailyLogReminderId);

      final scheduledDate = calculateNextDailyOccurrence(time);
      final canExact = await _client.canScheduleExactNotifications() ?? false;
      final scheduleMode = canExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;

      const notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          dailyLogReminderChannelId,
          dailyLogReminderChannelName,
          channelDescription: dailyLogReminderChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
        ),
      );

      await _client.zonedScheduleDaily(
        id: dailyLogReminderId,
        title: dailyLogReminderTitle,
        body: dailyLogReminderBody,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: scheduleMode,
        payload: dailyLogReminderPayload,
      );

      return DailyReminderScheduleResult(
        status: canExact
            ? NotificationScheduleStatus.scheduledExact
            : NotificationScheduleStatus.scheduledInexact,
        scheduledDate: scheduledDate,
      );
    } catch (error) {
      debugPrint('Failed to schedule daily log reminder: $error');
      return DailyReminderScheduleResult(
        status: NotificationScheduleStatus.failed,
        errorMessage: error.toString(),
      );
    }
  }

  /// Restores or reconciles the Daily Log Reminder during app startup using
  /// the persisted [time]. Does not prompt the user for permission on launch.
  Future<DailyReminderScheduleResult> restoreDailyLogReminder(TimeOfDay time) {
    return scheduleDailyLogReminder(time, requestPermission: false);
  }
}
