import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:smart_blood_definder/Phone_auth/Notification_Ui.dart';
import '../Phone_auth/viewcooection_screen.dart';
import '../donation/AddDonation_Screen.dart';
import '../donation/Donar_history_view.dart';
import 'ViewRequestScreen.dart';
import 'package:provider/provider.dart';
import 'ViewConnectionsScreen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController cityController = TextEditingController();
  String? selectedBloodGroup;
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;
  String? userName;
  int notificationCount = 0;

  final List<String> bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  @override
  void initState() {
    super.initState();
    fetchUserNameFromPrefs();
    loadNotificationCount();
    setupOneSignalListeners();
    getOneSignalToken();
  }

// ✅ Fetch user name from SharedPreferences
  Future<void> fetchUserNameFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('userName');
    print('🟡 Fetched userName: $name');

    if (name != null) {
      setState(() {
        userName = name;
      });
    } else {
      print('🔴 userName not found in SharedPreferences');
    }
  }

// ✅ Load saved notification count from SharedPreferences
  void loadNotificationCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationCount = prefs.getInt('notifCount') ?? 0;
    });
  }

// ✅ OneSignal Listeners for notifications
  void setupOneSignalListeners() {
    // Increment & save notification count on foreground message
    OneSignal.Notifications.addForegroundWillDisplayListener((event) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int count = prefs.getInt('notifCount') ?? 0;
      count++;
      await prefs.setInt('notifCount', count);

      setState(() {
        notificationCount = count;
      });
    });

    // Reset count and navigate on notification click
    OneSignal.Notifications.addClickListener((event) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('notifCount', 0);

      setState(() {
        notificationCount = 0;
        isLoading = true; // Show the progress bar when notification clicked
      });

      // Simulate progress (you can replace this with actual task)
      await Future.delayed(Duration(seconds: 2)); // Wait for 2 seconds before transitioning

      setState(() {
        isLoading = false; // Hide the progress bar after the task is done
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NotificationListScreen()),
      );
    });
  }


  void getOneSignalToken() async {
    try {
      final userId = OneSignal.User.pushSubscription.id;
      if (userId != null) {
        print('📲 OneSignal Device Token: $userId');
      } else {
        print('❌ Token পাওয়া যায়নি');
      }
    } catch (e) {
      print('❌ Token সংগ্রহে সমস্যা: $e');
    }
  }

  void searchUsers() async {
    final String city = cityController.text.trim();
    final String? bloodGroup = selectedBloodGroup;

    if (city.isEmpty || bloodGroup == null || bloodGroup.isEmpty) {
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
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('city', isEqualTo: city)
          .where('bloodGroup', isEqualTo: bloodGroup)
          .get();

      final results = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      setState(() {
        searchResults = results;
      });

      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No donors found in "$city" with blood group "$bloodGroup"')),
        );
      }
    } catch (e) {
      debugPrint('❌ Error searching users: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error occurred. Please try again.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to send connection request and notification
  void sendConnectionRequest(Map<String, dynamic> user) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? senderPhone = prefs.getString('userPhone');
      String? senderName = prefs.getString('userName');
      String? senderBloodGroup = prefs.getString('bloodGroup');
      String? senderOneSignalToken = prefs.getString('onesignalToken'); // User's OneSignal Token

      if (senderPhone == null || senderName == null || senderBloodGroup == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❗ Sender info missing.")),
        );
        return;
      }

      // Send the request to Firestore
      await FirebaseFirestore.instance.collection('connections').add({
        'senderName': senderName,
        'senderPhone': senderPhone,
        'senderBloodGroup': senderBloodGroup,
        'receiverPhone': user['phone'],
        'timestamp': Timestamp.now(),
      });

      // Get the OneSignal Token for the receiver (assumed that this is stored in Firestore under receiver's document)
      String receiverOneSignalToken = user['onesignalToken']; // Assuming this is saved in Firestore under user data

      if (receiverOneSignalToken.isNotEmpty) {
        // Send Push Notification using OneSignal API
        await sendOneSignalNotification(receiverOneSignalToken, senderName);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Request sent successfully!')),
      );
    } catch (e) {
      debugPrint('❌ Error sending connection request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Failed to send request.')),
      );
    }
  }

// Function to send OneSignal Notification
// ----------------------
// Function to send notification
  Future<void> sendOneSignalNotification(String receiverToken, String senderName) async {
    try {
      const String oneSignalAppId = 'c10dd787-9845-4b2e-977d-6083ac2e7e14'; // তোমার App ID
      const String restApiKey = 'YOUR-ONESIGNAL-REST-API-KEY'; // OneSignal REST API KEY (IMPORTANT)

      var url = Uri.parse('https://onesignal.com/api/v1/notifications');

      var body = jsonEncode({
        "app_id": oneSignalAppId,
        "include_player_ids": [receiverToken],
        "headings": {"en": "Friend Request"},
        "contents": {"en": "$senderName has sent you a friend request."},
      });

      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Basic $restApiKey", // REST API Key দিয়ে Authorize করতে হবে
        },
        body: body,
      );

      if (response.statusCode == 200) {
        print('📲 Notification sent successfully!');
      } else {
        print('❌ Failed to send notification: ${response.body}');
      }
    } catch (e) {
      print('❌ Error sending notification: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (userName != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 250,
                        child: Card(
                          color: Colors.red[50],
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            leading: const Icon(Icons.person, color: Colors.redAccent),
                            title: Text('👋 Hello, $userName!',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            subtitle: const Text('Welcome to the app!',
                                style: TextStyle(fontSize: 14, color: Colors.grey)),
                          ),
                        ),
                      ),
                      Stack(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                notificationCount = 0;
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const NotificationListScreen()),
                              );
                            },
                            icon: const Icon(Icons.notifications_active_rounded),
                          ),
                          if (notificationCount > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: CircleAvatar(
                                radius: 8,
                                backgroundColor: Colors.red,
                                child: Text(
                                  '$notificationCount',
                                  style: const TextStyle(fontSize: 12, color: Colors.white),
                                ),
                              ),
                            )
                        ],
                      )
                    ],
                  ),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: 'Enter city'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedBloodGroup,
                  decoration: const InputDecoration(labelText: 'Select Blood Group'),
                  items: bloodGroups.map((String bg) {
                    return DropdownMenuItem(value: bg, child: Text(bg));
                  }).toList(),
                  onChanged: (String? newGroup) {
                    setState(() {
                      selectedBloodGroup = newGroup;
                    });
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: searchUsers,
                  icon: const Icon(Icons.search),
                  label: const Text('Search'),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: searchResults.isEmpty
                      ? const Center(child: Text('🔍 Search results will appear here.'))
                      : ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      var user = searchResults[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(user['name'] ?? 'No name'),
                          subtitle: Text(
                            '📍 ${user['city'] ?? ''} | 🩸 ${user['bloodGroup'] ?? ''}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.person_add),
                            onPressed: () {
                              sendConnectionRequest(user);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),



                //another
                Wrap(
                  alignment: WrapAlignment.spaceAround,
                  spacing: 10,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddDonationScreen(donorId: '')),
                        );
                      },
                      child: const Text('Add Donation'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DonorHistoryScreen(donorId: '')),
                        );
                      },
                      child: const Text('View History'),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.add_alert),
                      label: Text("Request Blood"),
                      onPressed: () => const AddDonationScreen(donorId: ''),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ViewRequestsScreen()),
                        );
                      },
                      child: Text("📢 View Requests"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Searching...",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
