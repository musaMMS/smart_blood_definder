// TODO Implement this library.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_blood_definder/Request/Chat_Screen.dart'; // নিচে এইটা বানিয়ে দিচ্ছি

class ViewConnectionsScreen extends StatelessWidget {
  final String currentUserPhone;

  const ViewConnectionsScreen({Key? key, required this.currentUserPhone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Connections'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('connections')
            .where('senderPhone', isEqualTo: currentUserPhone)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final connections = snapshot.data!.docs;

          if (connections.isEmpty) {
            return Center(child: Text('No connections yet.'));
          }

          return ListView.builder(
            itemCount: connections.length,
            itemBuilder: (context, index) {
              final connection = connections[index];
              final receiverName = connection['receiverName'];
              final receiverPhone = connection['receiverPhone'];

              return ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text(receiverName),
                subtitle: Text(receiverPhone),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          currentUserPhone: currentUserPhone,
                          friendPhone: receiverPhone,
                          friendName: receiverName, friendId: '',
                        ),
                      ),
                    );
                  },
                  child: Text('Message'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
