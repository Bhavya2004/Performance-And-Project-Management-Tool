import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ppmt/components/button.dart';
import 'package:ppmt/components/snackbar.dart';
import 'package:ppmt/components/textfield.dart';
import 'package:ppmt/constants/color.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  bool rememberPassword = true;

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
          key: _formSignInKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        FadeInUp(
                            duration: Duration(
                              milliseconds: 1000,
                            ),
                            child: Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                        SizedBox(
                          height: 20,
                        ),
                        FadeInUp(
                          duration: Duration(
                            milliseconds: 1200,
                          ),
                          child: Text(
                            "Login to your account",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                      ),
                      child: Column(
                        children: <Widget>[
                          FadeInUp(
                            duration: Duration(
                              milliseconds: 1200,
                            ),
                            child: textFormField(
                              labelText: "Email",
                              controller: emailController,
                              obscureText: false,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Email is required";
                                }
                                return null;
                              },
                              keyboardType: TextInputType.text,
                            ),
                          ),
                          FadeInUp(
                            duration: Duration(
                              milliseconds: 1300,
                            ),
                            child: textFormField(
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
                          ),
                        ],
                      ),
                    ),
                    FadeInUp(
                      duration: Duration(milliseconds: 1400),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Container(
                          padding: EdgeInsets.only(top: 3, left: 3),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.black,
                                ),
                                top: BorderSide(
                                  color: Colors.black,
                                ),
                                left: BorderSide(
                                  color: Colors.black,
                                ),
                                right: BorderSide(
                                  color: Colors.black,
                                ),
                              )),
                          child: MaterialButton(
                            minWidth: double.infinity,
                            height: 60,
                            onPressed: signUserIn,
                            color: kButtonColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                50,
                              ),
                            ),
                            child: Text(
                              "Login",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              FadeInUp(
                  duration: Duration(milliseconds: 1200),
                  child: Container(
                    height: MediaQuery.of(context).size.height / 3,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/login.png',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> signUserIn() async {
    if (!_formSignInKey.currentState!.validate()) {
      return;
    }

    if (!_isMounted) {
      return;
    }

    FocusScope.of(context).unfocus();

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

      User? user = FirebaseAuth.instance.currentUser;
      FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          if (documentSnapshot.get('role') == "admin") {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/admin_dashboard',
                  (_) => false,
            );
          } else {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/user_dashboard',
                  (_) => false,
            );
          }
        } else {}
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        showSnackBar(context: context, message: "Email/Password is invalid");
      }
      if (!_isMounted) {
        return;
      }
    }
  }
}
