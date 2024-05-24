import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/components/button.dart';
import 'package:ppmt/components/snackbar.dart';
import 'package:ppmt/constants/color.dart';

class ProjectSkillPage extends StatefulWidget {
  final Map<String, dynamic> projectData;

  ProjectSkillPage({Key? key, required this.projectData}) : super(key: key);

  @override
  _ProjectSkillPageState createState() => _ProjectSkillPageState();
}

class _ProjectSkillPageState extends State<ProjectSkillPage> {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  Map<String, bool> selectedSkills = {};
  List<String> selectedSkillIDs = [];

  bool isTeamLead = false;

  @override
  void initState() {
    super.initState();
    checkUserRole();
    fetchSelectedSkills();
  }

  Future<void> checkUserRole() async {
    try {
      String? currentUserID = FirebaseAuth.instance.currentUser?.uid;
      DocumentSnapshot userSnapshot =
          await firebaseFirestore.collection('users').doc(currentUserID).get();

      if (userSnapshot.exists) {
        setState(() {
          isTeamLead =
              userSnapshot['userID'] == widget.projectData["teamLeadID"];
        });
      }
    } catch (e) {
      print('Error checking user role: $e');
    }
  }

  Future<void> fetchSelectedSkills() async {
    try {
      QuerySnapshot existingSkillsSnapshot = await firebaseFirestore
          .collection('projects')
          .doc(widget.projectData["projectID"])
          .collection('skills')
          .limit(1)
          .get();

      if (existingSkillsSnapshot.docs.isNotEmpty) {
        DocumentSnapshot existingDoc = existingSkillsSnapshot.docs.first;
        Map<String, dynamic> data = existingDoc.data() as Map<String, dynamic>;
        List<dynamic> skillIDs = data['selectedSkillIDs'];
        setState(() {
          selectedSkillIDs.addAll(skillIDs.map((id) => id.toString()));
          selectedSkillIDs.forEach((id) {
            selectedSkills[id] = true;
          });
        });
      }
    } catch (e) {
      print('Error fetching selected skills: $e');
    }
  }

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

          return SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: sortedDocs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = sortedDocs[index];
                    Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;
                    String skillID = data['skillID'];
                    String skillName = data['skillName'];

                    return Card(
                      margin: EdgeInsets.all(10),
                      child: CheckboxListTile(
                        title: Text(skillName),
                        value: selectedSkills[skillID] ?? false,
                        onChanged: isTeamLead
                            ? (bool? value) {
                                setState(() {
                                  selectedSkills[skillID] = value ?? false;
                                  if (value == true) {
                                    selectedSkillIDs.add(skillID);
                                  } else {
                                    selectedSkillIDs.remove(skillID);
                                  }
                                });
                              }
                            : null, // Disable editing for non-lead users
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
                if (isTeamLead) ...[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: button(
                      onPressed: saveSelectedSkills,
                      buttonName: "Save",
                      backgroundColor: CupertinoColors.black,
                      textColor: CupertinoColors.white,
                    ),
                  ),
                ],
                SizedBox(height: 20), // Add some space after the button
              ],
            ),
          );
        },
      ),
    );
  }

  void saveSelectedSkills() async {
    try {
      QuerySnapshot existingSkillsSnapshot = await firebaseFirestore
          .collection('projects')
          .doc(widget.projectData["projectID"])
          .collection('skills')
          .limit(1)
          .get();

      if (existingSkillsSnapshot.docs.isNotEmpty) {
        DocumentSnapshot existingDoc = existingSkillsSnapshot.docs.first;
        await existingDoc.reference.update({
          'selectedSkillIDs': selectedSkillIDs,
        });
      } else {
        await firebaseFirestore
            .collection('projects')
            .doc(widget.projectData["projectID"])
            .collection('skills')
            .add({
          'selectedSkillIDs': selectedSkillIDs,
        });
      }

      showSnackBar(context: context, message: "Skills saved successfully");
    } catch (e) {
      showSnackBar(context: context, message: 'Failed to save skills: $e');
    }
  }
}
