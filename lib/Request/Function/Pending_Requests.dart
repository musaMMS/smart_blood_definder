import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
class FriendRequestsScreen extends StatelessWidget {
  const FriendRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text('Friend Requests')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('friend_requests')
            .where('receiverId', isEqualTo: currentUser!.uid)
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final requests = snapshot.data!.docs;
          if (requests.isEmpty) {
            return Center(child: Text('No Friend Requests'));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final senderId = request['senderId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(senderId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) return ListTile(title: Text('Loading...'));

                  final senderName = userSnapshot.data!['name'];

                  return ListTile(
                    title: Text('$senderName sent you a friend request'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () => _handleFriendRequest(request.id, senderId, true),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () => _handleFriendRequest(request.id, senderId, false),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handleFriendRequest(String requestId, String senderId, bool isAccepted) async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final requestRef = FirebaseFirestore.instance.collection('friend_requests').doc(requestId);

    if (isAccepted) {
      // Update friend lists
      await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
        'friends': FieldValue.arrayUnion([senderId])
      });
      await FirebaseFirestore.instance.collection('users').doc(senderId).update({
        'friends': FieldValue.arrayUnion([currentUser.uid])
      });
    }

    // Update request status
    await requestRef.update({'status': isAccepted ? 'accepted' : 'rejected'});
  }
}
