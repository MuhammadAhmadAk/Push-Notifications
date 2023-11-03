// ignore_for_file: avoid_print

import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  void initLocalNotifications(BuildContext context, RemoteMessage message) async {

  //initailize Android setting
    var androidintialization = const AndroidInitializationSettings('@mipmap/ic_launcher');
  //initailize Android setting
    var iosIntialization = const DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
      android: androidintialization,
      iOS: iosIntialization,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse: (payload) {},
    );
  }

  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((messege) {
      showNotifications(context,messege);
    });
  }

//Show Notification when App is Active
 Future<void> showNotifications(BuildContext context, RemoteMessage message) async {
    // Call the `initLocalNotifications` function with the context and message parameters
    initLocalNotifications(context, message);

    // Create an AndroidNotificationChannel with a random ID and the channel name
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(10000).toString(),
        "channelName",
        importance: Importance.max
    );
  
    // Create AndroidNotificationDetails with settings for the Android notification
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: "This is channel Description",
            importance: Importance.max,
            priority: Priority.high,
            ticker: "Ticker"
        );
    
    // Create DarwinNotificationDetails for iOS notification settings
    DarwinNotificationDetails iosNotificationDetails = const DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true
        );

    // Create a NotificationDetails object that combines Android and iOS settings
    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, 
        iOS: iosNotificationDetails
    );
    
    // Delay the execution of the following code until the next event
    Future.delayed(Duration.zero, () async {
      // Use the flutterLocalNotificationsPlugin to show a notification
      await flutterLocalNotificationsPlugin.show(
          1,  // Notification ID
          message.notification!.title.toString(),  
          message.notification!.body.toString(),  
          notificationDetails  
      );
    });
}


  Future<void> requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        sound: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User granted permission");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("User granted provisonal permission");
    } else {
      print("User denied permission");
    }
  }

  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token!;
  }

  void isTokenRefresh() {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
    });
  }
}
