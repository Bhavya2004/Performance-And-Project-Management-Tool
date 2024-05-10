import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/screens/admin/master/task/sub_task/add_subtask.dart';

class SubTaskList extends StatefulWidget {
  final String taskTypeID;

  SubTaskList({required this.taskTypeID, Key? key}) : super(key: key);

  @override
  _SubTaskListState createState() => _SubTaskListState();
}

class _SubTaskListState extends State<SubTaskList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('subTask')
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
                                taskTypeID: widget.taskTypeID,
                                subTaskID: data['subTaskID'],
                                subTaskName: data['subTaskName'],
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
                    updateSubTaskStatus(
                        subTaskID: data["subTaskID"].toString());
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateSubTaskStatus({required String subTaskID}) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("subTask")
          .where("subTaskID", isEqualTo: subTaskID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final subTaskSnapshot = querySnapshot.docs.first;
        final subTaskData = subTaskSnapshot.data() as Map<String, dynamic>?;

        if (subTaskData != null) {
          await subTaskSnapshot.reference
              .update({"isDisabled": !(subTaskData["isDisabled"] ?? false)});
        } else {
          throw ("Document data is null or empty");
        }
      } else {
        throw ("Skill with ID $subTaskID not found.");
      }
    } catch (e) {
      throw ("Error updating Sub Task details: $e");
    }
  }
}
