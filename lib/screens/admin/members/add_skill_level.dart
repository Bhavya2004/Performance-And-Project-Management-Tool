import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ppmt/components/button.dart';
import 'package:ppmt/components/snackbar.dart';

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
    // Fetch skills
    QuerySnapshot skillsSnapshot = await _firestore
        .collection('skills')
        .where('isDisabled', isEqualTo: false)
        .get();
    _skills = skillsSnapshot.docs
        .map((doc) => doc['skillName'])
        .toList()
        .cast<String>();

    // Fetch levels
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

      // Log query parameters and results
      print('userId: ${widget.userId}');
      print('_selectedSkill: $_selectedSkill');
      print('_selectedLevel: $_selectedLevel');
      print('existingRecords.docs.length: ${existingRecords.docs.length}');

      // If any existing records are found, show an error message
      if (existingRecords.docs.isNotEmpty) {
        showSnackBar(
          message: 'Skill and level combination already exists for this user',
          context: context,
        );
      } else {
        // If the combination doesn't exist, check if it's an update or add operation
        // Check if the user already has this skill and level combination
        QuerySnapshot userSkillLevel = await _firestore
            .collection('userSkillsLevels')
            .where('userId', isEqualTo: widget.userId)
            .where('skillName', isEqualTo: _selectedSkill)
            .get();

        // Log query parameters and results
        print('userSkillLevel.docs.length: ${userSkillLevel.docs.length}');

        // If the user already has this skill and level combination, update it
        if (userSkillLevel.docs.isNotEmpty) {
          // Get the document ID of the first matching record
          String documentId = userSkillLevel.docs.first.id;
          try {
            // Update the specific record using its document ID
            await _firestore.collection('userSkillsLevels').doc(documentId).update({
              'levelName': _selectedLevel,
            });
            print('Record updated successfully');
          } catch (e) {
            print('Error updating record: $e');
          }
        }
        else {
          // If the user doesn't have this skill and level combination, add it
          print('Adding new record');
          await _firestore.collection('userSkillsLevels').add({
            'userId': widget.userId,
            'skillName': _selectedSkill,
            'levelName': _selectedLevel,
            'isDisabled': false,
          });
        }

        Navigator.pop(context); // Navigate back to the Users screen

        // Show a snackbar
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
        title: Text('Assign Skill and Level'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              child: DropdownButtonFormField(
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
                ),
              ),
            ),
            ..._levels.map((level) {
              return RadioListTile(
                title: Text(level),
                value: level,
                groupValue: _selectedLevel,
                onChanged: (value) {
                  setState(() {
                    _selectedLevel = value as String?;
                  });
                },
              );
            }).toList(),
            button(
              onPressed: _selectedSkill != null && _selectedLevel != null
                  ? assignSkillAndLevel
                  : null,
              buttonName: 'Assign Skill and Level',
            ),
          ],
        ),
      ),
    );
  }
}
