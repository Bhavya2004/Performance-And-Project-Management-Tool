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
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: firebaseFirestore
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
              final colorString = taskStatus['taskStatusColor'] as String?;
              final color = colorString != null
                  ? Color(int.parse(colorString, radix: 16))
                  : Colors.transparent;
              final statusTypeID = taskStatus['taskStatusName'] as String?;
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
    final String statusTypeID = data['taskStatusName'];
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
              data['taskStatusName'],
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
                              builder: (context) => AddTaskStatus(
                                taskId: widget.taskId,
                                taskStatusID: data["taskStatusID"],
                                taskStatusName: data["taskStatusName"],
                                taskStatusColor: data["taskStatusColor"],
                                isEditMode: true,
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
                          if (!isToDoOrDone) {
                            await firebaseFirestore
                                .collection('taskStatus')
                                .doc(document.id)
                                .update({'isDisabled': !isDisabled});
                          } else if (isDisabled) {
                            // Enable the status if it's "To Do" or "Done" and currently disabled
                            await firebaseFirestore
                                .collection('taskStatus')
                                .doc(document.id)
                                .update({'isDisabled': false});
                          }
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
}
