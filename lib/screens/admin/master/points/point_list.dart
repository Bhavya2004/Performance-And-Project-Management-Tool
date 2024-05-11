import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ppmt/components/snackbar.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/screens/admin/master/points/add_point.dart';

class PointList extends StatefulWidget {
  const PointList({Key? key}) : super(key: key);

  @override
  State<PointList> createState() => _PointListState();
}

class _PointListState extends State<PointList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('points').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CupertinoActivityIndicator(
                color: kAppBarColor,
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              var document = snapshot.data!.docs[index];
              Map<String, dynamic> pointsData = document["points"];
              List<DataColumn> columns = buildColumns(pointsData);
              List<DataRow> rows = [];
              buildRows(pointsData, rows);

              return FutureBuilder<Map<String, dynamic>>(
                future: fetchSkillData(skillID: document["skillID"]),
                builder: (context, skillSnapshot) {
                  if (skillSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return SizedBox();
                  }

                  if (!skillSnapshot.hasData) {
                    return Container();
                  }

                  var skillData = skillSnapshot.data!;
                  var skillName = skillData['skillName'];

                  return ExpansionTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$skillName',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => deleteRecord(document.id),
                        ),
                      ],
                    ),
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddPoint(
                                  document: document,
                                  pointsID: document["pointsID"],
                                ),
                              ),
                            );
                          },
                          child: DataTable(
                            sortAscending: true,
                            columnSpacing: 30,
                            border: TableBorder.all(),
                            columns: columns,
                            rows: rows,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void deleteRecord(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('points')
          .doc(documentId)
          .delete();
      showSnackBar(context: context, message: "Record Deleted Successfully");
    } catch (e) {
      showSnackBar(context: context, message: "Failed to Delete Record");
    }
  }

  Future<Map<String, dynamic>> fetchSkillData({required String skillID}) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('skills')
          .where('skillID', isEqualTo: skillID)
          .where('isDisabled', isEqualTo: false)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final skillSnapshot = querySnapshot.docs.first;
        final skillData = skillSnapshot.data() as Map<String, dynamic>?;

        if (skillData != null) {
          return skillData;
        } else {
          throw ('Document data is null or empty');
        }
      } else {
        throw ('Skill with ID $skillID not found.');
      }
    } catch (e) {
      throw ('Error updating skill details: $e');
    }
  }

  List<DataColumn> buildColumns(Map<String, dynamic> pointsData) {
    var complexityNames = pointsData.entries.first.value.keys.toList();
    List<DataColumn> columns = [
      DataColumn(
        label: Text(
          'Task Type',
        ),
      ),
      for (var complexityName in complexityNames)
        DataColumn(
          label: Text(
            complexityName,
          ),
        ),
    ];
    return columns;
  }

  void buildRows(Map<String, dynamic> pointsData, List<DataRow> rows) {
    for (var entry in pointsData.entries) {
      var taskTypeID = entry.key;
      gettaskTypeName(taskTypeID).then((taskTypeName) {
        if (taskTypeName != null) {
          List<DataCell> cells = [
            DataCell(Text(taskTypeName)),
            for (var subEntry in entry.value.entries)
              DataCell(Text('${subEntry.value}')),
          ];
          rows.add(DataRow(cells: cells));
        }
      }).catchError((error) {});
    }
  }

  Future<String?> gettaskTypeName(String taskTypeID) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('taskType')
          .where('taskTypeID', isEqualTo: taskTypeID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final taskTypeSnapShot = querySnapshot.docs.first;
        final taskTypeData = taskTypeSnapShot.data() as Map<String, dynamic>?;

        if (taskTypeData != null && !taskTypeData["isDisabled"]) {
          return taskTypeData["taskTypeName"];
        } else {
          throw ('taskType with ID $taskTypeID is disabled or not found.');
        }
      } else {
        throw ('taskType with ID $taskTypeID not found.');
      }
    } catch (e) {
      throw ('Error fetching taskType details: $e');
    }
  }
}
