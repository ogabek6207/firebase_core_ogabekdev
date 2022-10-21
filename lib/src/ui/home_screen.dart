import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../notification/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  void loadFCM() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print(token);

    String title = FirebaseMessaging.instance.app.name;

    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
          "high_importance_channel", "High Importance Notifications",
          importance: Importance.high);
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadFCM();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: FloatingActionButton(
          onPressed: () {
            notificationService.showNotificationDate(
              3,
              "title",
              "body",
              DateTime.now(),
            );
          },
        ),
      ),
    );
  }
}
