import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalNotifications {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  static final onClickNotification = BehaviorSubject<String>();
  static int _notificationIdCounter = 2;
  static final List<Map<String, dynamic>> _activeAlarms = [];

  static Future<void> _saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_alarms', jsonEncode(_activeAlarms));
    debugPrint('Alarms saved: $_activeAlarms');
  }

  static Future<void> _loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final alarmsJson = prefs.getString('active_alarms');
    if (alarmsJson != null) {
      _activeAlarms.clear();
      final List<dynamic> decoded = jsonDecode(alarmsJson);
      _activeAlarms.addAll(decoded.cast<Map<String, dynamic>>());
      debugPrint('Alarms loaded: $_activeAlarms');
    }
  }

  static Future<void> onNotificationTap(NotificationResponse response) async {
    final String? payload = response.payload;
    if (payload != null) {
      debugPrint('notification payload: $payload');
      onClickNotification.add(payload);
    }
  }

  static Future init() async {
    await _loadAlarms();
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings();
    final LinuxInitializationSettings initializationSettingsLinux =
    LinuxInitializationSettings(defaultActionName: 'Open notification');
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );

    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      debugPrint('Notification permission granted: $granted');
    }

    if (await Permission.scheduleExactAlarm.isDenied) {
      final status = await Permission.scheduleExactAlarm.request();
      debugPrint('Schedule exact alarm permission: $status');
      if (status.isDenied) {
        debugPrint('Prompting for exact alarm permission');
        try {
          final intent = AndroidIntent(
            action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
            flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
          );
          await intent.launch();
        } catch (e) {
          debugPrint('Error launching alarm settings: $e');
          await openAppSettings();
        }
      }
    }

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: onNotificationTap,
    );
    debugPrint('Notification plugin fully initialized');
  }

  static Future showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async
  {
    try {
      const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
        'channel_id_1',
        'Main Channel',
        channelDescription: 'Channel for simple notifications',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      );
      const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);
      await _flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
      debugPrint('Simple notification shown successfully');
    } catch (e) {
      debugPrint('Error showing simple notification: $e');
    }
  }





  static Future<int> showDailyNotificationAtTime({
    required String title,
    required String body,
    required String payload,
    required TimeOfDay time,
    required BuildContext context,
  }) async
  {
    try {
      debugPrint('Starting showDailyNotificationAtTime: title=$title, time=${time.hour}:${time.minute}');

      // Initialize timezone
      tz.initializeTimeZones();
      debugPrint('Timezone initialized: ${tz.local.name}');

      // Calculate schedule time
      final now = DateTime.now();
      var scheduleTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour-5,
        time.minute-30,
      );
      if (scheduleTime.isBefore(tz.TZDateTime.now(tz.local))) {
        scheduleTime = scheduleTime.add(const Duration(days: 1));
      }
      debugPrint('Scheduled time: ${scheduleTime.toString()} (ID: $_notificationIdCounter)');

      // Generate unique ID
      final notificationId = _notificationIdCounter++;
      debugPrint('Generated notification ID: $notificationId');

      // Initialize notification channel
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'channel_id_4',
            'Daily Alarm Channel',
            description: 'Channel for daily alarms at specific times',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
            showBadge: true,
          ),
        );
        debugPrint('Notification channel channel_id_4 created');
      }

      // Check permissions
      bool notificationsEnabled = true;
      if (androidPlugin != null) {
        notificationsEnabled = await androidPlugin.requestNotificationsPermission() ?? false;
        debugPrint('Notification permission status: $notificationsEnabled');
      }
      final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
      debugPrint('Exact alarm permission status: $exactAlarmStatus');

      // Prompt for permissions if denied
      if (!notificationsEnabled) {
        debugPrint('Notification permission denied, requesting...');
        notificationsEnabled = await androidPlugin?.requestNotificationsPermission() ?? false;
        if (!notificationsEnabled) {
          debugPrint('Notification permission still denied, cannot schedule');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enable notifications in settings')),
          );
          await openAppSettings();
          return -1;
        }
      }
      if (exactAlarmStatus.isDenied) {
        debugPrint('Exact alarm permission denied, requesting...');
        final status = await Permission.scheduleExactAlarm.request();
        debugPrint('Exact alarm permission after request: $status');
        if (status.isDenied) {
          debugPrint('Prompting user to enable exact alarms in settings');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enable exact alarms in settings')),
          );
          try {
            final intent = AndroidIntent(
              action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
              flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
            );
            await intent.launch();
          } catch (e) {
            debugPrint('Error launching alarm settings: $e');
            await openAppSettings();
          }
          return -1;
        }
      }

      // Define notification details
      const androidDetails = AndroidNotificationDetails(
        'channel_id_4',
        'Daily Alarm Channel',
        channelDescription: 'Channel for daily alarms at specific times',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        playSound: true,
        enableVibration: true,
        channelShowBadge: true,
      );
      const notificationDetails = NotificationDetails(android: androidDetails);
      debugPrint('Notification details configured');

      // Schedule notification
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        scheduleTime,
        notificationDetails,
        androidScheduleMode: exactAlarmStatus.isGranted
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint(
          'Daily notification $notificationId scheduled for ${scheduleTime.toString()} with ${exactAlarmStatus.isGranted ? 'EXACT' : 'INEXACT'} timing');

      // Persist alarm
      _activeAlarms.add({
        'id': notificationId,
        'title': title,
        'time': time.format(context),
      });
      await _saveAlarms();
      debugPrint('Alarm saved: $_activeAlarms');
      return notificationId;
    } catch (e) {
      debugPrint('Error scheduling daily notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to schedule notification: $e')),
      );
      return -1;
    }
  }
  // static Future<int> showDailyNotificationAtTime({
  //   required String title,
  //   required String body,
  //   required String payload,
  //   required TimeOfDay time,
  //   required BuildContext context,
  // }) async
  // {
  //   try {
  //     debugPrint('Starting showDailyNotificationAtTime: title=$title, time=${time.hour}:${time.minute}');
  //
  //     // Initialize timezone
  //     tz.initializeTimeZones();
  //     // Explicitly set the timezone to IST (or dynamically get the device's timezone)
  //     final String deviceTimeZone = await FlutterNativeTimezone.getLocalTimezone();
  //     final tz.Location location = tz.getLocation(deviceTimeZone);
  //     tz.setLocalLocation(location);
  //     debugPrint('Timezone set to: ${tz.local.name}');
  //
  //     // Calculate schedule time
  //     final now = DateTime.now();
  //     var scheduleTime = tz.TZDateTime(
  //       tz.local,
  //       now.year,
  //       now.month,
  //       now.day,
  //       time.hour,
  //       time.minute,
  //     );
  //     if (scheduleTime.isBefore(tz.TZDateTime.now(tz.local))) {
  //       scheduleTime = scheduleTime.add(const Duration(days: 1));
  //     }
  //     debugPrint('Scheduled time: ${scheduleTime.toString()} (ID: $_notificationIdCounter)');
  //
  //     // Generate unique ID
  //     final notificationId = _notificationIdCounter++;
  //     debugPrint('Generated notification ID: $notificationId');
  //
  //     // Initialize notification channel
  //     final androidPlugin = _flutterLocalNotificationsPlugin
  //         .resolvePlatformSpecificImplementation<
  //         AndroidFlutterLocalNotificationsPlugin>();
  //     if (androidPlugin != null) {
  //       await androidPlugin.createNotificationChannel(
  //         const AndroidNotificationChannel(
  //           'channel_id_4',
  //           'Daily Alarm Channel',
  //           description: 'Channel for daily alarms at specific times',
  //           importance: Importance.max,
  //           playSound: true,
  //           enableVibration: true,
  //           showBadge: true,
  //         ),
  //       );
  //       debugPrint('Notification channel channel_id_4 created');
  //     }
  //
  //     // Check permissions
  //     bool notificationsEnabled = true;
  //     if (androidPlugin != null) {
  //       notificationsEnabled = await androidPlugin.requestNotificationsPermission() ?? false;
  //       debugPrint('Notification permission status: $notificationsEnabled');
  //     }
  //     final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
  //     debugPrint('Exact alarm permission status: $exactAlarmStatus');
  //
  //     // Prompt for permissions if denied
  //     if (!notificationsEnabled) {
  //       debugPrint('Notification permission denied, requesting...');
  //       notificationsEnabled = await androidPlugin?.requestNotificationsPermission() ?? false;
  //       if (!notificationsEnabled) {
  //         debugPrint('Notification permission still denied, cannot schedule');
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Please enable notifications in settings')),
  //         );
  //         await openAppSettings();
  //         return -1;
  //       }
  //     }
  //     if (exactAlarmStatus.isDenied) {
  //       debugPrint('Exact alarm permission denied, requesting...');
  //       final status = await Permission.scheduleExactAlarm.request();
  //       debugPrint('Exact alarm permission after request: $status');
  //       if (status.isDenied) {
  //         debugPrint('Prompting user to enable exact alarms in settings');
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Please enable exact alarms in settings')),
  //         );
  //         try {
  //           final intent = AndroidIntent(
  //             action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
  //             flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
  //           );
  //           await intent.launch();
  //         } catch (e) {
  //           debugPrint('Error launching alarm settings: $e');
  //           await openAppSettings();
  //         }
  //         return -1;
  //       }
  //     }
  //
  //     // Define notification details
  //     const androidDetails = AndroidNotificationDetails(
  //       'channel_id_4',
  //       'Daily Alarm Channel',
  //       channelDescription: 'Channel for daily alarms at specific times',
  //       importance: Importance.max,
  //       priority: Priority.high,
  //       ticker: 'ticker',
  //       playSound: true,
  //       enableVibration: true,
  //       channelShowBadge: true,
  //     );
  //     const notificationDetails = NotificationDetails(android: androidDetails);
  //     debugPrint('Notification details configured');
  //
  //     // Schedule notification
  //     await _flutterLocalNotificationsPlugin.zonedSchedule(
  //       notificationId,
  //       title,
  //       body,
  //       scheduleTime,
  //       notificationDetails,
  //       androidScheduleMode: exactAlarmStatus.isGranted
  //           ? AndroidScheduleMode.exactAllowWhileIdle
  //           : AndroidScheduleMode.inexactAllowWhileIdle,
  //       payload: payload,
  //       matchDateTimeComponents: DateTimeComponents.time,
  //     );
  //     debugPrint(
  //         'Daily notification $notificationId scheduled for ${scheduleTime.toString()} with ${exactAlarmStatus.isGranted ? 'EXACT' : 'INEXACT'} timing');
  //
  //     // Persist alarm
  //     _activeAlarms.add({
  //       'id': notificationId,
  //       'title': title,
  //       'time': time.format(context),
  //     });
  //     await _saveAlarms();
  //     debugPrint('Alarm saved: $_activeAlarms');
  //     return notificationId;
  //   } catch (e) {
  //     debugPrint('Error scheduling daily notification: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to schedule notification: $e')),
  //     );
  //     return -1;
  //   }
  // }



  static List<Map<String, dynamic>> getActiveAlarms() => _activeAlarms;

  static Future cancel(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
      _activeAlarms.removeWhere((alarm) => alarm['id'] == id);
      await _saveAlarms();
      debugPrint('Notification $id cancelled');
    } catch (e) {
      debugPrint('Error cancelling notification: $e');
    }
  }

  static Future cancelAll() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      _activeAlarms.clear();
      await _saveAlarms();
      debugPrint('All notifications cancelled');
    } catch (e) {
      debugPrint('Error cancelling all notifications: $e');
    }
  }
}