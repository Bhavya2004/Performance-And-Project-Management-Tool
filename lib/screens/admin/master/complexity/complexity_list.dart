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
      body: StreamBuilder(
        stream: firebaseFirestore.collection('complexity').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CupertinoActivityIndicator(
                color: kAppBarColor,
              ),
            );
          }

          var complexityItems = snapshot.data!.docs;

          Widget buildTile(DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            Color tileColor = CupertinoColors.lightBackgroundGray;

            switch (data['complexityName']) {
              case 'High':
                tileColor = CupertinoColors.destructiveRed;
                break;
              case 'Medium':
                tileColor = CupertinoColors.systemYellow;
                break;
              case 'Low':
                tileColor = CupertinoColors.activeGreen;
                break;
              default:
                tileColor = CupertinoColors.lightBackgroundGray;
            }

            return Card(
              color: tileColor,
              margin: EdgeInsets.all(10),
              child: ListTile(
                title: Text(
                  data['complexityName'],
                  style: TextStyle(
                    color: CupertinoColors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
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
    );
  }
}
