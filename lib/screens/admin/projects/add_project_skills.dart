import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/components/button.dart';
import 'package:ppmt/components/snackbar.dart';
import 'package:ppmt/constants/color.dart';

class AddProjectSkillPage extends StatefulWidget {
  final Map<String, dynamic> projectData;
  final List<String> existingSkillIDs;

  AddProjectSkillPage(
      {Key? key, required this.projectData, required this.existingSkillIDs})
      : super(key: key);

  @override
  _AddProjectSkillPageState createState() => _AddProjectSkillPageState();
}

class _AddProjectSkillPageState extends State<AddProjectSkillPage> {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  Map<String, bool> selectedSkills = {};
  List<String> selectedSkillIDs = [];

  @override
  void initState() {
    super.initState();
    initializeSelectedSkills();
  }

  void initializeSelectedSkills() {
    setState(() {
      for (String skillID in widget.existingSkillIDs) {
        selectedSkills[skillID] = true;
        selectedSkillIDs.add(skillID);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: CupertinoColors.white,
        ),
        title: Text(
          'Select Skills',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
        backgroundColor: kAppBarColor,
      ),
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
                            if (value == true) {
                              selectedSkillIDs.add(skillID);
                            } else {
                              selectedSkillIDs.remove(skillID);
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: button(
                    onPressed: saveSelectedSkills,
                    buttonName: "Save",
                    backgroundColor: CupertinoColors.black,
                    textColor: CupertinoColors.white,
                  ),
                ),
                SizedBox(height: 20),
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

      Navigator.pop(context);
      showSnackBar(context: context, message: "Skills saved successfully");
    } catch (e) {
      Navigator.pop(context);
      showSnackBar(context: context, message: "Failed to save skills: $e");
    }
  }
}
