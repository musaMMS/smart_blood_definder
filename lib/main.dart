import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:smart_blood_definder/Phone_auth/viewcooection_screen.dart';
// Screens
import 'Phone_auth/Notification_Ui.dart';
import 'screens/Login_screen.dart';
import 'screens/Registe_screen.dart';
import 'screens/slpash_screen.dart';
import 'Navbar/Navigation_Screen.dart';

// Widget & Controller
import 'widget/Color.dart';
import 'Phone_auth/Notification Controller.dart'; // ✅ NotificationController import

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyDnl_bYbAHkkOx5wbS83mLABawQIc3wbF0',
      appId: '1:600386780335:android:0b5e179319499c2f50e85a',
      messagingSenderId: '600386780335',
      projectId: 'smart-blood-definder',
    ),
  );
  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    final title = event.notification.title ?? 'No Title';
    final body = event.notification.body ?? 'No Body';
    final time = DateTime.now();

    final controller = navigatorKey.currentContext!.read<NotificationController>();
    controller.addNotification(title, body, time);
  });


  // ✅ Initialize OneSignal
  OneSignal.Debug.setLogLevel(OSLogLevel.none);
  OneSignal.initialize("27eda07b-303a-466b-b567-749ab2793607");
  await OneSignal.Notifications.requestPermission(true);

  runApp(
    ChangeNotifierProvider(
      create: (_) => NotificationController(), // ✅ PROVIDER দিচ্ছি এখানে
      child: const MyApp(),
    ),
  );
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
        '/frqest':(context) => ViewConnectionsScreen(),
      },
    );
  }
}