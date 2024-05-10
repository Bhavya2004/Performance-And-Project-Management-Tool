import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/screens/admin/master/task/sub_task/add_subtask.dart';
import 'package:ppmt/screens/admin/master/task/sub_task/subtask_list.dart';
import 'package:ppmt/screens/admin/master/task/task_type_status/add_task_type_status.dart';
import 'package:ppmt/screens/admin/master/task/task_type_status/task_type_status_list.dart';

class TaskTypeDetail extends StatefulWidget {
  final String taskTypeID;
  final String taskTypeName;

  TaskTypeDetail(
      {required this.taskTypeID, Key? key, required this.taskTypeName})
      : super(key: key);

  @override
  State<TaskTypeDetail> createState() => _TaskTypeDetailState();
}

class _TaskTypeDetailState extends State<TaskTypeDetail>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: 2,
      vsync: this,
    );
  }

  @override
  void dispose() {
    tabController.dispose();
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
                widget.taskTypeName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.white,
                ),
              ),
            ],
          ),
          bottom: TabBar(
            controller: tabController,
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
                text: "Task Type Status",
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            SubTaskList(taskTypeID: widget.taskTypeID),
            TaskTypeStatusList(taskTypeID: widget.taskTypeID),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          isExtended: true,
          onPressed: () {
            switch (tabController.index) {
              case 0:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddSubTask(
                      taskTypeID: widget.taskTypeID,
                      subTaskID: "",
                      subTaskName: "",
                    ),
                  ),
                );
                break;
              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTaskTypeStatus(
                      taskTypeID: widget.taskTypeID,
                      taskTypeStatusID: "",
                      taskTypeStatusName: "",
                    ),
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
