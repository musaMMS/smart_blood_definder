import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

Future<void> sendFriendRequest(String receiverId) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return;

  await FirebaseFirestore.instance.collection('friend_requests').add({
    'senderId': currentUser.uid,
    'receiverId': receiverId,
    'status': 'pending',
    'timestamp': DateTime.now(),
  });

  // Notification Logic (আগের মতো)
}
