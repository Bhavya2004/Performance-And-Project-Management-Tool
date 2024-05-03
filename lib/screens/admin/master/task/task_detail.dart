import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/screens/admin/master/task/add_task.dart';
import 'package:ppmt/screens/admin/master/task/subtask/add_subtask.dart';
import 'package:ppmt/screens/admin/master/task/subtask/subtask_list.dart';
import 'package:ppmt/screens/admin/master/task/task_status/add_task_status.dart';
import 'package:ppmt/screens/admin/master/task/task_status/task_status_list.dart';

class TaskDetail extends StatefulWidget {
  final String taskId;
  final String taskName;

  TaskDetail({required this.taskId, Key? key, required this.taskName})
      : super(key: key);

  @override
  State<TaskDetail> createState() => _TaskDetailState();
}

class _TaskDetailState extends State<TaskDetail>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
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
                widget.taskName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.white,
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
              fontSize: 13,
            ),
            physics: ScrollPhysics(),
            indicatorWeight: 1,
            unselectedLabelColor: CupertinoColors.white,
            tabs: [
              Tab(
                text: "Sub Task",
              ),
              Tab(
                text: "Task Status",
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            SubTaskList(taskId: widget.taskId),
            TaskStatusList(taskId: widget.taskId),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          isExtended: true,
          onPressed: () {
            switch (_tabController.index) {
              case 0:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddSubTask(taskId: widget.taskId),
                  ),
                );
                break;
              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTaskStatus(taskId: widget.taskId),
                  ),
                );
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
