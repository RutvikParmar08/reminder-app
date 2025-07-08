import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:reminderapp/ActiveAlarmsPage.dart';
import 'package:reminderapp/AlarmPage.dart';
import 'package:reminderapp/LocalNotifications.dart';
import 'package:reminderapp/SetTimerPage.dart';
import 'package:reminderapp/another_page.dart';
import 'package:reminderapp/home.dart';

final navigatorKey = GlobalKey<NavigatorState>();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotifications.init();

  // Handle notifications when app is launched from a terminated state
  final initialNotification =
  await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (initialNotification?.didNotificationLaunchApp == true) {
    final payload = initialNotification?.notificationResponse?.payload;
    if (payload != null) {
      // Delay to ensure navigator is ready
      Future.delayed(const Duration(seconds: 1), () {
        navigatorKey.currentState?.pushNamed(
          '/',
          arguments: payload,
        );
      });
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Homepage(),
        '/another': (context) => const AnotherPage(),
        '/set_timer': (context) => const SetTimerPage(),
        '/active_alarms': (context) => const AlarmPage(), // Add new route
      },
    );
  }
}