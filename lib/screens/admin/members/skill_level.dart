import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ppmt/constants/color.dart';

class SkillLevel extends StatefulWidget {
  final String? userID;
  final String? userName;

  SkillLevel({Key? key, this.userID, this.userName}) : super(key: key);

  @override
  State<SkillLevel> createState() => _SkillLevelState();
}

class _SkillLevelState extends State<SkillLevel> {
  List<DocumentSnapshot> _userSkillsLevels = [];

  @override
  void initState() {
    super.initState();
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
    } catch (e) {}
  }

  Card buildTile(DocumentSnapshot document, bool isDisabled) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    var skill = data['skillName'] as String?;
    var level = data['levelName'] as String?;

    return Card(
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skill ?? 'Missing skill',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  level ?? 'Missing level',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
          children: [
            ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: _userSkillsLevels.length,
              itemBuilder: (context, index) {
                return buildTile(
                    _userSkillsLevels[index], true);
              },
            ),
          ],
        ),
      ),
    );
  }
}
