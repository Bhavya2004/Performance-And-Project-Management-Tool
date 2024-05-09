import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ppmt/components/snackbar.dart';
import 'package:ppmt/components/textfield.dart';
import 'package:ppmt/constants/color.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final formSignInKey = GlobalKey<FormState>();
  final formForgetPasswordDialogKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final forgetEmailController = TextEditingController();
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
    forgetEmailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> resetPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future<void> signUserIn() async {
    if (!formSignInKey.currentState!.validate() || !_isMounted) {
      return;
    }

    FocusScope.of(context).unfocus();

    try {
      showSnackBar(context: context, message: "Signing in...");

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      final user = FirebaseAuth.instance.currentUser;
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (docSnapshot.exists) {
        final role = docSnapshot.get('role');
        Navigator.pushNamedAndRemoveUntil(
          context,
          role == "admin" ? '/admin_dashboard' : '/user_dashboard',
          (_) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        showSnackBar(context: context, message: "Email/Password is invalid");
      }
    }
  }

  AlertDialog buildResetPasswordDialog() {
    return AlertDialog(
      backgroundColor: CupertinoColors.white,
      title: Text(
        'Forgot Password',
        style: TextStyle(
          fontFamily: "SF-Pro",
          color: CupertinoColors.black,
        ),
      ),
      content: Form(
        key: formForgetPasswordDialogKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            textFormField(
              controller: forgetEmailController,
              obscureText: false,
              validator: (value) => value == null || value.trim().isEmpty
                  ? "Email is required"
                  : null,
              keyboardType: TextInputType.text,
              labelText: "Enter your email",
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            if (formForgetPasswordDialogKey.currentState!.validate()) {
              resetPassword(forgetEmailController.text);
              Navigator.of(context).pop();
            }
          },
          child: Text(
            "Submit",
            style: TextStyle(
              fontFamily: "SF-Pro",
              color: CupertinoColors.black,
            ),
          ),
        )
      ],
    );
  }

  Widget buildLoginButton() {
    return Container(
      padding: EdgeInsets.only(top: 3, left: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.black),
      ),
      child: MaterialButton(
        minWidth: double.infinity,
        height: 60,
        onPressed: signUserIn,
        color: kButtonColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          "Login",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Form(
          key: formSignInKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Login to your account",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: <Widget>[
                          textFormField(
                            labelText: "Email",
                            controller: emailController,
                            obscureText: false,
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? "Email is required"
                                    : null,
                            keyboardType: TextInputType.text,
                          ),
                          textFormField(
                            controller: passwordController,
                            obscureText: true,
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? "Password is required"
                                    : null,
                            keyboardType: TextInputType.text,
                            labelText: 'Password',
                          ),
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    buildResetPasswordDialog(),
                              );
                            },
                            child: Text(
                              "Forgot Password",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: buildLoginButton(),
                    ),
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height / 3,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/login.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
