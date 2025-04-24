import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DonorHistoryScreen extends StatelessWidget {
  final String donorId; // Pass donor's ID

  const DonorHistoryScreen({super.key, required this.donorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Donation History')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('donations')
            .where('donorId', isEqualTo: donorId)
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final donations = snapshot.data!.docs;

          if (donations.isEmpty) {
            return Center(child: Text("No donation history found."));
          }

          return ListView.builder(
            itemCount: donations.length,
            itemBuilder: (context, index) {
              final data = donations[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(Icons.local_hospital, color: Colors.red),
                  title: Text("To: ${data['receiverName']}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Hospital: ${data['hospital']}"),
                      Text("City: ${data['city']}"),
                      Text("Date: ${DateFormat.yMMMd().format(data['date'].toDate())}"),
                    ],
                  ),
                  trailing: Icon(Icons.check_circle, color: Colors.green),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
