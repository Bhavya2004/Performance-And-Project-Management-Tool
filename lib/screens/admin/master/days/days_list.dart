import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ppmt/components/snackbar.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/screens/admin/master/days/add_days.dart';

class DaysList extends StatefulWidget {
  const DaysList({Key? key}) : super(key: key);

  @override
  State<DaysList> createState() => _DaysListState();
}

class _DaysListState extends State<DaysList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _firestore.collection('days').snapshots(),
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
                            builder: (context) => AddDays(document: document),
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
      await _firestore.collection('days').doc(documentId).delete();
      showSnackBar(context: context, message: "Record Deleted Successfully");
    } catch (e) {
      showSnackBar(context: context, message: "Failed to Delete Record");
    }
  }

}
