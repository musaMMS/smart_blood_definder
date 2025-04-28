import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_blood_definder/Request/Chat_Screen.dart';
import 'package:http/http.dart';
class FriendsListScreen extends StatelessWidget {
  const FriendsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text('Friends')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('friends')
            .where('user1', isEqualTo: currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var friends = snapshot.data!.docs;
          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              var friendId = friends[index]['user2'];
              return ListTile(
                title: Text('Friend: $friendId'),
                trailing: IconButton(
                  icon: Icon(Icons.chat),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatScreen(friendId: friendId, friendName: null, currentUserPhone: null, friendPhone: null,)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
