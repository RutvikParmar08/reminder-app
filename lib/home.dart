import 'package:flutter/material.dart';
import 'package:reminderapp/LocalNotifications.dart';
import 'package:reminderapp/another_page.dart';
import 'package:permission_handler/permission_handler.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  void initState() {
    super.initState();
    listenToNotifications();
  }

  void listenToNotifications() {
    debugPrint("Listening to notifications");
    LocalNotifications.onClickNotification.stream.listen((payload) {
      debugPrint("Notification clicked with payload: $payload");
      Navigator.of(context).pushNamed('/another', arguments: payload);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flutter Local Notifications")),
      body: Container(
        height: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  LocalNotifications.showSimpleNotification(
                    title: "Simple Notification",
                    body: "This is a simple notification",
                    payload: "simple_data",
                  );
                },
                label: const Text("Simple Notification"),
              ),


              ElevatedButton.icon(
                icon: const Icon(Icons.access_time),
                onPressed: () {
                  Navigator.of(context).pushNamed('/set_timer');
                },
                label: const Text("Set Daily Alarm"),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.list),
                onPressed: () {
                  Navigator.of(context).pushNamed('/active_alarms');
                },
                label: const Text("View Active Alarms"),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.delete_forever_outlined),
                onPressed: () {
                  LocalNotifications.cancelAll();
                },
                label: const Text("Cancel All Notifications"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}