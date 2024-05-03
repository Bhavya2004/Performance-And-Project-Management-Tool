import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/screens/admin/master/task/subtask/add_subtask.dart';

class SubTaskList extends StatefulWidget {
  final String taskId;

  SubTaskList({required this.taskId, Key? key}) : super(key: key);

  @override
  _SubTaskListState createState() => _SubTaskListState();
}

class _SubTaskListState extends State<SubTaskList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('subtasks')
            .where(
              'taskId',
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
            final subTasks = snapshot.data!.docs;
            return ListView.builder(
              itemCount: subTasks.length,
              itemBuilder: (context, index) {
                final subTask = subTasks[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          subTask['subTaskName'],
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
                                builder: (context) => AddSubTask(
                                  taskId: widget.taskId,
                                  subTaskID: subTask.id,
                                  subTaskName: subTask['subTaskName'],
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
