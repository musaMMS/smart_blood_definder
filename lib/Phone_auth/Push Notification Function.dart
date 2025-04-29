import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> sendPushNotification({
  required String token,
  required String title,
  required String body,
}) async {
  try {
    await FirebaseFirestore.instance.collection('notifications').add({
      'token': token,
      'title': title,
      'body': body,
      'timestamp': Timestamp.now(),
    });

    // তোমার Node.js server বা Firebase Functions ব্যবহার করে FCM পাঠাতে হবে
    // এখানে শুধু ফায়ারস্টোর এ রাখা হচ্ছে। Notification সিস্টেম live করতে হলে
    // ক্লাউড ফাংশন লাগবে।

  } catch (e) {
    debugPrint('❌ Error sending FCM: $e');
  }
}
