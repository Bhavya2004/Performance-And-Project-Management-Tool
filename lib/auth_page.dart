import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  void initState() {
    super.initState();
    // Call the function to handle authentication state
    _handleAuthState();
  }

  Future<void> _handleAuthState() async {
    // Delay the navigation slightly to ensure it's not during the build phase
    await Future.delayed(Duration.zero);
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userEmail = user.email;
      if (userEmail == "test@gmail.com") {
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/signin');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // or any other loading indicator
      ),
    );
  }
}
