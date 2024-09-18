import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/ui/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid
      ? await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyAOz406oyWzjEMHlghknA2kZt6AjSIdPSM',
      appId: '1:686425174562:android:b75204e9cca846e849107b',
      messagingSenderId: '686425174562',
      projectId: 'techwiz-e0599',
      storageBucket: 'gs://techwiz-e0599.appspot.com',
    ),
  )
      : await Firebase.initializeApp();
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // if (snapshot.hasData) {
          //   return const HomeScreen();
          // } else {
          //   return const LoginScreen();
          // }
          return const LoginScreen();
        },
      ),
    );
  }
}
