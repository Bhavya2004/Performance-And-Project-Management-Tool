import 'package:flutter/material.dart';
import 'package:ppmt/auth_page.dart';
import 'package:ppmt/screens/admin/master/complexity/add_complexity.dart';
import 'package:ppmt/screens/admin/master/complexity/complexity_list.dart';
import 'package:ppmt/screens/admin/master/level/add_level.dart';
import 'package:ppmt/screens/admin/master/master.dart';
import 'package:ppmt/screens/admin/master/skill/add_skill.dart';
import 'package:ppmt/screens/admin/master/task/add_task.dart';
import 'package:ppmt/screens/admin/master/task/task_list.dart';
import 'package:ppmt/screens/admin/members/add_skill_level.dart';
import 'package:ppmt/screens/admin/members/add_user.dart';
import 'package:ppmt/screens/admin/admin_dashboard.dart';
import 'package:ppmt/screens/admin/master/level/level_list.dart';
import 'package:ppmt/screens/admin/master/skill/skill_list.dart';
import 'package:ppmt/screens/admin/members/skill_level.dart';
import 'package:ppmt/screens/admin/message/message.dart';
import 'package:ppmt/screens/admin/profile/account.dart';
import 'package:ppmt/screens/admin/projects/projects.dart';
import 'package:ppmt/screens/signin_screen.dart';
import 'package:ppmt/screens/splash_screen.dart';
import 'package:ppmt/screens/user/user_dashboard.dart';
import 'package:ppmt/screens/admin/members/users.dart';
import 'package:ppmt/screens/user/user_skill_level.dart';

Map<String, Widget Function(BuildContext)> route = {
  '/': (context) => const Splash(),
  '/auth': (context) => const AuthPage(),
  '/signin': (context) => const SignInScreen(),
  '/admin_dashboard': (context) => AdminDashboard(),
  '/user_dashboard': (context) => UserDashboard(),
  "/add_user": (context) => const AddUser(
        name: "",
        surname: "",
        phoneNumber: "",
        email: "",
      ),
  "/message": (context) => const Message(),
  "/profile": (context) => const Account(),
  "/master": (context) => const Master(),
  "/projects": (context) => const Projects(),
  "/user_list": (context) => const Users(),
  "/level_list": (context) => LevelListPage(),
  "/add_level": (context) => const AddLevel(
        levelID: "",
        levelName: "",
      ),
  "/skill_list": (context) => SkillListPage(),
  "/add_skill": (context) => const AddSkill(skillName: "", skillID: ""),
  '/add_skill_level': (context) => AssignSkillLevel(
        userId: "",
      ),
  '/skill_level': (context) => SkillLevel(
        userID: "",
        userName: "",
      ),
  '/user_skill_level': (context) => UserSkillLevel(
        UserID: "",
      ),
  "/add_complexity": (context) => const AddComplexity(),
  '/complexity_list': (context) => ComplexityListPage(),
  "/add_task": (context) => const AddTask(),
  '/task_list': (context) => const TaskList(),
};
