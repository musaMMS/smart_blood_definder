import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Screens
import 'Phone_auth/Notification_Ui.dart';
import 'screens/Login_screen.dart';
import 'screens/Registe_screen.dart';
import 'screens/slpash_screen.dart';
import 'Navbar/Navigation_Screen.dart';

// Widget & Controller
import 'widget/Color.dart';
import 'Phone_auth/Notification Controller.dart';

// ✅ Global NavigatorKey
// Screens
import 'Navbar/Navigation_Screen.dart';
import 'Phone_auth/Notification_Ui.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyAo2yuusux00km8rt2WhqVOK20Gj36j3LU',
      appId: '1:906112039266:android:20d3f37f534e3f1d2b143b',
      messagingSenderId: '906112039266',
      projectId: 'smart-blood-9e24d',
    ),
  );

  // ✅ Initialize OneSignal
  OneSignal.Debug.setLogLevel(OSLogLevel.none); // Logs off
  OneSignal.initialize("c10dd787-9845-4b2e-977d-6083ac2e7e14");

  // ✅ Ask for Notification permission
  await OneSignal.Notifications.requestPermission(true);

  // ✅ Handle notification received when the app is in the foreground
  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    final title = event.notification.title ?? 'No Title';
    final body = event.notification.body ?? 'No Body';
    final time = DateTime.now();
    NotificationController.instance?.addNotification(title, body, time);
  });

  // ✅ Handle notification click
  OneSignal.Notifications.addClickListener((event) {
    navigatorKey.currentState?.pushNamed('/notifications');
  });

  // ✅ Retrieve Device Player ID (NEW way for 5.0.4)
  String? playerId = OneSignal.User.pushSubscription.id;
  print('🔔 OneSignal Player ID: $playerId');

  if (playerId != null) {
    // ✅ Save Player ID Locally using SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('onesignalToken', playerId);
    print('✅ Player ID saved in SharedPreferences.');

    // ✅ If user is logged in, save Player ID to Firestore
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'onesignalToken': playerId});
      print('✅ Player ID updated in Firestore.');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Smart Blood & Medicine Finder',
      theme: appTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/register': (context) => RegisterScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => NavigationScreen(),
        '/notifications': (context) => NotificationListScreen(),
      },
    );
  }
}

