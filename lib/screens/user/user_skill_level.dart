import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/screens/admin/members/add_skill_level.dart';

class UserSkillLevel extends StatefulWidget {
  final String? UserID;

  UserSkillLevel({Key? key, this.UserID}) : super(key: key);

  @override
  State<UserSkillLevel> createState() => _SkillLevelState();
}

class _SkillLevelState extends State<UserSkillLevel> {
  List<DocumentSnapshot> _userSkillsLevels = [];
  List<DocumentSnapshot> _disabledUserSkillsLevels = [];

  @override
  void initState() {
    super.initState();
    if (widget.UserID != null && widget.UserID!.isNotEmpty) {
      fetchUserSkillsLevels();
    }
  }

  Future<void> fetchUserSkillsLevels() async {
    try {
      QuerySnapshot userSkillsLevelsSnapshot = await FirebaseFirestore.instance
          .collection('userSkillsLevels')
          .where('userId', isEqualTo: widget.UserID)
          .get();
      setState(() {
        _userSkillsLevels = userSkillsLevelsSnapshot.docs
            .where((doc) => doc['isDisabled'] != true)
            .toList();
        _disabledUserSkillsLevels = userSkillsLevelsSnapshot.docs
            .where((doc) => doc['isDisabled'] == true)
            .toList();
      });
    } catch (e) {}
  }

  Card buildTile(DocumentSnapshot document, bool isDisabled) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    var skill = data['skillName'] as String?;
    var level = data['levelName'] as String?;

    return Card(
      child: ListTile(
        tileColor: isDisabled ? Colors.grey[400] : null,
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
            Row(
              children: [
                IconButton(
                  icon: data['isDisabled']
                      ? SizedBox()
                      : Icon(
                          CupertinoIcons.pencil,
                          color: kEditColor,
                        ),
                  onPressed: data['isDisabled']
                      ? null
                      : () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AssignSkillLevel(
                                userId: widget.UserID!,
                                selectedSkill: skill,
                                selectedLevel: level,
                              ),
                            ),
                          ).then((value) {
                            fetchUserSkillsLevels();
                          });
                        },
                ),
                IconButton(
                  icon: isDisabled
                      ? Icon(
                          Icons.visibility_off,
                          color: kDeleteColor,
                        )
                      : Icon(
                          Icons.visibility,
                          color: kAppBarColor,
                        ),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('userSkillsLevels')
                        .doc(document.id)
                        .update({'isDisabled': !isDisabled});
                    fetchUserSkillsLevels();
                  },
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
        title: Text(
          "Skill - Level",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount:
                  _userSkillsLevels.length + _disabledUserSkillsLevels.length,
              itemBuilder: (context, index) {
                if (index < _userSkillsLevels.length) {
                  return buildTile(_userSkillsLevels[index], false);
                } else {
                  return buildTile(
                      _disabledUserSkillsLevels[
                          index - _userSkillsLevels.length],
                      true);
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        isExtended: true,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AssignSkillLevel(userId: widget.UserID!),
            ),
          ).then(
            (value) {
              fetchUserSkillsLevels();
            },
          );
        },
        backgroundColor: Colors.orange.shade700,
        child: Icon(
          Icons.add,
          color: Colors.orange.shade100,
        ),
      ),
    );
  }
}
