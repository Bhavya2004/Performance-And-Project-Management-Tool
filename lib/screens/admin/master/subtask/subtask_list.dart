import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/screens/admin/master/subtask/add_subtask.dart';

class SubTaskList extends StatefulWidget {
  final String taskId;

  const SubTaskList({required this.taskId, Key? key}) : super(key: key);

  @override
  _SubTaskListState createState() => _SubTaskListState();
}

class _SubTaskListState extends State<SubTaskList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: AppColor.white,
        ),
        backgroundColor: AppColor.sanMarino,
        title: Text(
          "Sub Task",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColor.white,
          ),
        ),
      ),
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
            return const CircularProgressIndicator();
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
                    title: Text(subTask['subTaskName']),
                    onTap: () {
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
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text(
          "Add Sub Task",
          style: TextStyle(
            color: AppColor.black,
          ),
        ),
        icon: Icon(
          Icons.add,
          color: AppColor.black,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddSubTask(taskId: widget.taskId),
            ),
          );
        },
      ),
    );
  }
}
