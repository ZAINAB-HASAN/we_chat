import 'dart:convert';

import 'package:http/http.dart' as http;

/// Base URL of your notification server (no trailing slash).
/// - Android emulator: http://10.0.2.2:3000
/// - iOS simulator / local: http://127.0.0.1:3000
/// - Production: https://your-app.onrender.com (or your deployed URL)
const String kNotificationServerBaseUrl = 'http://10.0.2.2:3000';
//const String kNotificationServerBaseUrl = 'http://192.168.1.5:3000';
/// Calls the notification server to send FCM to the receiver.
/// Does not throw; failures are logged only so chat still works without Blaze.
Future<void> sendChatNotification({
  required String receiverId,
  required String senderId,
  required String senderEmail,
  required String message,
}) async {
  final uri = Uri.parse('$kNotificationServerBaseUrl/send-notification');
  try {
    final res = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'receiverId': receiverId,
            'senderId': senderId,
            'senderEmail': senderEmail,
            'message': message,
          }),
        )
        .timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      print('Notification API error: ${res.statusCode} ${res.body}');
    }
  } catch (e) {
    print('Notification API request failed: $e');
  }
}
