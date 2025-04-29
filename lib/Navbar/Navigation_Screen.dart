import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_blood_definder/Phone_auth/viewcooection_screen.dart';
import '../Medicine/medicin_search_screen.dart';
import '../Phone_auth/SendConnectRequestScreen.dart';
import '../screens/Home_Screen.dart';
import 'package:http/http.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});
  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;
  int _unreadMessageCount = 0;

  final List<Widget> _screens = [
    HomeScreen(),                  // index 0
    SearchMedicineScreen(),       // index 1
    ViewConnectionsScreen(),       // index 2
    // PendingRequestsScreen(),      // index 3 <-- এটাকে নতুন যোগ করা হলো
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 5) {
        setState(() {
          _unreadMessageCount = 0;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    listenForUnreadMessages();
  }

  void listenForUnreadMessages() {
    FirebaseFirestore.instance
        .collection('messages')
        .snapshots()
        .listen((snapshot) {
      int totalUnread = 0;

      for (var doc in snapshot.docs) {
        doc.reference
            .collection('chats')
            .where('isSeen', isEqualTo: false)
            .get()
            .then((querySnapshot) {
          totalUnread += querySnapshot.docs.length;
          setState(() {
            _unreadMessageCount = totalUnread;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.bloodtype),
            label: 'Blood',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'Medicine',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Friends',
          ),
          // const BottomNavigationBarItem(
          //   icon: Icon(Icons.person_add),
          //   label: 'Requests',
          // ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
