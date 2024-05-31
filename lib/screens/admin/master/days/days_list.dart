import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/components/snackbar.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/screens/admin/master/days/add_days.dart';

class DaysList extends StatefulWidget {
  const DaysList({Key? key}) : super(key: key);

  @override
  State<DaysList> createState() => _DaysListState();
}


class _DaysListState extends State<DaysList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('days').snapshots(),
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
              Map<String, dynamic> daysData = document["days"];
              List<DataColumn> columns = buildColumns(daysData);
              List<DataRow> rows = [];
              buildRows(daysData, rows);

              return FutureBuilder<Map<String, dynamic>>(
                future: fetchSkillData(skillID: document["skillID"]),
                builder: (context, skillSnapshot) {
                  if (skillSnapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(); // Return an empty SizedBox if no skill data found
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
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddDays(
                                      document: document,
                                      daysID: document["daysID"],
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => deleteRecord(document.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          sortAscending: true,
                          columnSpacing: 30,
                          border: TableBorder.all(),
                          columns: columns,
                          rows: rows,
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
          .collection('days')
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

  List<DataColumn> buildColumns(Map<String, dynamic> daysData) {
    var complexityNames = daysData.entries.first.value.keys.toList();
    List<DataColumn> columns = [
      DataColumn(
        label: Text(
          'Levels',
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

  void buildRows(Map<String, dynamic> daysData, List<DataRow> rows) {
    for (var entry in daysData.entries) {
      var levelID = entry.key;
      getLevelName(levelID).then((levelName) {
        if (levelName != null) {
          List<DataCell> cells = [
            DataCell(Text(levelName)),
            for (var subEntry in entry.value.entries)
              DataCell(Text('${subEntry.value}')),
          ];
          rows.add(DataRow(cells: cells));
        }
      }).catchError((error) {});
    }
  }

  Future<String?> getLevelName(String levelID) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('levels')
          .where('levelID', isEqualTo: levelID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final levelSnapShot = querySnapshot.docs.first;
        final levelData = levelSnapShot.data() as Map<String, dynamic>?;

        if (levelData != null && !levelData["isDisabled"]) {
          return levelData["levelName"];
        } else {
          throw ('Level with ID $levelID is disabled or not found.');
        }
      } else {
        throw ('Level with ID $levelID not found.');
      }
    } catch (e) {
      throw ('Error fetching level details: $e');
    }
  }
}
