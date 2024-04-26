import 'package:flutter/material.dart';

class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task"),
      ),
      body: Container(),
      floatingActionButton: FloatingActionButton.extended(
        label: Text("Add Task"),
        icon: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).pushNamed('/add_task');
        },
      ),
    );
  }
}
