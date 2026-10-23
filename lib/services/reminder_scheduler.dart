import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Notification ids used by the app.
abstract final class ReminderIds {
  static const upcomingPeriod = 1;
  static const dailyCheckIn = 2;
}

/// Schedules local notifications. Nothing is sent to a server.
abstract interface class ReminderScheduler {
  Future<void> init();

  /// Asks the OS for permission to show notifications.
  Future<bool> requestPermission();

  Future<void> scheduleOnce({
    required int id,
    required DateTime at,
    required String title,
    required String body,
  });

  Future<void> scheduleDaily({
    required int id,
    required TimeOfDay time,
    required String title,
    required String body,
  });

  Future<void> cancel(int id);
}

class LocalNotificationScheduler implements ReminderScheduler {
  final _plugin = FlutterLocalNotificationsPlugin();

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'cyclia_reminders',
      'Reminders',
      channelDescription: 'Upcoming period and daily check-in reminders',
      // Hide the content on a locked screen; health reminders are private.
      visibility: NotificationVisibility.private,
    ),
    iOS: DarwinNotificationDetails(),
  );

  @override
  Future<void> init() async {
    tz_data.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (_) {
      // Unknown zone name: fall back to UTC rather than failing to start.
      tz.setLocalLocation(tz.UTC);
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Permission is requested when the user turns a reminder on.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  @override
  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await ios?.requestPermissions(alert: true, sound: true) ?? false;
  }

  @override
  Future<void> scheduleOnce({
    required int id,
    required DateTime at,
    required String title,
    required String body,
  }) async {
    await cancel(id);
    final when = tz.TZDateTime.from(at, tz.local);
    if (!when.isAfter(tz.TZDateTime.now(tz.local))) return;
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: when,
      notificationDetails: _details,
      // Inexact alarms need no SCHEDULE_EXACT_ALARM permission; a reminder
      // doesn't need to-the-second precision.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> scheduleDaily({
    required int id,
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {
    await cancel(id);
    final now = tz.TZDateTime.now(tz.local);
    var first = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (!first.isAfter(now)) first = first.add(const Duration(days: 1));
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: first,
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);
}
