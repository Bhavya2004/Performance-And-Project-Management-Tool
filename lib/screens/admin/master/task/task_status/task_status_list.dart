import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/screens/admin/master/task/subtask/add_subtask.dart';
import 'package:ppmt/screens/admin/master/task/task_status/add_task_status.dart';

class TaskStatusList extends StatefulWidget {
  final String taskId;

  TaskStatusList({required this.taskId, Key? key}) : super(key: key);

  @override
  _TaskStatusListState createState() => _TaskStatusListState();
}

class _TaskStatusListState extends State<TaskStatusList> {
  @override
  Widget build(BuildContext context) {
    print(widget.taskId);
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('taskStatus')
            .where(
          'taskID',
          isEqualTo: widget.taskId,
        )
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CupertinoActivityIndicator(
                color: kAppBarColor,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          } else {
            final taskStatuses = snapshot.data!.docs;
            return ListView.builder(
              itemCount: taskStatuses.length,
              itemBuilder: (context, index) {
                final taskStatus = taskStatuses[index];
                print(taskStatus.data());
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          taskStatus['taskStatusName'],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            CupertinoIcons.pencil,
                            color: kEditColor,
                          ),
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddTaskStatus(
                                  taskId: widget.taskId,
                                  taskStatusID: taskStatus["taskStatusID"],
                                  taskStatusName: taskStatus["taskStatusName"],
                                  isEditMode: true,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
