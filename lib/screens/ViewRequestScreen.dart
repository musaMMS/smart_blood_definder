// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class ViewRequestsScreen extends StatelessWidget {
//   const ViewRequestsScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("📢 Blood Requests")),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('requests')
//             .orderBy('timestamp', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) return Center(child: Text('Error loading requests'));
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//
//           final requests = snapshot.data!.docs;
//
//           if (requests.isEmpty) {
//             return Center(child: Text('No blood requests found.'));
//           }
//
//           return ListView.builder(
//             itemCount: requests.length,
//             itemBuilder: (context, index) {
//               final data = requests[index].data() as Map<String, dynamic>;
//               return Card(
//                 margin: EdgeInsets.all(8),
//                 child: ListTile(
//                   title: Text('${data['city']} | ${data['bloodGroup']}'),
//                   subtitle: Text(data['message'] ?? 'No message'),
//                   trailing: Text('📞 ${data['contact']}'),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewRequestsScreen extends StatelessWidget {
  const ViewRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Requests'),
        backgroundColor: Colors.redAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .orderBy('timestamp', descending: true)
            .snapshots(), // 🔁 Live data
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('📭 No blood requests found.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: const Icon(Icons.bloodtype, color: Colors.redAccent),
                  title: Text('🩸 ${data['bloodGroup']} needed in ${data['city']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📞 Contact: ${data['contact']}'),
                      const SizedBox(height: 4),
                      Text('📨 Message: ${data['message']}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.phone, color: Colors.green),
                    onPressed: () {
                      // optional: open dialer with contact number
                    },
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
