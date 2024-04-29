import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/screens/admin/master/skill/add_skill.dart';

class SkillListPage extends StatelessWidget {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  SkillListPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: AppColor.white,
        ),
        backgroundColor: AppColor.sanMarino,
        title: Text(
          "Skills",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColor.white,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firebaseFirestore.collection('skills').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
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
          "Add Skill",
          style: TextStyle(
            color: AppColor.black,
          ),
        ),
        icon: Icon(
          Icons.add,
          color: AppColor.black,
        ),
        onPressed: () {
          Navigator.of(context).pushNamed('/add_skill');
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
              child: Text(
                data['skillName'],
              ),
            ),
            IconButton(
              icon: data['isDisabled']
                  ? Icon(Icons.visibility_off)
                  : Icon(Icons.visibility),
              onPressed: () async {
                await firebaseFirestore
                    .collection('skills')
                    .doc(document.id)
                    .update({'isDisabled': !data['isDisabled']});
              },
            ),
          ],
        ),
      ),
    );
  }
}
