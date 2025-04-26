import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class SendRequestScreen extends StatefulWidget {
  @override
  _SendRequestScreenState createState() => _SendRequestScreenState();
}

class _SendRequestScreenState extends State<SendRequestScreen> {
  List<Map<String, dynamic>> users = [
    {
      'name': 'Rahim',
      'phone': '017xxxxxxx',
      'bloodGroup': 'A+',
      'onesignalToken': 'receiver_player_id'
    },
    // Add more users here
  ];

  void sendConnectionRequest(Map<String, dynamic> user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? senderName = prefs.getString('userName');
    String? senderPhone = prefs.getString('userPhone');

    if (senderName == null || senderPhone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❗ Sender info missing.")),
      );
      return;
    }

    // Save to Firestore
    await FirebaseFirestore.instance.collection('connections').add({
      'senderName': senderName,
      'senderPhone': senderPhone,
      'receiverPhone': user['phone'],
      'timestamp': Timestamp.now(),
    });

    String receiverToken = user['onesignalToken'];

    if (receiverToken.isNotEmpty) {
      await sendOneSignalNotification(receiverToken, senderName);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Request sent successfully!')),
    );
  }

  Future<void> sendOneSignalNotification(String receiverPlayerId, String senderName) async {
    const String oneSignalAppId = 'YOUR_ONESIGNAL_APP_ID';
    const String restApiKey = 'YOUR_ONESIGNAL_REST_API_KEY';

    var url = Uri.parse('https://onesignal.com/api/v1/notifications');

    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Basic $restApiKey',
      },
      body: jsonEncode({
        'app_id': oneSignalAppId,
        'include_player_ids': [receiverPlayerId],
        'headings': {'en': 'New Friend Request'},
        'contents': {'en': '$senderName has sent you a friend request!'},
      }),
    );

    if (response.statusCode == 200) {
      print('✅ Notification sent successfully');
    } else {
      print('❌ Failed to send notification: ${response.statusCode}');
      print('❌ Response: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Friend Request'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(users[index]['name']),
            subtitle: Text('Blood Group: ${users[index]['bloodGroup']}'),
            trailing: IconButton(
              icon: Icon(Icons.send),
              onPressed: () => sendConnectionRequest(users[index]),
            ),
          );
        },
      ),
    );
  }
}
