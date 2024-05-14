import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/components/button.dart';
import 'package:ppmt/components/snackbar.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/constants/generate_id.dart';

class AssignSkillLevel extends StatefulWidget {
  final String userID;
  final String userSkillsLevelsID;
  final String? selectedSkill;
  final String? selectedLevel;

  AssignSkillLevel({
    required this.userID,
    this.selectedSkill,
    this.selectedLevel,
    required this.userSkillsLevelsID,
  });

  @override
  _AssignSkillLevelState createState() => _AssignSkillLevelState();
}

class _AssignSkillLevelState extends State<AssignSkillLevel> {
  Map<String, String> skills = {};
  Map<String, String> levels = {};
  String? selectedSkill;
  String? selectedLevel;

  @override
  void initState() {
    super.initState();
    fetchSkillsAndLevels();
    selectedSkill = widget.selectedSkill;
    selectedLevel = widget.selectedLevel;
  }

  void fetchSkillsAndLevels() async {
    QuerySnapshot skillsSnapshot = await FirebaseFirestore.instance
        .collection('skills')
        .where('isDisabled', isEqualTo: false)
        .get();
    skills = Map.fromEntries(skillsSnapshot.docs
        .map((doc) => MapEntry(doc['skillName'], doc['skillID'])));

    QuerySnapshot levelsSnapshot = await FirebaseFirestore.instance
        .collection('levels')
        .where('isDisabled', isEqualTo: false)
        .get();
    levels = Map.fromEntries(levelsSnapshot.docs
        .map((doc) => MapEntry(doc['levelName'], doc['levelID'])));

    setState(() {});
  }

  Future<void> addSkillAndLevel() async {
    int lastUserSkillsLevelsID = await getLastID(
        collectionName: "userSkillsLevels", primaryKey: "userSkillsLevelsID");
    int newUserSkillsLevelsID = lastUserSkillsLevelsID + 1;
    await FirebaseFirestore.instance.collection('userSkillsLevels').add({
      "userSkillsLevelsID": newUserSkillsLevelsID.toString(),
      'userID': widget.userID,
      'skillID': skills[selectedSkill!],
      'levelID': levels[selectedLevel!],
      'isDisabled': false,
    });
  }

  Future<void> updateSkillAndLevel() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('userSkillsLevels')
          .where('userSkillsLevelsID', isEqualTo: widget.userSkillsLevelsID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userSkillsLevelsSnapshot = querySnapshot.docs.first;
        final userSkillsLevelsData =
            userSkillsLevelsSnapshot.data() as Map<String, dynamic>?;

        if (userSkillsLevelsData != null) {
          await userSkillsLevelsSnapshot.reference.update({
            'levelID': levels[selectedLevel!],
          });
        } else {
          throw ('Document data is null or empty');
        }
      } else {
        throw ('Skill - Level with ID ${widget.userSkillsLevelsID} not found.');
      }
    } catch (e) {
      throw ('Error updating Skill - level details: $e');
    }
  }

  void submit() async {
    if (selectedSkill != null && selectedLevel != null) {
      QuerySnapshot existingRecords = await FirebaseFirestore.instance
          .collection('userSkillsLevels')
          .where('userID', isEqualTo: widget.userID)
          .where('skillID', isEqualTo: skills[selectedSkill!])
          .where('levelID', isEqualTo: levels[selectedLevel!])
          .get();

      if (existingRecords.docs.isNotEmpty) {
        showSnackBar(
          message: 'Skill and level combination already exists for this user',
          context: context,
        );
      } else {
        try {
          if (widget.userSkillsLevelsID != "") {
            await updateSkillAndLevel();
            showSnackBar(
                context: context,
                message: "Skill - Level Updated Successfully");
          } else {
            await addSkillAndLevel();
            showSnackBar(
                context: context,
                message: "Skill - Level Updated Successfully");
          }
          Navigator.of(context).pop();
        } catch (e) {
          showSnackBar(context: context, message: "Error: $e");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: CupertinoColors.white,
        ),
        backgroundColor: kAppBarColor,
        title: Text(
          'Assign Skill and Level',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              child: DropdownButtonFormField(
                style: TextStyle(color: kAppBarColor),
                items: skills.keys.map((skill) {
                  return DropdownMenuItem(
                    value: skill,
                    child: Text(skill),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSkill = value as String?;
                  });
                },
                value: selectedSkill,
                decoration: InputDecoration(
                  labelText: 'Skill',
                  labelStyle: TextStyle(
                    color: kAppBarColor,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select Level",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  ...levels.keys.map((level) {
                    return RadioListTile(
                      activeColor: kAppBarColor,
                      title: Text(level),
                      value: level,
                      groupValue: selectedLevel,
                      onChanged: (value) {
                        setState(() {
                          selectedLevel = value;
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
            button(
              onPressed: selectedSkill != null && selectedLevel != null
                  ? submit
                  : null,
              buttonName: 'Assign Skill and Level',
              backgroundColor: CupertinoColors.black,
              textColor: CupertinoColors.white,
            ),
          ],
        ),
      ),
    );
  }
}
