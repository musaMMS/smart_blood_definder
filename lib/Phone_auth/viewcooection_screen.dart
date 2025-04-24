import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewConnectionsScreen extends StatefulWidget {
  const ViewConnectionsScreen({super.key});

  @override
  State<ViewConnectionsScreen> createState() => _ViewConnectionsScreenState();
}

class _ViewConnectionsScreenState extends State<ViewConnectionsScreen> {
  String? currentUserPhone;

  @override
  void initState() {
    super.initState();
    loadUserPhone();
  }

  Future<void> loadUserPhone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserPhone = prefs.getString('userPhone');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserPhone == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incoming Connect Requests'),
        backgroundColor: Colors.redAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('connections')
            .where('receiverPhone', isEqualTo: currentUserPhone)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("📭 No connection requests yet."),
            );
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var request = requests[index].data() as Map<String, dynamic>;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.redAccent),
                  title: Text("${request['senderName'] ?? 'Unknown'}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("📞 ${request['senderPhone']}"),
                      Text("🩸 Blood Group: ${request['senderBloodGroup']}"),
                      Text("⏱️ Requested: ${_formatTimestamp(request['timestamp'])}"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "Just now";
    DateTime dt = timestamp.toDate();
    return "${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute}";
  }
}
