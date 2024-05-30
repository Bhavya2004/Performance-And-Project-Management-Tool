import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/screens/admin/projects/allocated_user.dart';
import 'package:ppmt/screens/admin/projects/project_information.dart';
import 'package:ppmt/screens/admin/projects/project_skills.dart';

class ProjectDetails extends StatefulWidget {
  final Map<String, dynamic> projectData;

  const ProjectDetails({Key? key, required this.projectData}) : super(key: key);

  @override
  State<ProjectDetails> createState() => _ProjectDetailsState();
}

class _ProjectDetailsState extends State<ProjectDetails>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> tabTitles = [
    'Project Information',
    'Project Skills',
    'Allocated People',
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
    final projectData = widget.projectData;

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
                "Project Details",
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
            ProjectInformation(
              projectData: projectData,
            ),
            ProjectSkillPage(
              projectData: projectData,
            ),
            AllocatedUser(
              projectData: projectData,
            ),

          ],
        ),
      ),
    );
  }
}
