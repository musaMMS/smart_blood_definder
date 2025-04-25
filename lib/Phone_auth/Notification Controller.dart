import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class NotificationController with ChangeNotifier {
  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  NotificationController() {
    // 🔔 Foreground notification handler
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      _unreadCount++;
      notifyListeners();

      // ✅ New SDK no longer needs event.complete(...)
      // Notification auto-displayed
    });

    // 🔔 When user clicks notification
    OneSignal.Notifications.addClickListener((event) {
      _unreadCount = 0;
      notifyListeners();
    });
  }

  void clearCount() {
    _unreadCount = 0;
    notifyListeners();
  }
}

