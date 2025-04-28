import 'package:flutter/material.dart';

class NotificationController with ChangeNotifier {
  final List<NotificationItem> _notifications = [];
  int _unreadCount = 0;

  List<NotificationItem> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  // ✅ Add Notification
  void addNotification(String title, String body, DateTime time) {
    _notifications.insert(
      0,
      NotificationItem(title: title, body: body, time: time),
    );
    _unreadCount++;
    notifyListeners();
  }

  // ✅ Clear Unread Count
  void clearCount() {
    _unreadCount = 0;
    notifyListeners();
  }
}

class NotificationItem {
  final String title;
  final String body;
  final DateTime time;

  NotificationItem({
    required this.title,
    required this.body,
    required this.time,
  });
}
