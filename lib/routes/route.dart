import 'package:flutter/material.dart';
import 'package:ppmt/auth_page.dart';
import 'package:ppmt/screens/admin/master/level/add_level.dart';
import 'package:ppmt/screens/admin/master/master.dart';
import 'package:ppmt/screens/admin/master/skill/add_skill.dart';
import 'package:ppmt/screens/admin/members/add_user.dart';
import 'package:ppmt/screens/admin/admin_dashboard.dart';
import 'package:ppmt/screens/admin/master/level/level_list.dart';
import 'package:ppmt/screens/admin/master/skill/skill_list.dart';
import 'package:ppmt/screens/admin/message/message.dart';
import 'package:ppmt/screens/admin/profile/account.dart';
import 'package:ppmt/screens/admin/projects/projects.dart';
import 'package:ppmt/screens/signin_screen.dart';
import 'package:ppmt/screens/splash_screen.dart';
import 'package:ppmt/screens/admin/members/user.dart';
import 'package:ppmt/screens/user/user_dashboard.dart';
import 'package:ppmt/screens/admin/members/users.dart';

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
  "/message": (context) => Message(),
  "/profile": (context) => Account(),
  "/master": (context) => Master(),
  "/projects": (context) => Projects(),
  "/user_list": (context) => Users(),
  "/user": (context) => User(),
  "/level_list": (context) => LevelListPage(),
  "/add_level": (context) => AddLevel(
        levelID: "",
        levelName: "",
      ),
  "/skill_list": (context) => SkillListPage(),
  "/add_skill": (context) => AddSkill(skillName: "", skillID: ""),
};
