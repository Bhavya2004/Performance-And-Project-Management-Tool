import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/constants/color.dart';

class ProjectSkillPage extends StatefulWidget {
  @override
  _ProjectSkillPageState createState() => _ProjectSkillPageState();
}

class _ProjectSkillPageState extends State<ProjectSkillPage> {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  Map<String, bool> selectedSkills = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: firebaseFirestore.collection('skills').orderBy('skillName').snapshots(),
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
              String skillID = data['skillID'];
              String skillName = data['skillName'];

              return Card(
                margin: EdgeInsets.all(10),
                child: CheckboxListTile(
                  title: Text(skillName),
                  value: selectedSkills[skillID] ?? false,
                  onChanged: (bool? value) {
                    setState(() {
                      selectedSkills[skillID] = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
