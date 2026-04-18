import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidSettings,
    );

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Australia/Sydney'));

    await _notificationsPlugin.initialize(
      settings: settings,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  static Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'silent_scheduler_channel',
      'Silent Scheduler Notifications',
      channelDescription: 'Notifications for meeting reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'silent_scheduler_channel',
      'Silent Scheduler Notifications',
      channelDescription: 'Notifications for meeting reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    final tzScheduled = tz.TZDateTime.from(scheduledTime, tz.local);

    debugPrint('Now: ${DateTime.now()}');
    debugPrint('ScheduledTime raw: $scheduledTime');
    debugPrint('ScheduledTime tz: $tzScheduled');

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzScheduled,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> printPendingNotifications() async {
    final pending = await _notificationsPlugin.pendingNotificationRequests();
    debugPrint('Pending notifications: ${pending.length}');
    for (final item in pending) {
      debugPrint('ID: ${item.id}, Title: ${item.title}, Body: ${item.body}');
    }
  }
}