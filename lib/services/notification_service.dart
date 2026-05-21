import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Service for managing local push notifications for lunchtime suggestions.
///
/// Exposes init(), scheduleDailyNotification(), cancelAll(), and a tap callback.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Function(String? restaurantId)? onNotificationTap;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'lunchtime_suggestions_channel',
    'Lunchtime Suggestions',
    description: 'Daily lunch suggestions based on nearby restaurants.',
    importance: Importance.high,
  );

  static bool _initialized = false;

  /// Initialize notification plugin and timezones. Returns true if permission is granted.
  static Future<bool> init() async {
    if (_initialized) {
      final granted = await requestPermission();
      return granted;
    }

    tz_data.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    final InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        onNotificationTap?.call(response.payload);
      },
    );

    // Ensure Android channel is created
    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(_channel);
    }

    _initialized = true;
    return requestPermission();
  }

  /// Request notification permissions (iOS side). Returns true if granted.
  static Future<bool> requestPermission() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    }
    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }
    }
    return true;
  }

  /// Check whether notification permission has been granted.
  static Future<bool> isPermissionGranted() async {
    if (Platform.isIOS) {
      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final settings = await iosPlugin?.requestPermissions(alert: false, badge: false, sound: false);
      // requestPermissions on iOS returning an int means granted; this is a proxy.
      // A better way: use UNUserNotificationCenter, but flutter_local_notifications doesn't expose it.
      // We'll infer from scheduling and rely on external OS prompt.
      return (settings ?? false);
    }
    // Best-effort: assume true on Android unless we can query the newer APIs.
    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidPlugin?.areNotificationsEnabled() ?? true;
      return granted;
    }
    return true;
  }

  /// Schedule a daily repeating local notification at the specified time.
  static Future<void> scheduleDailyNotification(TimeOfDay time, {String? payload}) async {
    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    final tzDateTime = tz.TZDateTime.from(scheduled, tz.local);

    await _plugin.zonedSchedule(
      id: 0,
      title: 'Lunchtime Suggestion',
      body: "Got lunch plans? Tap to see what's nearby.",
      scheduledDate: tzDateTime,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  /// Cancel all scheduled notifications.
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Check whether a notification tap launched the app (cold-start).
  /// Returns any payload to deep-link.
  static Future<String?> getLaunchPayload() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      return details.notificationResponse?.payload;
    }
    return null;
  }
}
