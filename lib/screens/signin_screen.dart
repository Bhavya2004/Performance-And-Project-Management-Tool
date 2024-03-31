import 'package:flutter/material.dart'; // Importing Flutter material package for UI components
import 'package:firebase_auth/firebase_auth.dart'; // Importing Firebase authentication package
import 'package:cloud_firestore/cloud_firestore.dart'; // Importing Cloud Firestore package
import 'package:ppmt/components/button.dart'; // Importing custom button component
import 'package:ppmt/components/snackbar.dart'; // Importing custom snackbar component
import 'package:ppmt/components/textfield.dart'; // Importing custom textfield component
import 'package:ppmt/constants/color.dart'; // Importing color constants

class SignInScreen extends StatefulWidget { // Defining SignInScreen widget as a StatefulWidget
  const SignInScreen({Key? key}) : super(key: key); // Constructor for SignInScreen widget

  @override
  _SignInScreenState createState() => _SignInScreenState(); // Creating state for SignInScreen widget
}

class _SignInScreenState extends State<SignInScreen> { // State class for SignInScreen widget
  final _formSignInKey = GlobalKey<FormState>(); // GlobalKey for accessing form state
  bool rememberPassword = true; // Boolean flag for remembering password

  // Text editing controllers for email and password fields
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isMounted = false; // Flag to track whether the widget is mounted or not

  @override
  void initState() { // Initialization method
    super.initState();
    _isMounted = true; // Setting _isMounted flag to true when widget is initialized
  }

  @override
  void dispose() { // Disposal method
    _isMounted = false; // Setting _isMounted flag to false when widget is disposed
    emailController.dispose(); // Disposing emailController
    passwordController.dispose(); // Disposing passwordController
    super.dispose();
  }

  Future<void> signUserIn() async { // Method for signing in the user
    if (!_formSignInKey.currentState!.validate()) { // Validating form
      return;
    }

    if (!_isMounted) { // Checking if the widget is mounted
      return;
    }

    FocusScope.of(context).unfocus();

    try {
      showSnackBar(context: context, message: "Signin in... "); // Showing a snackbar indicating signing in

      // Signing in the user using Firebase authentication
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      if (!_isMounted) { // Checking if the widget is mounted
        return;
      }


      ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hiding the current snackbar

      // Getting current user and checking their role in Firestore
      User? user = FirebaseAuth.instance.currentUser;
      FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) { // Checking if document exists
          if (documentSnapshot.get('role') == "admin") { // Checking user role
            // Navigating to admin dashboard if user is admin
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/admin_dashboard',
                  (_) => false, // Removing all routes below '/admin_dashboard'
            );
          } else {
            // Navigating to user dashboard if user is not admin
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/user_dashboard',
                  (_) => false, // Removing all routes below '/user_dashboard'
            );
          }
        } else {
          print('Document does not exist on the database');
        }
      });
      print(user.uid); // Printing user ID
    } on FirebaseAuthException catch (e) { // Handling FirebaseAuth exceptions
      if (e.code == 'invalid-credential') {
        // Showing an error snackbar to the user
        showSnackBar(context: context, message: "Email/Password is invalid");
      }
      if (!_isMounted) { // Checking if the widget is mounted
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) { // Building the UI for SignInScreen widget
    return Scaffold( // Scaffold widget for basic material design structure
      backgroundColor: Colors.white, // Setting background color
      body: Center( // Centering the content vertically and horizontally
        child: SingleChildScrollView( // Allowing scrolling if content overflows
          scrollDirection: Axis.vertical,
          child: Form( // Form widget for managing form state
            key: _formSignInKey, // Assigning GlobalKey to form
            child: Column( // Column widget for arranging children vertically
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50), // Empty space
                const Icon( // Icon widget for displaying lock icon
                  Icons.lock,
                  size: 100,
                ),
                const SizedBox(height: 50), // Empty space
                Text( // Text widget for displaying welcome message
                  'Welcome back you\'ve been missed!',
                  style: TextStyle(
                    color: AppColor.elephant, // Setting text color
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25), // Empty space
                // Email text field
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
                const SizedBox(height: 10), // Empty space
                // Password text field
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
                const SizedBox(height: 10), // Empty space
                const SizedBox(height: 25), // Empty space
                // Sign in button
                button(
                  buttonName: "Login",
                  onPressed: signUserIn,
                ),
                const SizedBox(height: 50), // Empty space
              ],
            ),
          ),
        ),
      ),
    );
  }
}
