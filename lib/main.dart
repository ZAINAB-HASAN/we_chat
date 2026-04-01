import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_chat/core/routes/app_routes.dart';
import 'package:we_chat/core/routes/routes_name.dart';

import 'data/services/notification_service.dart';

// global object for accessing device screen size

//late Size mq;

/// BACKGROUND HANDLER (Required)
/*@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Background message received");
  print("Title: ${message.notification?.title}");
  print("Body: ${message.notification?.body}");
}*/

Future<void> printFCMToken() async {
  String? token = await FirebaseMessaging.instance.getToken();

  print("FCM TOKEN: $token");

  // Listen for token refresh (important for production)
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    print("FCM TOKEN REFRESHED: $newToken");
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  /// REQUIRED
  FirebaseMessaging.onBackgroundMessage(
    NotificationService.firebaseMessagingBackgroundHandler,
  );

  await NotificationService.init();

  /// Print FCM Token
  await printFCMToken();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'We Chat',
      debugShowCheckedModeBanner: false,
      /*builder: (context, child) {
        mq = MediaQuery.of(context).size;
        return child!;
      },*/
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 1,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 20,
          ),
        ),
      ),
      initialRoute: RoutesName.splash,
      getPages: AppRoutes.appRoutes(),
    );
  }
}
