import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ppmt/components/snackbar.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/screens/admin/master/days/add_days.dart';
import 'package:ppmt/screens/admin/master/points/add_point.dart';

class PointList extends StatefulWidget {
  const PointList({Key? key}) : super(key: key);

  @override
  State<PointList> createState() => _PointListState();
}

class _PointListState extends State<PointList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _firestore.collection('points').snapshots(),
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
              print(document.data());
              Map<String, dynamic> daysData = document["points"];

              var complexityNames = daysData.entries.first.value.keys.toList();

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

              List<DataRow> rows = [];
              for (var entry in daysData.entries) {
                List<DataCell> cells = [
                  DataCell(
                    Text(
                      entry.key,
                    ),
                  ),
                  for (var subEntry in entry.value.entries)
                    DataCell(
                      Text(
                        '${subEntry.value}',
                      ),
                    ),
                ];
                rows.add(
                  DataRow(
                    cells: cells,
                  ),
                );
              }
              return ExpansionTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${document["skillName"]}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteRecord(document.id),
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
                            builder: (context) => AddPoint(document: document),
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
      ),
    );
  }

  void _deleteRecord(String documentId) async {
    try {
      await _firestore.collection('points').doc(documentId).delete();
      showSnackBar(context: context, message: "Record Deleted Successfully");
    } catch (e) {
      print("Error deleting record: $e");
      showSnackBar(context: context, message: "Failed to Delete Record");
    }
  }

}
