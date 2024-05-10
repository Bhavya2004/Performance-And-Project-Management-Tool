import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ppmt/components/button.dart';
import 'package:ppmt/components/snackbar.dart';
import 'package:ppmt/constants/color.dart';

class AssignSkillLevel extends StatefulWidget {
  final String userId;
  final String? selectedSkill;
  final String? selectedLevel;

  AssignSkillLevel({
    required this.userId,
    this.selectedSkill,
    this.selectedLevel,
  });

  @override
  _AssignSkillLevelState createState() => _AssignSkillLevelState();
}

class _AssignSkillLevelState extends State<AssignSkillLevel> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _skills = [];
  List<String> _levels = [];
  String? _selectedSkill;
  String? _selectedLevel;

  @override
  void initState() {
    super.initState();
    fetchSkillsAndLevels();
    _selectedSkill = widget.selectedSkill;
    _selectedLevel = widget.selectedLevel;
  }

  void fetchSkillsAndLevels() async {
    QuerySnapshot skillsSnapshot = await _firestore
        .collection('skills')
        .where('isDisabled', isEqualTo: false)
        .get();
    _skills = skillsSnapshot.docs
        .map((doc) => doc['skillName'])
        .toList()
        .cast<String>();

    QuerySnapshot levelsSnapshot = await _firestore
        .collection('levels')
        .where('isDisabled', isEqualTo: false)
        .get();
    _levels = levelsSnapshot.docs
        .map((doc) => doc['levelName'])
        .toList()
        .cast<String>();

    setState(() {});
  }

  void assignSkillAndLevel() async {
    if (_selectedSkill != null && _selectedLevel != null) {
      // Check if the combination already exists
      QuerySnapshot existingRecords = await _firestore
          .collection('userSkillsLevels')
          .where('userId', isEqualTo: widget.userId)
          .where('skillName', isEqualTo: _selectedSkill)
          .where('levelName', isEqualTo: _selectedLevel)
          .get();

      if (existingRecords.docs.isNotEmpty) {
        showSnackBar(
          message: 'Skill and level combination already exists for this user',
          context: context,
        );
      } else {
        QuerySnapshot userSkillLevel = await _firestore
            .collection('userSkillsLevels')
            .where('userId', isEqualTo: widget.userId)
            .where('skillName', isEqualTo: _selectedSkill)
            .get();

        if (userSkillLevel.docs.isNotEmpty) {
          String documentId = userSkillLevel.docs.first.id;
          try {
            await _firestore
                .collection('userSkillsLevels')
                .doc(documentId)
                .update({
              'levelName': _selectedLevel,
            });
            print('Record updated successfully');
          } catch (e) {
            print('Error updating record: $e');
          }
        } else {
          print('Adding new record');
          await _firestore.collection('userSkillsLevels').add({
            'userId': widget.userId,
            'skillName': _selectedSkill,
            'levelName': _selectedLevel,
            'isDisabled': false,
          });
        }

        Navigator.pop(context);
        showSnackBar(
          message: 'Skill and level assigned successfully',
          context: context,
        );
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
                items: _skills.map((skill) {
                  return DropdownMenuItem(
                    value: skill,
                    child: Text(skill),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSkill = value as String?;
                  });
                },
                value: _selectedSkill,
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
                  ..._levels.map((level) {
                    return RadioListTile(
                      activeColor: kAppBarColor,
                      title: Text(level),
                      value: level,
                      groupValue: _selectedLevel,
                      onChanged: (value) {
                        setState(() {
                          _selectedLevel = value;
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
            button(
              onPressed: _selectedSkill != null && _selectedLevel != null
                  ? assignSkillAndLevel
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
