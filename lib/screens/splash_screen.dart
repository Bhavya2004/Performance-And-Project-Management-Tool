import 'dart:async';
import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    initializeFirstLaunch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "PPMT",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  void initializeFirstLaunch() async {
    Timer(
      Duration(seconds: 5),
      () {
        Navigator.of(context).pushReplacementNamed('/auth');
      },
    );
  }
}
