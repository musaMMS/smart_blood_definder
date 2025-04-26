import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Phone_auth/Notification Controller.dart';
import 'package:intl/intl.dart';

class NotificationListScreen extends StatelessWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Back to Home screen (or previous screen)
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: notificationProvider.notifications.length,
        itemBuilder: (context, index) {
          final notification = notificationProvider.notifications[index];
          return ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(notification.title),
            subtitle: Text(notification.body),
            trailing: Text(
              DateFormat('hh:mm a').format(notification.time),
              style: const TextStyle(fontSize: 12),
            ),
          );
        },
      ),
    );
  }
}
