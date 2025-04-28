import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart';
class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text('Friend Requests')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('friend_requests')
            .where('receiverId', isEqualTo: currentUser?.uid)
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var requests = snapshot.data!.docs;
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var request = requests[index];
              return ListTile(
                title: Text('Friend Request from ${request['senderId']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check, color: Colors.green),
                      onPressed: () => acceptFriendRequest(request.id, request['senderId']),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () => rejectFriendRequest(request.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

Future<void> acceptFriendRequest(String requestId, String senderId) async {
  final currentUser = FirebaseAuth.instance.currentUser;

  // ✅ Update Request Status
  await FirebaseFirestore.instance.collection('friend_requests').doc(requestId).update({
    'status': 'accepted',
  });

  // ✅ Add to Friends Collection
  await FirebaseFirestore.instance.collection('friends').add({
    'user1': currentUser!.uid,
    'user2': senderId,
  });
}

Future<void> rejectFriendRequest(String requestId) async {
  await FirebaseFirestore.instance.collection('friend_requests').doc(requestId).update({
    'status': 'rejected',
  });
}
