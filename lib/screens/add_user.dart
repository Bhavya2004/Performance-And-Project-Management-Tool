import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/components/button.dart';
import 'package:ppmt/components/textfield.dart';
import 'dart:math';

class AddUser extends StatefulWidget {
  const AddUser({Key? key}) : super(key: key);

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final _formSignInKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final surNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Add User"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Form(
              key: _formSignInKey,
              child: Column(
                children: [
                  textFormField(
                    controller: emailController,
                    obscureText: false,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Email is required";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    labelText: 'Email',
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  button(
                    buttonName: "Add User",
                    onPressed: addUser,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addUser() async {
    if (_formSignInKey.currentState!.validate()) {
      try {
        // Create user account in Firebase Authentication
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: emailController.text,
              password: generateRandomPassword(),
            )
            .then(
              (value) => {
                postDetailsToFirestore(emailController.text, "user"),
              },
            );
        // Send temporary password to user's email
        await sendTemporaryPassword(
            emailController.text, generateRandomPassword());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'User registered successfully. Check your email for the password.'),
          ),
        );

        // Navigate back to Dashboard after registration
        Navigator.of(context).pushReplacementNamed('/user_dashboard');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('The account already exists for that email'),
            ),
          );
        }
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred. Please try again later'),
          ),
        );
      }
    }

    if (!_isMounted) {
      return;
    }
  }

// Generate a random temporary password
  String generateRandomPassword() {
    const int minLength = 8;
    const int maxLength = 12;
    const _chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random _random = Random.secure();

    final length = minLength + _random.nextInt(maxLength - minLength + 1);

    return Iterable.generate(
        length, (_) => _chars[_random.nextInt(_chars.length)]).join();
  }

// Send temporary password to the user's email address
  Future<void> sendTemporaryPassword(
      String email, String temporaryPassword) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      print('Temporary password sent to $email');
    } catch (e) {
      print('Failed to send temporary password: $e');
      // Handle error appropriately
    }
  }

  postDetailsToFirestore(String email, String rool) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    var user = FirebaseAuth.instance.currentUser;
    CollectionReference ref = firebaseFirestore.collection('users');
    ref.doc(user!.uid).set({'email': emailController.text, 'role': rool});
  }
}
