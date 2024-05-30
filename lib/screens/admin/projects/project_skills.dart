import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/screens/admin/projects/add_project_skills.dart';
import 'package:ppmt/components/snackbar.dart';

class ProjectSkillPage extends StatefulWidget {
  final Map<String, dynamic> projectData;

  ProjectSkillPage({Key? key, required this.projectData}) : super(key: key);

  @override
  State<ProjectSkillPage> createState() => _ProjectSkillPageState();
}

class _ProjectSkillPageState extends State<ProjectSkillPage> {
  bool isTeamLead = false;

  @override
  void initState() {
    super.initState();
    checkUserRole();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('projects')
            .doc(widget.projectData["projectID"])
            .collection("skills")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CupertinoActivityIndicator(
                color: kAppBarColor,
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text('No data available'),
            );
          }

          List<String> skillIDs = [];
          snapshot.data!.docs.forEach((doc) {
            List<String> selectedSkillIDs =
                List<String>.from(doc['selectedSkillIDs']);
            skillIDs.addAll(selectedSkillIDs);
          });

          return FutureBuilder<List<Map<String, String>>>(
            future: fetchSkillNames(skillIDs),
            builder: (context, skillsSnapshot) {
              if (skillsSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CupertinoActivityIndicator(
                    color: kAppBarColor,
                  ),
                );
              }

              if (skillsSnapshot.hasError) {
                return Center(
                  child: Text('Error: ${skillsSnapshot.error}'),
                );
              }

              if (!skillsSnapshot.hasData || skillsSnapshot.data == null) {
                return Center(
                  child: Text('No skills available'),
                );
              }

              List<Map<String, String>> skills = skillsSnapshot.data!;

              return ListView.builder(
                itemCount: skills.length,
                itemBuilder: (context, index) {
                  String skillName = skills[index]['skillName']!;
                  String skillID = skills[index]['skillID']!;

                  return Card(
                    margin: EdgeInsets.all(10),
                    elevation: 5,
                    child: ListTile(
                      title: Text(skillName),
                      leading: Icon(Icons.star, color: kAppBarColor),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: isTeamLead
          ? FloatingActionButton(
              onPressed: () async {
                List<String> skillIDs = await fetchExistingSkillIDs();
                String? result =
                    await Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return AddProjectSkillPage(
                      projectData: widget.projectData,
                      existingSkillIDs: skillIDs,
                    );
                  },
                ));

                if (result != null && result.isNotEmpty) {
                  showSnackBar(context: context, message: result);
                }
              },
              child: Icon(Icons.edit),
            )
          : null,
    );
  }

  Future<List<Map<String, String>>> fetchSkillNames(
      List<String> skillIDs) async {
    List<Map<String, String>> skills = [];

    try {
      for (String skillID in skillIDs) {
        QuerySnapshot skillSnapshot = await FirebaseFirestore.instance
            .collection('skills')
            .where('skillID', isEqualTo: skillID)
            .where('isDisabled', isEqualTo: false)
            .get();

        if (skillSnapshot.docs.isNotEmpty) {
          Map<String, dynamic> skillData =
              skillSnapshot.docs.first.data() as Map<String, dynamic>;
          String skillName = skillData['skillName'];
          skills.add({'skillID': skillID, 'skillName': skillName});
        } else {
          print('Skill with ID $skillID does not exist.');
        }
      }
    } catch (e) {
      print('Error fetching skill names: $e');
    }

    return skills;
  }

  Future<List<String>> fetchExistingSkillIDs() async {
    List<String> skillIDs = [];
    try {
      QuerySnapshot existingSkillsSnapshot = await FirebaseFirestore.instance
          .collection('projects')
          .doc(widget.projectData["projectID"])
          .collection('skills')
          .get();

      if (existingSkillsSnapshot.docs.isNotEmpty) {
        for (var doc in existingSkillsSnapshot.docs) {
          List<String> selectedSkillIDs =
              List<String>.from(doc['selectedSkillIDs']);
          skillIDs.addAll(selectedSkillIDs);
        }
      }
    } catch (e) {
      print('Error fetching existing skill IDs: $e');
    }
    return skillIDs;
  }

  Future<void> checkUserRole() async {
    try {
      String? currentUserID = FirebaseAuth.instance.currentUser?.uid;
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserID)
          .get();

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
}
