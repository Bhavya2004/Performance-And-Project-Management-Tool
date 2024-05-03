import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/components/button.dart';
import 'package:ppmt/components/textfield.dart';
import 'package:ppmt/constants/color.dart';

class AddUser extends StatefulWidget {
  final String? name;
  final String? surname;
  final String? phoneNumber;
  final String? email;
  final bool isUpdating;
  final bool isProfileEditing;

  const AddUser({
    Key? key,
    this.name,
    this.surname,
    this.phoneNumber,
    this.email,
    this.isUpdating = false,
    this.isProfileEditing = false,
  }) : super(key: key);

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
    nameController.text = widget.name ?? '';
    surNameController.text = widget.surname ?? '';
    emailController.text = widget.email ?? '';
    phoneNumberController.text = widget.phoneNumber ?? '';
  }

  @override
  void dispose() {
    _isMounted = false;
    nameController.dispose();
    surNameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: CupertinoColors.white,
        ),
        backgroundColor: kAppBarColor,
        title: Text(
          widget.isProfileEditing ? "Update User" : "Add User",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Form(
              key: _formSignInKey,
              child: Column(
                children: [
                  textFormField(
                    controller: nameController,
                    obscureText: false,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Name is required";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.name,
                    labelText: 'Name',
                  ),
                  textFormField(
                    controller: surNameController,
                    obscureText: false,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Surname is required";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.name,
                    labelText: 'Surname',
                  ),
                  textFormField(
                    controller: phoneNumberController,
                    obscureText: false,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Phone Number is required";
                      }
                      return null;
                    },
                    inputFormatNumber: 10,
                    keyboardType: TextInputType.number,
                    labelText: 'Phone Number',
                  ),
                  textFormField(
                    controller: emailController,
                    enabled: !widget.isProfileEditing,
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
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: button(
                      buttonName:
                          widget.isProfileEditing ? "Update User" : "Add User",
                      backgroundColor: CupertinoColors.black,
                      textColor: CupertinoColors.white,
                      onPressed: widget.isProfileEditing ? editUser : addUser,
                    ),
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
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: generateRandomPassword(),
        );

        await sendTemporaryPassword(
          emailController.text,
          generateRandomPassword(),
        );

        await postDetailsToFirestore(
          name: nameController.text.toString(),
          surname: surNameController.text.toString(),
          phoneNumber: phoneNumberController.text,
          email: emailController.text.toString(),
          role: "user",
          isDisabled: false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User registered successfully. Check your email for the password.',
            ),
          ),
        );

        Navigator.of(context).pop();
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
  }

  Future<void> editUser() async {
    if (_formSignInKey.currentState!.validate()) {
      try {
        await updateDetails();
        Navigator.of(context).pop();
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred. Please try again later'),
          ),
        );
      }
    }
  }

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

  Future<void> sendTemporaryPassword(
      String email, String temporaryPassword) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      print('Temporary password sent to $email');
    } catch (e) {
      print('Failed to send temporary password: $e');
    }
  }

  postDetailsToFirestore(
      {required String email,
      required String role,
      required String name,
      required String surname,
      required String phoneNumber,
      required bool isDisabled}) async {
    final firebaseFirestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    final ref = firebaseFirestore.collection('users');
    ref.doc(user!.uid).set({
      'email': emailController.text,
      'role': role,
      'name': name,
      'surname': surname,
      'phoneNumber': phoneNumber,
      'isDisabled': isDisabled,
    });
  }

  Future<void> updateDetails() async {
    final firebaseFirestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    final ref = firebaseFirestore.collection('users');
    await ref.doc(user!.uid).update({
      'email': emailController.text,
      'name': nameController.text,
      'surname': surNameController.text,
      'phoneNumber': phoneNumberController.text,
    });
  }
}
