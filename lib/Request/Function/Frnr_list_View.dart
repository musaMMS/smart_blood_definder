import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_blood_definder/Request/Chat_Screen.dart';
class FriendListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text('Friends')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final friends = List<String>.from(snapshot.data!['friends'] ?? []);
          if (friends.isEmpty) return Center(child: Text('No Friends Yet'));

          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friendId = friends[index];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(friendId).get(),
                builder: (context, friendSnapshot) {
                  if (!friendSnapshot.hasData) return ListTile(title: Text('Loading...'));

                  final friendName = friendSnapshot.data!['name'];

                  return ListTile(
                    title: Text(friendName),
                    trailing: IconButton(
                      icon: Icon(Icons.chat),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(friendId: friendId, friendName: friendName, currentUserPhone: null, friendPhone: null,),
                        ),
                      ),
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
}
