import 'package:flutter/material.dart';
import 'package:ppmt/auth_page.dart';
import 'package:ppmt/screens/add_user.dart';
import 'package:ppmt/screens/admin_dashboard.dart';
import 'package:ppmt/screens/signin_screen.dart';
import 'package:ppmt/screens/splash_screen.dart';
import 'package:ppmt/screens/user.dart';
import 'package:ppmt/screens/user_dashboard.dart';
import 'package:ppmt/screens/users.dart';

Map<String, Widget Function(BuildContext)> route = {
  '/': (context) => Splash(),
  '/auth': (context) => AuthPage(),
  '/signin': (context) => SignInScreen(),
  '/admin_dashboard': (context) => AdminDashboard(),
  '/user_dashboard': (context) => UserDashboard(),
  "/add_user": (context) => AddUser(
        name: "",
        surname: "",
        phoneNumber: "",
        email: "",
      ),
  "/user_list": (context) => Users(),
  "/user": (context) => User(),
};
