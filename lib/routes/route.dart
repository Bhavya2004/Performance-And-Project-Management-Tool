import 'package:flutter/material.dart';
import 'package:ppmt/screens/admin/master/complexity/add_complexity.dart';
import 'package:ppmt/screens/admin/master/complexity/complexity_list.dart';
import 'package:ppmt/screens/admin/master/days/add_days.dart';
import 'package:ppmt/screens/admin/master/days/days_list.dart';
import 'package:ppmt/screens/admin/master/level/add_level.dart';
import 'package:ppmt/screens/admin/master/master.dart';
import 'package:ppmt/screens/admin/master/points/add_point.dart';
import 'package:ppmt/screens/admin/master/points/point_list.dart';
import 'package:ppmt/screens/admin/master/skill/add_skill.dart';
import 'package:ppmt/screens/admin/master/task/add_task_type.dart';
import 'package:ppmt/screens/admin/master/task/task_type_list.dart';
import 'package:ppmt/screens/splash_screen.dart';
import 'package:ppmt/screens/user/skill_level/add_skill_level.dart';
import 'package:ppmt/screens/admin/members/add_user.dart';
import 'package:ppmt/screens/admin/admin_dashboard.dart';
import 'package:ppmt/screens/admin/master/level/level_list.dart';
import 'package:ppmt/screens/admin/master/skill/skill_list.dart';
import 'package:ppmt/screens/admin/members/skill_level.dart';
import 'package:ppmt/screens/admin/message/message.dart';
import 'package:ppmt/screens/admin/profile/account.dart';
import 'package:ppmt/screens/admin/projects/projects.dart';
import 'package:ppmt/screens/signin_screen.dart';
import 'package:ppmt/screens/user/user_dashboard.dart';
import 'package:ppmt/screens/admin/members/users.dart';
import 'package:ppmt/screens/user/skill_level/skill_level_list.dart';

Map<String, Widget Function(BuildContext)> route = {
  '/': (context) => Splash(),
  '/sign_in': (context) => SignInScreen(),
  '/admin_dashboard': (context) => AdminDashboard(),
  '/user_dashboard': (context) => UserDashboard(),
  "/add_user": (context) => AddUser(
        userID: "",
        address: "",
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
        userSkillsLevelsID: "",
        userID: "",
      ),
  '/skill_level': (context) => SkillLevel(
        userID: "",
        userName: "",
      ),
  '/user_skill_level': (context) => SkillLevelList(
        userID: "",
      ),
  "/add_complexity": (context) => AddComplexity(),
  '/complexity_list': (context) => ComplexityListPage(),
  "/add_task_type": (context) => AddTaskType(
        taskTypeID: "",
        taskTypeName: "",
      ),
  '/task_type_list': (context) => TaskTypeList(),
  "/add_days": (context) => AddDays(
        daysID: "",
      ),
  '/days_list': (context) => DaysList(),
  "/add_point": (context) => AddPoint(
        pointsID: "",
      ),
  '/point_list': (context) => PointList(),
};
