import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> sendFriendRequest(String receiverId) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return;

  // ✅ Step 1: Save Friend Request in Firestore
  await FirebaseFirestore.instance.collection('friend_requests').add({
    'senderId': currentUser.uid,
    'receiverId': receiverId,
    'status': 'pending',
    'timestamp': DateTime.now(),
  });

  // ✅ Step 2: Get receiver's OneSignal playerId
  DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(receiverId).get();
  String? receiverPlayerId = userDoc['onesignalToken'];

  if (receiverPlayerId != null) {
    // ✅ Step 3: Send notification through OneSignal
    var url = Uri.parse('https://onesignal.com/api/v1/notifications');
    await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Basic YOUR_ONESIGNAL_REST_API_KEY',
      },
      body: jsonEncode({
        'app_id': 'YOUR_ONESIGNAL_APP_ID',
        'include_player_ids': [receiverPlayerId],
        'headings': {'en': 'New Friend Request'},
        'contents': {'en': '${currentUser.displayName ?? 'Someone'} sent you a friend request!'},
      }),
    );
  }
}
