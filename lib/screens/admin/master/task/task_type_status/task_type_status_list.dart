import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/screens/admin/master/task/task_type_status/add_task_type_status.dart';

class TaskTypeStatusList extends StatefulWidget {
  final String taskTypeID;

  TaskTypeStatusList({required this.taskTypeID, Key? key}) : super(key: key);

  @override
  _TaskTypeStatusListState createState() => _TaskTypeStatusListState();
}

class _TaskTypeStatusListState extends State<TaskTypeStatusList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('taskTypeStatus')
            .where(
              'taskTypeID',
              isEqualTo: widget.taskTypeID,
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CupertinoActivityIndicator(
                color: kAppBarColor,
              ),
            );
          }

          List<DocumentSnapshot> sortedDocs = snapshot.data!.docs.toList()
            ..sort((a, b) {
              bool aDisabled = a['isDisabled'] ?? false;
              bool bDisabled = b['isDisabled'] ?? false;
              if (aDisabled && !bDisabled) {
                return 1;
              } else if (!aDisabled && bDisabled) {
                return -1;
              } else {
                return 0;
              }
            });

          final taskStatuses = snapshot.data!.docs;
          return ListView.builder(
            itemCount: sortedDocs.length,
            itemBuilder: (context, index) {
              final taskStatus = taskStatuses[index];
              final colorString = taskStatus['taskTypeStatusColor'] as String?;
              final color = colorString != null
                  ? Color(int.parse(colorString, radix: 16))
                  : Colors.transparent;
              final statusTypeID = taskStatus['taskTypeStatusName'] as String?;
              final isEditable =
                  statusTypeID != 'To Do' && statusTypeID != 'Done';
              final textColor =
                  color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
              DocumentSnapshot doc = sortedDocs[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return buildCard(
                  context, doc, data, isEditable, textColor, color);
            },
          );
        },
      ),
    );
  }

  Widget buildCard(
      BuildContext context,
      DocumentSnapshot document,
      Map<String, dynamic> data,
      bool isEditable,
      Color textColor,
      Color color) {
    final String statusTypeID = data['taskTypeStatusName'];
    final bool isToDoOrDone = statusTypeID == 'To Do' || statusTypeID == 'Done';
    final bool isDisabled = data['isDisabled'] ?? false;
    final bool canEdit = !isToDoOrDone;

    return Card(
      color: isDisabled
          ? Colors.grey[400]
          : canEdit
              ? color
              : color,
      margin: EdgeInsets.all(10),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              data['taskTypeStatusName'],
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            canEdit
                ? Row(
                    children: [
                      IconButton(
                        icon: isDisabled
                            ? SizedBox()
                            : Icon(
                                CupertinoIcons.pencil,
                                color: kEditColor,
                              ),
                        onPressed: isDisabled
                            ? null
                            : () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddTaskTypeStatus(
                                      taskTypeID: widget.taskTypeID,
                                      taskTypeStatusID:
                                          data["taskTypeStatusID"],
                                      taskTypeStatusName:
                                          data["taskTypeStatusName"],
                                      taskTypeStatusColor:
                                          data["taskTypeStatusColor"],
                                    ),
                                  ),
                                );
                              },
                      ),
                      IconButton(
                        icon: isDisabled
                            ? Icon(
                                Icons.visibility_off,
                                color: kDeleteColor,
                              )
                            : Icon(
                                Icons.visibility,
                                color: kAppBarColor,
                              ),
                        onPressed: () async {
                          updateTaskTypeStatus(
                              taskTypeStatusID:
                                  data["taskTypeStatusID"].toString());
                        },
                      ),
                    ],
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  Future<void> updateTaskTypeStatus({required String taskTypeStatusID}) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("taskTypeStatus")
          .where("taskTypeStatusID", isEqualTo: taskTypeStatusID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final taskTypeStatusSnapshot = querySnapshot.docs.first;
        final taskTypeStatusData =
            taskTypeStatusSnapshot.data() as Map<String, dynamic>?;

        if (taskTypeStatusData != null) {
          await taskTypeStatusSnapshot.reference.update(
              {"isDisabled": !(taskTypeStatusData["isDisabled"] ?? false)});
        } else {
          throw ("Document data is null or empty");
        }
      } else {
        throw ("Skill with ID $taskTypeStatusID not found.");
      }
    } catch (e) {
      throw ("Error updating task type details: $e");
    }
  }
}
