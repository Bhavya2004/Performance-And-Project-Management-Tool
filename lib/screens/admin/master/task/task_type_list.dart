import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:ppmt/constants/color.dart";
import "package:ppmt/screens/admin/master/task/add_task_type.dart";
import "package:ppmt/screens/admin/master/task/task_type_detail.dart";

class TaskTypeList extends StatefulWidget {
  const TaskTypeList({Key? key}) : super(key: key);

  @override
  State<TaskTypeList> createState() => _TaskTypeListState();
}

class _TaskTypeListState extends State<TaskTypeList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("taskType")
            .orderBy("taskTypeName")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CupertinoActivityIndicator(
                color: kAppBarColor,
              ),
            );
          }

          List<DocumentSnapshot> sortedDocs = snapshot.data!.docs.toList();

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
      color: data["isDisabled"] == true ? Colors.grey[400] : null,
      margin: EdgeInsets.all(10),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              child: Text(
                data["taskTypeName"],
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: data["isDisabled"]
                      ? SizedBox()
                      : Icon(
                          CupertinoIcons.pencil,
                          color: kEditColor,
                        ),
                  onPressed: data["isDisabled"]
                      ? null
                      : () async {
                          String taskTypeName = data["taskTypeName"];
                          String taskTypeID = data["taskTypeID"];
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddTaskType(
                                taskTypeID: taskTypeID,
                                taskTypeName: taskTypeName,
                              ),
                            ),
                          );
                        },
                ),
                IconButton(
                  icon: data["isDisabled"]
                      ? SizedBox()
                      : Icon(
                          CupertinoIcons.info_circle_fill,
                          color: kAppBarColor,
                        ),
                  onPressed: data["isDisabled"]
                      ? null
                      : () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TaskTypeDetail(
                                taskTypeID: data["taskTypeID"],
                                taskTypeName: data["taskTypeName"],
                              ),
                            ),
                          );
                        },
                ),
                IconButton(
                  icon: data["isDisabled"]
                      ? Icon(
                          Icons.visibility_off,
                          color: kDeleteColor,
                        )
                      : Icon(
                          Icons.visibility,
                          color: kAppBarColor,
                        ),
                  onPressed: () => updateTaskTypeStatus(
                      taskTypeID: data["taskTypeID"].toString()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateTaskTypeStatus({required String taskTypeID}) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("taskType")
          .where("taskTypeID", isEqualTo: taskTypeID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final taskTypeSnapshot = querySnapshot.docs.first;
        final taskTypeData = taskTypeSnapshot.data() as Map<String, dynamic>?;

        if (taskTypeData != null) {
          await taskTypeSnapshot.reference
              .update({"isDisabled": !(taskTypeData["isDisabled"] ?? false)});
        } else {
          throw ("Document data is null or empty");
        }
      } else {
        throw ("Skill with ID $taskTypeID not found.");
      }
    } catch (e) {
      throw ("Error updating task type details: $e");
    }
  }
}
