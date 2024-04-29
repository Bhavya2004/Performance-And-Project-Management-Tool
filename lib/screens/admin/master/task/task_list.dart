import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/screens/admin/master/subtask/subtask_list.dart';
import 'package:ppmt/screens/admin/master/task/add_task.dart';

class TaskList extends StatefulWidget {
  const TaskList({Key? key}) : super(key: key);

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: AppColor.white,
        ),
        backgroundColor: AppColor.sanMarino,
        title: Text(
          "Task",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColor.white,
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          } else {
            final tasks = snapshot.data!.docs;
            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final Map<String, dynamic> taskStatus =
                    Map<String, dynamic>.from(
                  task['taskStatus'],
                );
                final List<String> trueStatuses = taskStatus.entries
                    .where((entry) => entry.value == true)
                    .map((entry) => entry.key)
                    .toList();

                return Card(
                  margin: EdgeInsets.all(
                    10,
                  ),
                  child: ListTile(
                    title: Text(
                      task['taskName'],
                      style: TextStyle(
                        color: AppColor.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      trueStatuses.join(
                        ", ",
                      ),
                      style: TextStyle(
                        color: AppColor.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubTaskList(
                            taskId: task.id,
                          ),
                        ),
                      );
                    },
                    onLongPress: () {
                      showActivitySheet(context, task);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text(
          "Add Task",
          style: TextStyle(
            color: AppColor.black,
          ),
        ),
        icon: Icon(
          Icons.add,
          color: AppColor.black,
        ),
        onPressed: () {
          Navigator.of(context).pushNamed('/add_task');
        },
      ),
    );
  }

  void showActivitySheet(BuildContext context, DocumentSnapshot task) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTask(
                    taskId: task.id,
                    taskName: task['taskName'],
                    taskStatus: task['taskStatus'],
                    isEditMode: true,
                  ),
                ),
              ).then(
                (value) {
                  if (value == true) {
                    setState(() {});
                  }
                },
              ).then(
                (value) {
                  Navigator.pop(context);
                },
              );
            },
            child: Text(
              "Edit",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: CupertinoColors.activeGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
