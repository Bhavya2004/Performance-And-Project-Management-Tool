import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ppmt/constants/color.dart';
import 'AddProject.dart';

class Project {
  final String id;
  final String name;
  final String status;
  final String description;
  final String managementPoints;
  final String totalBonus;
  // final String? startDate;
  // final String? endDate;

  Project({
    required this.id,
    required this.name,
    required this.status,
    required this.description,
    required this.managementPoints,
    required this.totalBonus,
    // this.startDate,
    // this.endDate,
  });
}

class Projects extends StatefulWidget {
  const Projects({super.key});

  @override
  State<Projects> createState() => _ProjectsState();
}

class _ProjectsState extends State<Projects> {
  final TextEditingController _searchController = TextEditingController();
  final List<Project> _projects = [];

  bool _showToDo = true;
  bool _showInProgress = true;
  bool _showCompleted = true;

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Projects').get();
    final projects = snapshot.docs.map((doc) {
      return Project(
        id: doc.id,
        name: doc['Name'],
        status: doc['Status'],
        description: doc['Description'],
        managementPoints: doc['Management_Points'],
        totalBonus: doc['Total_Bonus'],
        // startDate: doc['Start Date'] != null
        //     ? (doc['Start Date'] as Timestamp).toDate().toString()
        //     : null,
        // endDate: doc['End Date']! != null
        //     ? (doc['End Date'] as Timestamp).toDate().toString()
        //     : null,
      );
    }).toList();

    setState(() {
      _projects.clear();
      _projects.addAll(projects);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: CupertinoColors.white,
        ),
        backgroundColor: kAppBarColor,
        title: Text(
          'Projects',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    children: [
                      Checkbox(
                        value: _showToDo,
                        onChanged: (value) {
                          setState(() {
                            _showToDo = value!;
                          });
                        },
                      ),
                      Text('ToDo', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    children: [
                      Checkbox(
                        value: _showInProgress,
                        onChanged: (value) {
                          setState(() {
                            _showInProgress = value!;
                          });
                        },
                      ),
                      Text('InProgress', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    children: [
                      Checkbox(
                        value: _showCompleted,
                        onChanged: (value) {
                          setState(() {
                            _showCompleted = value!;
                          });
                        },
                      ),
                      Text('Completed', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search Project Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            Expanded(
              child: ListView(
                children: _getFilteredProjects().map((project) {
                  return GestureDetector(
                    onTap: () {
                      _openEditPage(project);
                    },
                    child: Card(
                      color: _getStatusColor(project.status),
                      child: ListTile(
                        title: Text(
                          project.name,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(project.status),
                        trailing: Icon(CupertinoIcons.info_circle_fill),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProject(),
            ),
          );
          _fetchProjects(); // Fetch the projects again after returning from AddProject screen
        },
        child: Icon(Icons.add),
      ),
    );
  }

  List<Project> _getFilteredProjects() {
    List<Project> filteredProjects = _projects.where((project) {
      if (!_showToDo && project.status == 'ToDo') return false;
      if (!_showInProgress && project.status == 'InProgress') return false;
      if (!_showCompleted && project.status == 'Completed') return false;
      if (_searchController.text.isNotEmpty &&
          !project.name
              .toLowerCase()
              .contains(_searchController.text.toLowerCase())) return false;
      return true;
    }).toList();

    filteredProjects.sort((a, b) {
      const statusOrder = ['ToDo', 'InProgress', 'Completed'];
      return statusOrder
          .indexOf(a.status)
          .compareTo(statusOrder.indexOf(b.status));
    });

    return filteredProjects;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ToDo':
        return Colors.grey[300]!;
      case 'InProgress':
        return Colors.yellow[300]!;
      case 'Completed':
        return Colors.green[300]!;
      default:
        return Colors.white;
    }
  }

  void _openEditPage(Project project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProject(
          isUpdating: true,
          projectId: project.id,
          projectName: project.name,
          description: project.description,
          status: project.status,
          managementPoints: project.managementPoints,
          totalBonus: project.totalBonus,
          // startDate: project.startDate,
          // endDate: project.endDate,
        ),
      ),
    ).then((_) {
      _fetchProjects();
    });
  }
}
