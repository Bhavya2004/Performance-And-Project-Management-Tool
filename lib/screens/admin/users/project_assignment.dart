import 'package:flutter/material.dart';

class ProjectAssignment extends StatefulWidget {
  const ProjectAssignment({super.key});

  @override
  State<ProjectAssignment> createState() => _ProjectAssignmentState();
}

class _ProjectAssignmentState extends State<ProjectAssignment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Project Assignment",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
