import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/screens/admin/master/days/days_list.dart';
import 'package:ppmt/screens/admin/master/level/level_list.dart';
import 'package:ppmt/screens/admin/master/points/point_list.dart';
import 'package:ppmt/screens/admin/master/skill/skill_list.dart';
import 'package:ppmt/screens/admin/master/task/task_type_list.dart';
import 'package:ppmt/screens/admin/users/personal_details.dart';
import 'package:ppmt/screens/admin/users/project_assignment.dart';
import 'package:ppmt/screens/admin/users/skill_level.dart';

class UserDetails extends StatefulWidget {
  final String userID;
  final String userName;

  UserDetails({super.key, required this.userID, required this.userName});

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> tabTitles = [
    'Skill - Level',
    'User Details',
    'Project Assignment',
  ];
  String currentTabTitle = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    );
    _tabController.addListener(_handleTabSelection);
    currentTabTitle = tabTitles[0];
  }

  void _handleTabSelection() {
    setState(() {
      currentTabTitle = tabTitles[_tabController.index];
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: CupertinoColors.white,
          ),
          backgroundColor: kAppBarColor,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.userName.toString(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.white,
                ),
              ),
              Text(
                currentTabTitle,
                style: TextStyle(
                  fontSize: 15,
                  color: kButtonColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.orange,
            indicatorColor: kButtonColor,
            labelStyle: TextStyle(
              fontFamily: "SF-Pro",
              fontSize: 11,
            ),
            physics: ScrollPhysics(),
            indicatorWeight: 1,
            unselectedLabelColor: CupertinoColors.white,
            tabs: [
              Tab(
                icon: Image.asset(
                  'assets/icons/levels.png',
                  width: 30,
                  height: 30,
                  color: kButtonColor,
                ),
              ),
              Tab(
                icon: Image.asset(
                  'assets/icons/skills.png',
                  width: 30,
                  height: 30,
                  color: kButtonColor,
                ),
              ),
              Tab(
                icon: Image.asset(
                  'assets/icons/tasks.png',
                  width: 30,
                  height: 30,
                  color: kButtonColor,
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            SkillLevel(userID: widget.userID),
            PersonalDetails(
              userID: widget.userID,
            ),
            ProjectAssignment()
          ],
        ),
      ),
    );
  }
}
