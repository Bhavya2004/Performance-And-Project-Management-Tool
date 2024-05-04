import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/routes/route.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MaterialApp(
      routes: route,
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      theme: ThemeData( 
        useMaterial3: true,
        fontFamily: 'SF-Pro',
      ),
    ),
  );
}
