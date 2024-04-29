import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ppmt/constants/color.dart';

class ComplexityListPage extends StatelessWidget {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  ComplexityListPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: AppColor.white,
        ),
        backgroundColor: AppColor.sanMarino,
        title: Text(
          "Complexity Levels",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColor.white,
          ),
        ),
      ),
      body: StreamBuilder(
        stream: firebaseFirestore.collection('complexity').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          var complexityItems = snapshot.data!.docs;

          Widget buildTile(DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            Color tileColor = Colors.green;

            switch (data['complexityName']) {
              case 'High':
                tileColor = Colors.red;
                break;
              case 'Medium':
                tileColor = Colors.yellow;
                break;
              case 'Low':
                tileColor = Colors.green;
                break;
              default:
                tileColor = Colors.grey;
            }

            return Card(
              color: tileColor,
              margin: EdgeInsets.all(10),
              child: ListTile(
                title: Text(
                  data['complexityName'],
                  style: TextStyle(
                    color: AppColor.black,
                  ),
                ),
              ),
            );
          }

          return ListView(
            children: complexityItems.map((doc) => buildTile(doc)).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text(
          "Add Complexity",
          style: TextStyle(
            color: AppColor.black,
          ),
        ),
        icon: Icon(
          CupertinoIcons.add,
          color: AppColor.black,
        ),
        onPressed: () {
          Navigator.of(context).pushNamed('/add_complexity');
        },
      ),
    );
  }
}
