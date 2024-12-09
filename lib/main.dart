import 'package:firebaselab/screens/login_screen.dart';
import 'package:firebaselab/screens/homescreen.dart';
import 'package:firebaselab/screens/register_screen.dart';

import 'firebase_options.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Study Planner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        useMaterial3: true,
      ),
      initialRoute: '/signup',
      routes: {
        '/login': (context) => const LoginPage2(),
        '/signup': (context) => const SignupPage2(),
        '/home': (context) => const Homescreen(),
      },
    );
  }
}
