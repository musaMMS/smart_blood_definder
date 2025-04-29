import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Phone_auth/pushnoiticifacionOnSignal.dart';
import 'Push Notification Function.dart';

class SendConnectRequestScreen extends StatefulWidget {
  const SendConnectRequestScreen({super.key});

  @override
  State<SendConnectRequestScreen> createState() => _SendConnectRequestScreenState();
}

class _SendConnectRequestScreenState extends State<SendConnectRequestScreen> {
  String? currentUserPhone;
  String? currentUserName;
  String? currentUserBloodGroup;
  String searchBloodGroup = "";

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserPhone = prefs.getString('userPhone');
      currentUserName = prefs.getString('userName');
      currentUserBloodGroup = prefs.getString('userBloodGroup');
    });
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

                final users = snapshot.data!.docs
                    .where((doc) => doc['phone'] != currentUserPhone)
                    .toList();

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
                              // ✅ Firestore এ Connection Save করো
                              await FirebaseFirestore.instance.collection('connections').add({
                                'senderName': currentUserName,
                                'senderPhone': currentUserPhone,
                                'senderBloodGroup': currentUserBloodGroup,
                                'receiverPhone': user['phone'],
                                'receiverName': user['name'],
                                'receiverBloodGroup': user['bloodGroup'],
                                'timestamp': FieldValue.serverTimestamp(),
                              });

                              // ✅ OneSignal Notification পাঠাও (যদি receiver-এর OneSignal ID থাকে)
                              if (user['oneSignalUserId'] != null) {
                                await sendPushNotificationWithOneSignal(
                                  userId: user['oneSignalUserId'],
                                  title: "New Connection Request",
                                  message: "$currentUserName wants to connect with you!",
                                );
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("✅ Request sent!")),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("❌ Failed to send request.")),
                              );
                              print("❌ Error: $e");
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
