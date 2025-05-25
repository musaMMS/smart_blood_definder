// import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
// import 'package:http/http.dart' as http;
// import '../Phone_auth/Notification_Ui.dart';
// import '../donation/AddDonation_Screen.dart';
// import '../donation/Donar_history_view.dart';
// import 'ViewRequestScreen.dart';
//
// class BloodFinderScreen extends StatefulWidget {
//   const BloodFinderScreen({super.key});
//
//   @override
//   _BloodFinderScreenState createState() => _BloodFinderScreenState();
// }
//
// class _BloodFinderScreenState extends State<BloodFinderScreen> {
//   final TextEditingController cityController = TextEditingController();
//   String? selectedBloodGroup;
//   List<Map<String, dynamic>> searchResults = [];
//   bool isLoading = false;
//   String? userName;
//   int notificationCount = 0;
//
//   final List<String> bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
//
//   final String restApiKey = 'os_v2_app_e7w2a6zqhjdgxnlhosnle6jwa6lmn6s4nvuujo4w5hlzkf5e2os5powbn5tcohpbik3zu35hd5m55exfcgajybtyodefd25vnzyvlti'; // Replace this
//
//   @override
//   void initState() {
//     super.initState();
//     fetchUserNameFromPrefs();
//     loadNotificationCount();
//     setupOneSignalListeners();
//     getOneSignalToken();
//   }
//
//   Future<void> fetchUserNameFromPrefs() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       userName = prefs.getString('userName');
//     });
//   }
//
//   void loadNotificationCount() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       notificationCount = prefs.getInt('notifCount') ?? 0;
//     });
//   }
//
//   void setupOneSignalListeners() {
//     OneSignal.Notifications.addForegroundWillDisplayListener((event) async {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       int count = prefs.getInt('notifCount') ?? 0;
//       count++;
//       await prefs.setInt('notifCount', count);
//       setState(() {
//         notificationCount = count;
//       });
//     });
//
//     OneSignal.Notifications.addClickListener((event) async {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setInt('notifCount', 0);
//       setState(() {
//         notificationCount = 0;
//         isLoading = true;
//       });
//
//       await Future.delayed(const Duration(seconds: 2));
//       setState(() {
//         isLoading = false;
//       });
//
//       Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationListScreen()));
//     });
//   }
//
//   void getOneSignalToken() async {
//     try {
//       final userId = OneSignal.User.pushSubscription.id;
//       if (userId != null) {
//         print('📲 OneSignal Device Token: $userId');
//       } else {
//         print('❌ Token পাওয়া যায়নি');
//       }
//     } catch (e) {
//       print('❌ Token সংগ্রহে সমস্যা: $e');
//     }
//   }
//
//   void searchUsers() async {
//     final city = cityController.text.trim();
//     final bloodGroup = selectedBloodGroup;
//
//     if (city.isEmpty || bloodGroup == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('❗ Please enter both city and blood group')),
//       );
//       return;
//     }
//
//     setState(() {
//       isLoading = true;
//       searchResults = [];
//     });
//
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .where('city', isEqualTo: city)
//           .where('bloodGroup', isEqualTo: bloodGroup)
//           .get();
//
//       final results = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
//       setState(() {
//         searchResults = results;
//       });
//
//       if (results.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('No donors found in "$city" with "$bloodGroup"')),
//         );
//       }
//     } catch (e) {
//       print('❌ Error searching users: $e');
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   void sendConnectionRequest(Map<String, dynamic> user) async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       final senderPhone = prefs.getString('userPhone');
//       final senderName = prefs.getString('userName');
//       final senderBloodGroup = prefs.getString('bloodGroup');
//
//       if (senderPhone == null || senderName == null || senderBloodGroup == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("❗ Sender info missing.")),
//         );
//         return;
//       }
//
//       await FirebaseFirestore.instance.collection('connections').add({
//         'senderName': senderName,
//         'senderPhone': senderPhone,
//         'senderBloodGroup': senderBloodGroup,
//         'receiverPhone': user['phone'],
//         'timestamp': Timestamp.now(),
//       });
//
//       String receiverOneSignalToken = user['onesignalToken'];
//
//       if (receiverOneSignalToken.isNotEmpty) {
//         await sendOneSignalNotification(receiverOneSignalToken, senderName!);
//       }
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('✅ Request sent successfully!')),
//       );
//     } catch (e) {
//       print('❌ Error sending request: $e');
//     }
//   }
//
//   Future<void> sendOneSignalNotification(String token, String senderName) async {
//     try {
//       final url = Uri.parse('https://onesignal.com/api/v1/notifications');
//
//       final body = jsonEncode({
//         "app_id": '27eda07b-303a-466b-b567-749ab2793607',
//         "include_player_ids": [token],
//         "headings": {"en": "Friend Request"},
//         "contents": {"en": "$senderName has sent you a friend request."},
//       });
//
//       final response = await http.post(
//         url,
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Basic $restApiKey",
//         },
//         body: body,
//       );
//
//       if (response.statusCode == 200) {
//         print("📨 Notification sent!");
//       } else {
//         print("❌ Notification failed: ${response.body}");
//       }
//     } catch (e) {
//       print('❌ Error sending OneSignal notification: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: Stack(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   if (userName != null)
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text('👋 Hello, $userName', style: const TextStyle(fontSize: 18)),
//                         Stack(
//                           children: [
//                             IconButton(
//                               icon: const Icon(Icons.notifications),
//                               onPressed: () {
//                                 setState(() => notificationCount = 0);
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(builder: (_) => const NotificationListScreen()),
//                                 );
//                               },
//                             ),
//                             if (notificationCount > 0)
//                               Positioned(
//                                 right: 8,
//                                 top: 8,
//                                 child: CircleAvatar(
//                                   radius: 8,
//                                   backgroundColor: Colors.red,
//                                   child: Text(
//                                     '$notificationCount',
//                                     style: const TextStyle(fontSize: 12, color: Colors.white),
//                                   ),
//                                 ),
//                               )
//                           ],
//                         )
//                       ],
//                     ),
//                   TextField(
//                     controller: cityController,
//                     decoration: const InputDecoration(labelText: 'Enter City'),
//                   ),
//                   DropdownButtonFormField<String>(
//                     value: selectedBloodGroup,
//                     decoration: const InputDecoration(labelText: 'Blood Group'),
//                     items: bloodGroups.map((bg) => DropdownMenuItem(value: bg, child: Text(bg))).toList(),
//                     onChanged: (val) => setState(() => selectedBloodGroup = val),
//                   ),
//                   ElevatedButton(
//                     onPressed: searchUsers,
//                     child: const Text('🔍 Search'),
//                   ),
//                   Expanded(
//                     child: searchResults.isEmpty
//                         ? const Center(child: Text('No results'))
//                         : ListView.builder(
//                       itemCount: searchResults.length,
//                       itemBuilder: (ctx, i) {
//                         final user = searchResults[i];
//                         return Card(
//                           child: ListTile(
//                             title: Text(user['name'] ?? 'No Name'),
//                             subtitle: Text('${user['city']} | ${user['bloodGroup']}'),
//                             trailing: IconButton(
//                               icon: const Icon(Icons.person_add),
//                               onPressed: () => sendConnectionRequest(user),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             if (isLoading)
//               Container(
//                 color: Colors.black38,
//                 child: const Center(
//                   child: CircularProgressIndicator(),
//                 ),
//               )
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BloodFinderScreen extends StatefulWidget {
  const BloodFinderScreen({super.key});

  @override
  _BloodFinderScreenState createState() => _BloodFinderScreenState();
}

