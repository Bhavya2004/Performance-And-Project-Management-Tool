import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/screens/admin/master/level/add_level.dart';

class LevelListPage extends StatelessWidget {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  LevelListPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: AppColor.white,
        ),
        backgroundColor: AppColor.sanMarino,
        title: Text(
          "Levels",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColor.white,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firebaseFirestore.collection('levels').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
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
      floatingActionButton: FloatingActionButton.extended(
        label: Text(
          "Add Level",
          style: TextStyle(
            color: AppColor.black,
          ),
        ),
        icon: Icon(
          CupertinoIcons.add,
          color: AppColor.black,
        ),
        onPressed: () {
          Navigator.of(context).pushNamed('/add_level');
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
              onTap: data['isDisabled']
                  ? null
                  : () async {
                      String levelName = data['levelName'];
                      String levelID = data['levelID'];
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddLevel(
                            levelName: levelName,
                            levelID: levelID,
                          ),
                        ),
                      );
                    },
              child: Text(
                data['levelName'],
              ),
            ),
            IconButton(
              icon: data['isDisabled']
                  ? Icon(Icons.visibility_off)
                  : Icon(Icons.visibility),
              onPressed: () async {
                await firebaseFirestore
                    .collection('levels')
                    .doc(document.id)
                    .update({
                  'isDisabled': data['isDisabled'] == true ? false : true,
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
