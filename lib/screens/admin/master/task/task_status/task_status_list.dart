import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ppmt/constants/color.dart';
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
                final colorString = taskStatus['taskStatusColor'] as String?;
                final color = colorString != null
                    ? Color(int.parse(colorString, radix: 16))
                    : Colors.transparent;
                final statusTypeID = taskStatus['taskStatusName'] as String?;
                final isEditable = statusTypeID != 'To Do' && statusTypeID != 'Done';
                final textColor = color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
                return Card(
                  color: color,
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
                            color: textColor
                          ),
                        ),
                        isEditable ? IconButton(
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
                                  taskStatusColor: taskStatus["taskStatusColor"],
                                  isEditMode: true,
                                ),
                              ),
                            );
                          },
                        ) : SizedBox(), // If not editable, show an empty SizedBox instead of the edit icon
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
