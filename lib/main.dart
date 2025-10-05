import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

import 'splash screen/splash_screen.dart';
import 'authication/sign_in.dart';
import 'admindashboard/admin_dashboard.dart';
import 'userdashboard/dashboard_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey.shade100,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(), // Start with splash screen
      routes: {
        '/login': (context) => const SignInPage(),
        '/admin': (context) => const AdminDashboardPage(),
        '/dashboard': (context) => const DashboardPage(),
      },
    );
  }
}
