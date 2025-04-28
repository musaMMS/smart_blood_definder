// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
//
// class ChatScreen extends StatefulWidget {
//   final String currentUserPhone;
//   final String friendPhone;
//   final String friendName;
//   final String friendId;
//
//   const ChatScreen({
//     Key? key,
//     required this.currentUserPhone,
//     required this.friendPhone,
//     required this.friendName,
//     required this.friendId,
//   }) : super(key: key);
//
//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final ImagePicker _picker = ImagePicker();
//
//   String? friendPlayerId;
//
//   @override
//   void initState() {
//     super.initState();
//     getFriendPlayerId();
//   }
//
//   // Fetch the player ID of the friend
//   Future<void> getFriendPlayerId() async {
//     final doc = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(widget.friendPhone)
//         .get();
//     if (doc.exists) {
//       friendPlayerId = doc['playerId']; // Assuming playerId is saved in Firestore
//     }
//   }
//
//   // Generate chatId by combining currentUserPhone and friendPhone
//   String get chatId {
//     List<String> ids = [widget.currentUserPhone, widget.friendPhone];
//     ids.sort();
//     return ids.join('_');
//   }
//
//   // Function to send a notification
//   Future<void> sendNotification(String title, String body) async {
//     if (friendPlayerId == null) return;
//
//     try {
//       // Create the notification content
//       var notification = OSNotification(
//         playerIds: [friendPlayerId!], // Target playerId(s)
//         heading: title,               // Notification title
//         content: body,                // Notification body
//         additionalData: {"additionalData": "value"}, // Optional additional data
//       );
//
//       // Send the notification using the OneSignal shared instance
//         OneSignal.shared.postNotification(notification);
//     } catch (e) {
//       print("Error sending notification: $e");
//     }
//   }
//
//   // Function to send a message, either text or image
//   Future<void> sendMessage({String? text, String? imageUrl}) async {
//     if ((text == null || text.isEmpty) && (imageUrl == null)) return;
//
//     await FirebaseFirestore.instance
//         .collection('messages')
//         .doc(chatId)
//         .collection('chats')
//         .add({
//       'sender': widget.currentUserPhone,
//       'receiver': widget.friendPhone,
//       'text': text ?? '',
//       'imageUrl': imageUrl ?? '',
//       'timestamp': FieldValue.serverTimestamp(),
//       'isSeen': false,
//     });
//
//     _messageController.clear();
//
//     // Send Push Notification
//     if (text != null && text.isNotEmpty) {
//       await sendNotification('New Message from ${widget.currentUserPhone}', text);
//     } else if (imageUrl != null) {
//       await sendNotification('New Image from ${widget.currentUserPhone}', 'Sent a photo 📷');
//     }
//   }
//
//   // Function to pick an image from the gallery
//   Future<void> pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       final file = File(pickedFile.path);
//       final fileName = DateTime.now().millisecondsSinceEpoch.toString();
//       final ref = FirebaseStorage.instance.ref().child('chat_images/$fileName');
//
//       await ref.putFile(file);
//       final imageUrl = await ref.getDownloadURL();
//
//       sendMessage(imageUrl: imageUrl);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.friendName),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('messages')
//                   .doc(chatId)
//                   .collection('chats')
//                   .orderBy('timestamp', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
//
//                 final messages = snapshot.data!.docs;
//
//                 return ListView.builder(
//                   reverse: true,
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final message = messages[index];
//                     final isMe = message['sender'] == widget.currentUserPhone;
//
//                     return Align(
//                       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//                       child: Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: isMe ? Colors.blue[100] : Colors.grey[300],
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: message['imageUrl'] != ''
//                             ? Image.network(
//                           message['imageUrl'],
//                           width: 200,
//                           height: 200,
//                           fit: BoxFit.cover,
//                         )
//                             : Text(
//                           message['text'],
//                           style: const TextStyle(fontSize: 16),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           const Divider(height: 1),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8),
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.image),
//                   onPressed: pickImage,
//                 ),
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: const InputDecoration(
//                       hintText: 'Type your message...',
//                       border: InputBorder.none,
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: () => sendMessage(text: _messageController.text),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
