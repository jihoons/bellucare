import 'dart:io';

import 'package:bellucare/api/user_api.dart';
import 'package:bellucare/firebase_options.dart';
import 'package:bellucare/model/user.dart';
import 'package:bellucare/router.dart';
import 'package:bellucare/service/device_info_service.dart';
import 'package:bellucare/service/notification_service.dart';
import 'package:bellucare/service/permission_service.dart';
import 'package:bellucare/service/storage_service.dart';
import 'package:bellucare/style/colors.dart';
import 'package:bellucare/utils/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFirebase();
  await initCurrentState();
  var userInfo = await getUserInfo();

  var router = createRouter(userInfo == null);
  runApp(MyApp(router));
}

Future<User?> getUserInfo() async {
  String token = await StorageService().getData(StorageService.userTokenKey);
  if (token.isEmpty) {
    return null;
  }
  return await UserApi().fetchUserByToken(token);
}

Future<void> initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  var token = await FirebaseMessaging.instance.getToken();
  debug("====> $token");
  NotificationService.instance.init();
}

Future<void> initCurrentState() async {
  await PermissionService.instance.checkPermission();
  if (await DeviceInfoService.instance.canUseHealth()) {
    if (await PermissionService.instance.requestActivity()) {
    }
  }
  if (!(await Permission.notification.isGranted)) {
    await FirebaseMessaging.instance.requestPermission(
      badge: true,
      alert: true,
      sound: true,
    );
  }

  if (Platform.isAndroid && !(await Permission.phone.isGranted)) {
    await Permission.phone.request();
  }
}

class MyApp extends StatelessWidget {
  const MyApp(this.router, {super.key});
  final GoRouter router;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
        child: MaterialApp.router(
          title: "벨유케어",
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('en', ''), // English, no country code
            Locale('ko', ''), // Korean, no country code
          ],
          theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
              appBarTheme: const AppBarTheme(
                  backgroundColor: mainBackgroundColor,
                  surfaceTintColor: mainBackgroundColor,
                  foregroundColor: mainBackgroundColor,
                  iconTheme: IconThemeData(
                      color: Colors.white
                  )
              ),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: mainBackgroundColor,
              ),
              scaffoldBackgroundColor: mainBackgroundColor,
              useMaterial3: true),
          routerConfig: router,
        )
    );
  }
}

