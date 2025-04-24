import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class NotificationController with ChangeNotifier {
  int _unreadCount = 0;

  int get unreadCount => _unreadCount;

  NotificationController() {
    // ফোরগ্রাউন্ডে নোটিফিকেশন আসলে
    OneSignal.shared.setNotificationWillShowInForegroundHandler((event) {
      _unreadCount++;
      notifyListeners();

      // Notif টা দেখাও
      event.complete(event.notification);
    });

    // যখন ইউজার নোটিফিকেশন ওপেন করে
    OneSignal.shared.setNotificationOpenedHandler((openedResult) {
      _unreadCount = 0;
      notifyListeners();
    });
  }

  void clearCount() {
    _unreadCount = 0;
    notifyListeners();
  }
}
