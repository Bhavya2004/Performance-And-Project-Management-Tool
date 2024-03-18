import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/screens/splash_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splash(),
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'SF-Pro',
      ),
    ),
  );
}
