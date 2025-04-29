import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> sendPushNotificationWithOneSignal({
  required String userId, // OneSignal Player ID
  required String title,
  required String message,
}) async {
  const String oneSignalAppId = 'YOUR_ONESIGNAL_APP_ID'; // 🔁 Replace this
  const String restApiKey = 'YOUR_ONESIGNAL_REST_API_KEY'; // 🔁 Replace this

  final url = Uri.parse('https://onesignal.com/api/v1/notifications');

  final headers = {
    'Content-Type': 'application/json; charset=utf-8',
    'Authorization': 'Basic $restApiKey',
  };

  final body = jsonEncode({
    'app_id': oneSignalAppId,
    'include_player_ids': [userId],
    'headings': {'en': title},
    'contents': {'en': message},
  });

  try {
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      print('✅ Notification sent successfully.');
    } else {
      print('❌ Failed to send notification: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print("❌ OneSignal notification error: $e");
  }
}
