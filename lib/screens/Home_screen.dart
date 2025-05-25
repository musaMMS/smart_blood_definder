import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'package:smart_blood_definder/Near_hospital/Near_Hospital.dart';
import 'package:smart_blood_definder/screens/EmargencyCall)_screen.dart';
import 'package:smart_blood_definder/screens/Blood_Finder_Screen.dart';
import 'package:smart_blood_definder/Phone_auth/Notification_Ui.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int notificationCount = 0;

  @override
  void initState() {
    super.initState();
    loadNotificationCount();
    setupOneSignalListeners();
  }

  void loadNotificationCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationCount = prefs.getInt('notifCount') ?? 0;
    });
  }

  void setupOneSignalListeners() {
    OneSignal.Notifications.addForegroundWillDisplayListener((event) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int count = prefs.getInt('notifCount') ?? 0;
      count++;
      await prefs.setInt('notifCount', count);
      setState(() {
        notificationCount = count;
      });
    });

    OneSignal.Notifications.addClickListener((event) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('notifCount', 0);
      setState(() {
        notificationCount = 0;
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NotificationListScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        'title': 'Find Blood',
        'image': 'assets/10571272.png',
        'screen': const BloodFinderScreen(),
      },
      {
        'title': 'Hospital',
        'image': 'assets/images.png',
        'screen': const HospitalMapScreen(),
      },
      {
        'title': 'Emergency Call',
        'image': 'assets/download.png',
        'screen': EmergencyCallScreen(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏠 Home'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setInt('notifCount', 0);
                  setState(() {
                    notificationCount = 0;
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationListScreen()),
                  );
                },
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
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return AnimatedGridItem(
                  index: index,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => item['screen']),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 8,
                            offset: const Offset(2, 2),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            item['image'],
                            width: 25,
                            height: 25,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item['title'],
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Animation Widget
class AnimatedGridItem extends StatefulWidget {
  final Widget child;
  final int index;

  const AnimatedGridItem({required this.child, required this.index, super.key});

  @override
  State<AnimatedGridItem> createState() => _AnimatedGridItemState();
}

class _AnimatedGridItemState extends State<AnimatedGridItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _fade = Tween<double>(begin: 0, end: 1).animate(curved);
    _scale = Tween<double>(begin: 0.8, end: 1).animate(curved);

    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}
