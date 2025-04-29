import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:http/http.dart' as http; // ✅ Missing import

class SendConnectRequestScreen extends StatefulWidget {
  const SendConnectRequestScreen({super.key});

  @override
  State<SendConnectRequestScreen> createState() => _SendConnectRequestScreenState();
}

class _SendConnectRequestScreenState extends State<SendConnectRequestScreen> {
  String? currentUserPhone;
  String? currentUserName;
  String? currentUserBloodGroup;
  String searchBloodGroup = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserPhone = prefs.getString('phone');
      currentUserName = prefs.getString('name');
      currentUserBloodGroup = prefs.getString('bloodGroup');
    });
  }

  Future<void> sendPushNotificationWithOneSignal({
    required String userId,
    required String title,
    required String message,
  }) async {
    const String oneSignalAppId = 'YOUR_ONESIGNAL_APP_ID'; // ✅ Replace with real App ID
    const String restApiKey = 'YOUR_REST_API_KEY'; // ✅ Replace with real REST API Key

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
      if (response.statusCode != 200) {
        print('❌ Failed to send notification: ${response.body}');
      } else {
        print('✅ Notification sent successfully');
      }
    } catch (e) {
      print("❌ OneSignal notification error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserPhone == null || currentUserName == null || currentUserBloodGroup == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    Query usersQuery = FirebaseFirestore.instance.collection('users');
    if (searchBloodGroup.isNotEmpty) {
      usersQuery = usersQuery.where('bloodGroup', isEqualTo: searchBloodGroup);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Send Connect Request"),
        backgroundColor: Colors.redAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                labelText: "Search by Blood Group (e.g. A+)",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchBloodGroup = value.trim().toUpperCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: usersQuery.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!.docs.where((doc) => doc['phone'] != currentUserPhone).toList();

                if (users.isEmpty) {
                  return const Center(child: Text("No matching users found."));
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index].data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.person, color: Colors.redAccent),
                        title: Text(user['name'] ?? 'Unknown'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("📞 ${user['phone']}"),
                            Text("🩸 Blood Group: ${user['bloodGroup']}"),
                            Text("🏙️ City: ${user['city'] ?? 'Unknown'}"),
                          ],
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          child: const Text("Connect"),
                          onPressed: () async {
                            try {
                              // ✅ 1. Save to Firestore
                              await FirebaseFirestore.instance.collection('connections').add({
                                'senderName': currentUserName,
                                'senderPhone': currentUserPhone,
                                'senderBloodGroup': currentUserBloodGroup,
                                'receiverPhone': user['phone'],
                                'receiverName': user['name'],
                                'receiverBloodGroup': user['bloodGroup'],
                                'timestamp': FieldValue.serverTimestamp(),
                              });

                              // ✅ 2. Send OneSignal Push Notification
                              if (user['onesignalId'] != null && user['onesignalId'].toString().isNotEmpty) {
                                await sendPushNotificationWithOneSignal(
                                  userId: user['onesignalId'],
                                  title: "New Connection Request",
                                  message: "$currentUserName wants to connect with you!",
                                );
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("✅ Request sent!")),
                              );
                            } catch (e) {
                              print("❌ Error: $e");
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("❌ Failed to send request.")),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

