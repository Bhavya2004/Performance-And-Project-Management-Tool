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
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: firebaseFirestore
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

          return ListView.builder(
            itemCount: sortedDocs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = sortedDocs[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return buildCard(context, doc, data);
            },
          );
        },
      ),
    );
  }

  Widget buildCard(BuildContext context, DocumentSnapshot document,
      Map<String, dynamic> data) {
    return Card(
      color: data['isDisabled'] == true ? Colors.grey[400] : null,
      margin: EdgeInsets.all(10),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              child: Text(
                data['subTaskName'],
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: data['isDisabled']
                      ? SizedBox()
                      : Icon(
                    CupertinoIcons.pencil,
                    color: kEditColor,
                  ),
                  onPressed: data['isDisabled']
                      ? null
                      : () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddSubTask(
                          taskId: widget.taskId,
                          subTaskID: document.id,
                          subTaskName: data['subTaskName'],
                          isEditMode: true,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: data['isDisabled']
                      ? Icon(
                    Icons.visibility_off,
                    color: kDeleteColor,
                  )
                      : Icon(
                    Icons.visibility,
                    color: kAppBarColor,
                  ),
                  onPressed: () async {
                    await firebaseFirestore
                        .collection('subtasks')
                        .doc(document.id)
                        .update({'isDisabled': !data['isDisabled']});
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
