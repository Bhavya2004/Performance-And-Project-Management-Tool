import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
        title: Text("Sub Task"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('subtasks')
            .where('taskId',
                isEqualTo: widget.taskId) // Filter subtasks by taskId
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final subTasks = snapshot.data!.docs;
            return ListView.builder(
              itemCount: subTasks.length,
              itemBuilder: (context, index) {
                final subTask = subTasks[index];
                return ListTile(
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
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text("Add Sub Task"),
        icon: Icon(Icons.add),
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
