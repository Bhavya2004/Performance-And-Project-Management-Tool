import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ppmt/components/snackbar.dart';

class AssignSkillLevel extends StatefulWidget {
  final String userId;

  AssignSkillLevel({required this.userId});

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
    // Check if the combination already exists
    QuerySnapshot existingRecords = await _firestore
        .collection('userSkillsLevels')
        .where('userId', isEqualTo: widget.userId)
        .where('skillName', isEqualTo: _selectedSkill)
        .where('levelName', isEqualTo: _selectedLevel)
        .get();

    // If any existing records are found, show an error message
    if (existingRecords.docs.isNotEmpty) {
      print("exist");
      showSnackBar(
        message: 'Skill and level combination already exists for this user',
        context: context,
      );
    } else {
      // If the combination doesn't exist, add the new record
      // Add the new record
      await _firestore.collection('userSkillsLevels').add({
        'userId': widget.userId,
        'skillName': _selectedSkill,
        'levelName': _selectedLevel,
      });

      Navigator.pop(context); // Navigate back to the Users screen

      // Show a snackbar
      showSnackBar(
        message: 'Skill and level assigned successfully',
        context: context,
      );
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
            DropdownButtonFormField(
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
            ElevatedButton(
              onPressed: _selectedSkill != null && _selectedLevel != null
                  ? assignSkillAndLevel
                  : null,
              child: Text('Assign Skill and Level'),
            ),
          ],
        ),
      ),
    );
  }
}
