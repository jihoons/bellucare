import 'dart:io';

import 'package:bellucare/firebase_options.dart';
import 'package:bellucare/service/call_service.dart';
import 'package:bellucare/utils/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debug("Handling a background message: ${message.messageId}");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  NotificationService.instance.handleRemoteMessage(message);
}

class NotificationService {
  static final NotificationService _instance = NotificationService._privateConstructor();
  static NotificationService get instance => _instance;
  final _localNotification = FlutterLocalNotificationsPlugin();

  NotificationService._privateConstructor() {
    AndroidInitializationSettings android = const AndroidInitializationSettings("@mipmap/ic_launcher");
    DarwinInitializationSettings ios = const DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    InitializationSettings settings = InitializationSettings(android: android, iOS: ios);
    _localNotification.initialize(settings);
  }

  void init() {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
      // foreground
      debug("firebase onMessage");
      handleRemoteMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
      // background and alive
      debug("firebase onMessageOpenedApp");
      handleRemoteMessage(message);
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      debug("firebase getInitialMessage");
      handleRemoteMessage(message, init: true);
    });
  }

  Future<void> deleteNotification(String id) async {
    var notifications = await _localNotification.getActiveNotifications();
    debug("count ${notifications.length} id: $id");
    for (var notification in notifications) {
      debug("notification: ${notification.id} ${notification.body} ${notification.payload} ${notification.tag} ${notification.bigText}");
      if (Platform.isAndroid) {
        if (id == notification.tag) {
          debug("delete notification ${notification.id} ${notification.tag}");
          await _localNotification.cancel(notification.id!, tag: notification.tag);
        }
      }
    }
  }

  Future<void> handleRemoteMessage(RemoteMessage? message, {
    bool init = false
  }) async {
    if (message == null) {
      return;
    }
    if (message.notification != null) {
      debug("${message.notification!.title}");
      debug("${message.notification!.body}");
      debug("${message.data}");
      debug("${message.toMap()}");
    }

    String type = "";
    if (message.data != null) {
      type = message.data["type"] as String? ?? "";
    }

    if (type == "call") {
      if (init) {
        // TODO 일반 DeepLink 처리
        goToDeeplink(message.data ?? {});
      } else {
        CallService.instance.call(getMessageId(message), message.data ?? {});
      }
    } else {
      goToDeeplink(message.data ?? {});
    }
  }

  String getMessageId(RemoteMessage message) {
    debug("fcm message: ${message.toMap()}");
    if (Platform.isAndroid) {
      return message.notification?.android?.tag ?? "";
    } else {
      // TODO Check Android
      return "";
    }
  }

  void goToDeeplink(Map<String, dynamic> data) {

  }
}
