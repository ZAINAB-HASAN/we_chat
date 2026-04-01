import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../core/routes/routes_name.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static const String channelId = "chat_channel";
  static const String channelName = "Chat Notifications";

  /// When app is opened from terminated state by tapping a notification
  static Map<String, dynamic>? pendingNotificationData;

  /// 🔹 BACKGROUND HANDLER
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print("🔵 Background message: ${message.messageId}");
  }

  static Future<void> init() async {
    /// 🔹 Permission (Android 13+ important)
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    /// 🔹 Print Token (Debugging)
    final token = await _messaging.getToken();
    print("📲 FCM TOKEN in Notification service class => $token");

    /// Local notification init
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android);

    await _local.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        /// NAVIGATION FROM FOREGROUND TAP
        if (response.payload != null) {
          final data = Map<String, dynamic>.from(
            Uri.splitQueryString(response.payload!),
          );
          _handleNavigation(data);
        }
      },
    );

    /// CREATE CHANNEL (IMPORTANT)
    const androidChannel = AndroidNotificationChannel(
      channelId,
      channelName,
      importance: Importance.max,
    );

    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);

    /// 🔹 FOREGROUND MESSAGE
    FirebaseMessaging.onMessage.listen((message) {
      final data = message.data;
      final title =
          message.notification?.title ?? data['title'] ?? "New Message";

      final body =
          message.notification?.body ?? data['message'] ?? "";
      _local.show(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        payload: Uri(
          queryParameters: {
            "receiverId": data['receiverId']?.toString() ?? "",
            "receiverEmail": data['receiverEmail']?.toString() ?? "",
          },
        ).query,
      );
    });

    ///  🔹 BACKGROUND TAP (App already running in background)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNavigation(message.data);
    });

    ///  🔹 TERMINATED STATE TAP (App closed) – store for splash to handle after auth
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();

    if (initialMessage != null && initialMessage.data.isNotEmpty) {
      pendingNotificationData = Map<String, dynamic>.from(initialMessage.data);
    }
  }

  static void _handleNavigation(Map<String, dynamic> data) {
    print("NOTIFICATION DATA => $data");

    final receiverId = data["receiverId"]?.toString().trim();
    final receiverEmail = data["receiverEmail"]?.toString().trim() ?? "";

    if (receiverId == null || receiverId.isEmpty) {
      print("⚠ NOTIFICATION: missing receiverId, skipping navigation");
      return;
    }

    /// Delay until UI + GetX is ready
    Future.delayed(const Duration(milliseconds: 600), () {
      if (Get.key.currentState != null) {
        Get.toNamed(
          RoutesName.chatScreen,
          arguments: {
            "receiverId": receiverId,
            "receiverEmail": receiverEmail,
          },
        );
      } else {
        print("GETX NOT READY");
      }
    });
  }
}
