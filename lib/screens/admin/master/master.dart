import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/screens/admin/master/complexity/complexity_list.dart';
import 'package:ppmt/screens/admin/master/days/days_list.dart';
import 'package:ppmt/screens/admin/master/level/level_list.dart';
import 'package:ppmt/screens/admin/master/skill/skill_list.dart';
import 'package:ppmt/screens/admin/master/task/task_list.dart';

class Master extends StatefulWidget {
  const Master({Key? key}) : super(key: key);

  @override
  State<Master> createState() => _MasterState();
}

class _MasterState extends State<Master> with SingleTickerProviderStateMixin {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  late TabController _tabController;
  final List<String> tabTitles = [
    'Levels',
    'Skills',
    'Complexity / Severity',
    'Task Type',
    "Days Calculation"
  ];
  String currentTabTitle = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
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
      length: 5,
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
                "Master",
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
                  fontWeight: FontWeight.bold
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
                  'assets/icons/complexity.png',
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
              Tab(
                icon: Image.asset(
                  'assets/icons/days.png',
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
            LevelListPage(),
            SkillListPage(),
            ComplexityListPage(),
            TaskList(),
            DaysList()
          ],
        ),
        floatingActionButton: FloatingActionButton(
          isExtended: true,
          onPressed: () {
            switch (_tabController.index) {
              case 0:
                Navigator.of(context).pushNamed('/add_level');
                break;
              case 1:
                Navigator.of(context).pushNamed('/add_skill');
                break;
              case 2:
                Navigator.of(context).pushNamed('/add_complexity');
                break;
              case 3:
                Navigator.of(context).pushNamed('/add_task');
                break;
              case 4:
                Navigator.of(context).pushNamed('/add_days');
                break;
            }
          },
          backgroundColor: Colors.orange.shade700,
          child: Icon(
            Icons.add,
            color: Colors.orange.shade100,
          ),
        ),
      ),
    );
  }
}
