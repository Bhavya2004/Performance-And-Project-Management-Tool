import 'package:flutter/material.dart';
import 'package:ppmt/auth_page.dart';
import 'package:ppmt/screens/admin/master/complexity/add_complexity.dart';
import 'package:ppmt/screens/admin/master/complexity/complexity_list.dart';
import 'package:ppmt/screens/admin/master/days/add_days.dart';
import 'package:ppmt/screens/admin/master/days/days_list.dart';
import 'package:ppmt/screens/admin/master/level/add_level.dart';
import 'package:ppmt/screens/admin/master/master.dart';
import 'package:ppmt/screens/admin/master/points/add_point.dart';
import 'package:ppmt/screens/admin/master/points/point_list.dart';
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
  "/level_list": (context) => LevelListPage(),
  "/add_level": (context) => AddLevel(
        levelID: "",
        levelName: "",
      ),
  "/skill_list": (context) => SkillListPage(),
  "/add_skill": (context) => AddSkill(skillName: "", skillID: ""),
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
  "/add_complexity": (context) => AddComplexity(),
  '/complexity_list': (context) => ComplexityListPage(),
  "/add_task": (context) => AddTask(),
  '/task_list': (context) => TaskList(),
  "/add_days": (context) => AddDays(),
  '/days_list': (context) => DaysList(),
  "/add_point": (context) => AddPoint(),
  '/point_list': (context) => PointList(),
};
