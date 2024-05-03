import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/screens/admin/members/add_skill_level.dart';

class SkillLevel extends StatefulWidget {
  final String? userID;
  final String? userName;

  SkillLevel({Key? key, this.userID, this.userName}) : super(key: key);

  @override
  State<SkillLevel> createState() => _SkillLevelState();
}

class _SkillLevelState extends State<SkillLevel> {
  late List<DocumentSnapshot> _userSkillsLevels;

  @override
  void initState() {
    super.initState();
    _userSkillsLevels = [];
    if (widget.userID != null && widget.userID!.isNotEmpty) {
      fetchUserSkillsLevels();
    }
  }

  Future<void> fetchUserSkillsLevels() async {
    try {
      QuerySnapshot userSkillsLevelsSnapshot = await FirebaseFirestore.instance
          .collection('userSkillsLevels')
          .where('userId', isEqualTo: widget.userID)
          .where('isDisabled', isEqualTo: false)
          .get();
      setState(() {
        _userSkillsLevels = userSkillsLevelsSnapshot.docs;
      });
    } catch (e) {
      print(e.toString());
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Skill - Level",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.white,
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              widget.userName ?? "",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.white,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: _userSkillsLevels.map((doc) {
            var data = doc.data();
            if (data == null || !(data is Map<String, dynamic>)) {
              return ListTile(
                title: Text('Invalid data format'),
              );
            }
            var skill = data['skillName'] as String?;
            var level = data['levelName'] as String?;
            if (skill == null || level == null) {
              return ListTile(
                title: Text('Missing skill or level'),
              );
            }
            return Card(
              margin: EdgeInsets.all(10),
              child: ListTile(
                title: Text(skill),
                subtitle: Text(level),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
