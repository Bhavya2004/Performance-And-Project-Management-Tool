import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/components/button.dart';
import 'package:ppmt/components/snackbar.dart';
import 'package:ppmt/components/textfield.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/constants/generate_id.dart';

class AddUser extends StatefulWidget {
  final String userID;
  final String name;
  final String surname;
  final String phoneNumber;
  final String email;
  final String address;

  const AddUser({
    super.key,
    required this.userID,
    required this.name,
    required this.surname,
    required this.phoneNumber,
    required this.email,
    required this.address,
  });

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final surNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final addressController = TextEditingController();
  bool isMounted = false;

  @override
  void initState() {
    super.initState();
    isMounted = true;
    nameController.text = widget.name;
    surNameController.text = widget.surname;
    emailController.text = widget.email;
    phoneNumberController.text = widget.phoneNumber;
    addressController.text = widget.address;
  }

  @override
  void dispose() {
    isMounted = false;
    nameController.dispose();
    surNameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
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
          widget.userID != "" ? "Update User" : "Add User",
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
              key: formKey,
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
                    enabled: widget.userID == "",
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
                  textFormField(
                    controller: addressController,
                    obscureText: false,
                    validator: (value) {
                      return null;
                    },
                    keyboardType: TextInputType.streetAddress,
                    labelText: 'Address (Optional)',
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: button(
                        buttonName:
                            widget.userID != "" ? "Update User" : "Add User",
                        backgroundColor: CupertinoColors.black,
                        textColor: CupertinoColors.white,
                        onPressed: submit),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> submit() async {
    if (formKey.currentState!.validate()) {
      try {
        if (widget.userID != "") {
          await updateUser();
          showSnackBar(
              context: context, message: "User Details Updated Successfully");
        } else {
          try {
            await addUser();
            showSnackBar(
              context: context,
              message:
                  "User registered successfully. Check your email for the password.",
            );
          } on FirebaseAuthException catch (e) {
            if (e.code == 'email-already-in-use') {
              showSnackBar(
                context: context,
                message: "The account already exists for that email",
              );
              return;
            }
          } catch (e) {
            showSnackBar(
              context: context,
              message: "An error occurred. Please try again later",
            );
            return;
          }
        }
        // Refresh data here, for example by calling a function from the parent widget
        // Assuming there's a function refreshData in the parent widget
        // refreshData();
        // Close the current screen and pop back to the previous one
        Navigator.of(context).pop();
      } catch (e) {
        showSnackBar(context: context, message: "Error: $e");
      }
    }
  }

  Future<void> addUser() async {
    try {
      int lastUserID =
          await getLastID(collectionName: "users", primaryKey: "userID");
      int newUserID = lastUserID + 1;

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: generateRandomPassword(),
      );

      await sendTemporaryPassword(
        emailController.text,
        generateRandomPassword(),
      );

      final user = FirebaseAuth.instance.currentUser;
      final ref = FirebaseFirestore.instance.collection('users');
      ref.doc(user!.uid).set({
        "userID": newUserID.toString(),
        'email': emailController.text,
        'role': "user",
        'name': nameController.text.toString(),
        'surname': surNameController.text.toString(),
        'phoneNumber': phoneNumberController.text,
        'isDisabled': false,
        'address': addressController.text,
      });
    } catch (e) {
      throw ('Error adding level: $e');
    }
  }

  Future<void> updateUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final ref = FirebaseFirestore.instance.collection('users');
      await ref.doc(user!.uid).update({
        'email': emailController.text,
        'name': nameController.text,
        'surname': surNameController.text,
        'phoneNumber': phoneNumberController.text,
        'address': addressController.text,
      });
    } catch (e) {
      throw ('Error updating user details: $e');
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
    } catch (e) {}
  }
}
