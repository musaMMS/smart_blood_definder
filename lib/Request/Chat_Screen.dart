import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatelessWidget {
  final String friendId;
  ChatScreen({super.key, required this.friendId, required friendName, required currentUserPhone, required friendPhone});

  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text('Chat with $friendId')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('chats')
                  .doc(getChatId(currentUser!.uid, friendId))
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();

                var messages = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    return ListTile(title: Text(message['text']));
                  },
                );
              },
            ),
          ),
          TextField(
            controller: _messageController,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => sendMessage(friendId, _messageController.text),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String getChatId(String uid1, String uid2) => (uid1.compareTo(uid2) < 0) ? '$uid1\_$uid2' : '$uid2\_$uid1';

  Future<void> sendMessage(String friendId, String text) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.collection('chats')
        .doc(getChatId(currentUser!.uid, friendId))
        .collection('messages')
        .add({
      'text': text,
      'senderId': currentUser.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
