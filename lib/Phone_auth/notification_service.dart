import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static Future<void> initializeListeners(Function onNotificationTap, Function onNotificationUpdate) async {
    OneSignal.Notifications.addForegroundWillDisplayListener((event) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int count = prefs.getInt('notifCount') ?? 0;
      count++;
      await prefs.setInt('notifCount', count);
      onNotificationUpdate(count);
    });

    OneSignal.Notifications.addClickListener((event) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('notifCount', 0);
      onNotificationUpdate(0);
      onNotificationTap();
    });
  }

  static Future<void> getOneSignalToken() async {
    try {
      final userId = OneSignal.User.pushSubscription.id;
      if (userId != null) {
        debugPrint('📲 OneSignal Device Token: $userId');
      } else {
        debugPrint('❌ Token পাওয়া যায়নি');
      }
    } catch (e) {
      debugPrint('❌ Token সংগ্রহে সমস্যা: $e');
    }
  }

  static Future<int> getNotificationCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('notifCount') ?? 0;
  }
}