class _BloodFinderScreenState extends State<BloodFinderScreen> {
  final TextEditingController cityController = TextEditingController();
  String? selectedBloodGroup;
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;
  String? userName;

  final List<String> bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'
  ];

  @override
  void initState() {
    super.initState();
    fetchUserNameFromPrefs();
  }

  Future<void> fetchUserNameFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName');
    });
  }

  void searchUsers() async {
    final city = cityController.text.trim();
    final bloodGroup = selectedBloodGroup;

    if (city.isEmpty || bloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❗ Please enter both city and blood group')),
      );
      return;
    }

    setState(() {
      isLoading = true;
      searchResults = [];
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('city', isEqualTo: city)
          .where('bloodGroup', isEqualTo: bloodGroup)
          .get();

      final results = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      setState(() {
        searchResults = results;
      });

      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No donors found in "$city" with "$bloodGroup"')),
        );
      }
    } catch (e) {
      print('❌ Error searching users: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void sendConnectionRequest(Map<String, dynamic> user) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final senderPhone = prefs.getString('userPhone');
      final senderName = prefs.getString('userName');
      final senderBloodGroup = prefs.getString('bloodGroup');

      if (senderPhone == null || senderName == null || senderBloodGroup == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❗ Sender info missing.")),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('connections').add({
        'senderName': senderName,
        'senderPhone': senderPhone,
        'senderBloodGroup': senderBloodGroup,
        'receiverPhone': user['phone'],
        'timestamp': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Request sent successfully!')),
      );
    } catch (e) {
      print('❌ Error sending request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Blood Finder'),
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (userName != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('👋 Hello, $userName',
                          style: const TextStyle(fontSize: 18)),
                    ),
                  TextField(
                    controller: cityController,
                    decoration: const InputDecoration(labelText: 'Enter City'),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedBloodGroup,
                    decoration: const InputDecoration(labelText: 'Blood Group'),
                    items: bloodGroups
                        .map((bg) =>
                        DropdownMenuItem(value: bg, child: Text(bg)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedBloodGroup = val),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: searchUsers,
                    child: const Text('🔍 Search'),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: searchResults.isEmpty
                        ? const Center(child: Text('No results'))
                        : ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (ctx, i) {
                        final user = searchResults[i];
                        return Card(
                          child: ListTile(
                            title: Text(user['name'] ?? 'No Name'),
                            subtitle: Text(
                                '${user['city']} | ${user['bloodGroup']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.person_add),
                              onPressed: () => sendConnectionRequest(user),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black38,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

