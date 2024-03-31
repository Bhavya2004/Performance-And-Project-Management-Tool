import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/screens/admin/master/skill/add_skill.dart';

class SkillListPage extends StatelessWidget {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  SkillListPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Skills"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firebaseFirestore.collection('skills').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          var activeItems = snapshot.data!.docs
              .where((doc) => doc['isDisabled'] != true)
              .toList();
          var disabledItems = snapshot.data!.docs
              .where((doc) => doc['isDisabled'] == true)
              .toList();

          ListTile buildTile(DocumentSnapshot document, bool isDisabled) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return ListTile(
              tileColor: isDisabled ? Colors.grey : null,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(data['skillName']),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: isDisabled
                            ? null
                            : () async {
                                String skillName = data['skillName'];
                                String skillID = document.id;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddSkill(
                                      skillName: skillName,
                                      skillID: skillID,
                                    ),
                                  ),
                                );
                              },
                        child: Icon(Icons.edit),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: isDisabled
                            ? null
                            : () async {
                                await firebaseFirestore
                                    .collection('skills')
                                    .doc(document.id)
                                    .update({'isDisabled': true});
                              },
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          return ListView(
            children: activeItems.map((doc) => buildTile(doc, false)).toList() +
                disabledItems.map((doc) => buildTile(doc, true)).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text("Add Skill"),
        icon: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).pushNamed('/add_skill');
        },
      ),
    );
  }
}
