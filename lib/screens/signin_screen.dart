import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ppmt/components/button.dart';
import 'package:ppmt/components/snackbar.dart';
import 'package:ppmt/components/textfield.dart';
import 'package:ppmt/constants/color.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  bool rememberPassword = true;

  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
  }

  @override
  void dispose() {
    _isMounted = false;
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> signUserIn() async {
    if (!_formSignInKey.currentState!.validate()) {
      return;
    }

    if (!_isMounted) {
      return;
    }

    try {
      showSnackBar(context: context, message: "Signin in... ");

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      if (!_isMounted) {
        return;
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      // Check if email is admin email, if yes navigate to AdminDashboard, else navigate to UserDashboard
      User? user = FirebaseAuth.instance.currentUser;
      dynamic kk = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          if (documentSnapshot.get('role') == "admin") {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/admin_dashboard',
              (_) => false, // Removes all routes below '/admin_dashboard'
            );
          } else {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/user_dashboard',
              (_) => false, // Removes all routes below '/user_dashboard'
            );
          }
        } else {
          print('Document does not exist on the database');
        }
      });
      print(user.uid);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        // show error to user
        showSnackBar(context: context, message: "Email/Password is invalid");
      }
      if (!_isMounted) {
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Form(
            key: _formSignInKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                // logo
                const Icon(
                  Icons.lock,
                  size: 100,
                ),
                const SizedBox(height: 50),
                // welcome back, you've been missed!
                Text(
                  'Welcome back you\'ve been missed!',
                  style: TextStyle(
                    color: AppColor.elephant,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25),
                // email textfield
                textFormField(
                  controller: emailController,
                  obscureText: false,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Email is required";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  labelText: 'Email',
                ),
                const SizedBox(height: 10),
                // password textfield
                textFormField(
                  controller: passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Password is required";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  labelText: 'Password',
                ),

                const SizedBox(height: 10),

                const SizedBox(height: 25),
                // sign in button
                button(
                  buttonName: "Login",
                  onPressed: signUserIn,
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
