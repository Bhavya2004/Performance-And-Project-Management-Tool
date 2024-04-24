import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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

        // If the user already has this skill and level combination, update it
        if (userSkillLevel.docs.isNotEmpty) {
          userSkillLevel.docs.forEach((doc) async {
            await _firestore.collection('userSkillsLevels').doc(doc.id).update({
              'levelName': _selectedLevel,
            });
          });
        } else {
          // If the user doesn't have this skill and level combination, add it
          await _firestore.collection('userSkillsLevels').add({
            'userId': widget.userId,
            'skillName': _selectedSkill,
            'levelName': _selectedLevel,
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

  void _showSkillPicker() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 220,
          color: CupertinoColors.white,
          child: Column(
            children: [
              Container(
                color: CupertinoColors.lightBackgroundGray,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: "SF-Pro",
                        ),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    CupertinoButton(
                      onPressed: () {
                        setState(() {
                          _selectedSkill = _skills[_selectedSkillIndex];
                        });
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Done',
                        style: TextStyle(
                          fontFamily: "SF-Pro",
                        ),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker.builder(
                  itemExtent: 32.0,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      _selectedSkillIndex = index;
                    });
                  },
                  childCount: _skills.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Center(
                      child: Text(_skills[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int _selectedSkillIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Skill and Level'),
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: _showSkillPicker,
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedSkill ?? 'Select Skill',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
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
            onPressed: assignSkillAndLevel,
            buttonName: 'Assign Skill and Level',
          ),
        ],
      ),
    );
  }
}
