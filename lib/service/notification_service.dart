

import 'package:bellucare/firebase_options.dart';
import 'package:bellucare/service/call_service.dart';
import 'package:bellucare/utils/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debug("Handling a background message: ${message.messageId}");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // CallService.instance.call(message.data ?? {});
  NotificationService.instance.handleRemoteMessage(message);
}

class NotificationService {
  static final NotificationService _instance = NotificationService._privateConstructor();
  static NotificationService get instance => _instance;

  NotificationService._privateConstructor();

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
    }

    String type = "";
    if (message.data != null) {
      type = message.data["type"] as String? ?? "";
    }
    if (type == "call" && init == false) {
      CallService.instance.call(message.data ?? {});
    } else {
      // TODO 일반 DeepLink 처리
    }
  }
}