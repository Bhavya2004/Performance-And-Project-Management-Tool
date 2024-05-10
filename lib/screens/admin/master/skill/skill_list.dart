import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/screens/admin/master/skill/add_skill.dart';

class SkillListPage extends StatelessWidget {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  SkillListPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: firebaseFirestore
            .collection('skills')
            .orderBy('skillName')
            .snapshots(),
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
              return buildCard(context, doc, data);
            },
          );
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
              child: Text(
                data['skillName'],
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: data['isDisabled']
                      ? SizedBox()
                      : Icon(
                          CupertinoIcons.pencil,
                          color: kEditColor,
                        ),
                  onPressed: data['isDisabled']
                      ? null
                      : () async {
                          String skillName = data['skillName'];
                          String skillID = data['skillID'];
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
                ),
                IconButton(
                  icon: data['isDisabled']
                      ? Icon(
                          Icons.visibility_off,
                          color: kDeleteColor,
                        )
                      : Icon(
                          Icons.visibility,
                          color: kAppBarColor,
                        ),
                  onPressed: () =>
                      updateSkillStatus(skillID: data["skillID"].toString()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateSkillStatus({required String skillID}) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('skills')
          .where('skillID', isEqualTo: skillID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final skillSnapshot = querySnapshot.docs.first;
        final skillData = skillSnapshot.data() as Map<String, dynamic>?;

        if (skillData != null) {
          await skillSnapshot.reference
              .update({'isDisabled': !(skillData['isDisabled'] ?? false)});
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
}
