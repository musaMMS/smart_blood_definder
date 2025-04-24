import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:smart_blood_definder/screens/Login_screen.dart';
import 'package:smart_blood_definder/screens/Registe_screen.dart';
import 'package:smart_blood_definder/screens/slpash_screen.dart';
import 'package:smart_blood_definder/widget/Color.dart';
import 'package:provider/provider.dart';
import 'Navbar/Navigation_Screen.dart';
import 'Phone_auth/Notification Controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyAo2yuusux00km8rt2WhqVOK20Gj36j3LU',
      appId: '1:906112039266:android:20d3f37f534e3f1d2b143b',
      messagingSenderId: '906112039266',
      projectId: 'smart-blood-9e24d',
    ),
  );

  // FirebaseMessaging instance
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  // 🔔 OneSignal initialization
  // ✅ OneSignal Initialization for Flutter 3.x
  OneSignal.shared.setAppId("c10dd787-9845-4b2e-977d-6083ac2e7e14");

  // ✅ Request notification permission (for iOS/Android 13+)
  OneSignal.shared.promptUserForPushNotificationPermission();
  // Requesting permission for iOS notifications
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  // Checking the permission status
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission for notifications');
  } else {
    print('User declined or has not yet granted permission');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationController(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Blood & Medicine Finder',
        initialRoute: '/',
        routes: {
          '/s': (context) => SplashScreen(),
          '/': (context) => RegisterScreen(),
          '/login': (context) => LoginScreen(),
          '/home': (context) => NavigationScreen(),
        },
        theme: appTheme,
      ),
    );
  }
}
