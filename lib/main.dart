import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

import 'screens/Login_screen.dart';
import 'screens/Registe_screen.dart';
import 'screens/slpash_screen.dart';
import 'widget/Color.dart';
import 'Navbar/Navigation_Screen.dart';
import 'Phone_auth/Notification Controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyAo2yuusux00km8rt2WhqVOK20Gj36j3LU',
      appId: '1:906112039266:android:20d3f37f534e3f1d2b143b',
      messagingSenderId: '906112039266',
      projectId: 'smart-blood-9e24d',
    ),
  );

  // Initialize OneSignal
  await OneSignal.initialize("c10dd787-9845-4b2e-977d-6083ac2e7e14");

  // Request permission for notifications
  await OneSignal.Notifications.requestPermission(true);

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
        theme: appTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          '/register': (context) => RegisterScreen(),
          '/login': (context) => LoginScreen(),
          '/home': (context) => NavigationScreen(),
        },
      ),
    );
  }
}
