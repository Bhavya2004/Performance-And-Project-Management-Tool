import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/screens/user/skill_level/add_skill_level.dart';

class SkillLevelList extends StatefulWidget {
  final String userID;

  SkillLevelList({Key? key, required this.userID}) : super(key: key);

  @override
  State<SkillLevelList> createState() => _SkillLevelState();
}

class _SkillLevelState extends State<SkillLevelList> {
  @override
  void initState() {
    super.initState();
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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('userSkillsLevels')
            .where('userID', isEqualTo: widget.userID)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CupertinoActivityIndicator(
                color: kAppBarColor,
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              var document = snapshot.data!.docs[index];
              return FutureBuilder<Map<String, dynamic>>(
                future: fetchSkillAndLevelData(
                    skillID: document["skillID"], levelID: document["levelID"]),
                builder: (context, skillSnapshot) {
                  if (skillSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return SizedBox();
                  }

                  if (!skillSnapshot.hasData) {
                    return Container();
                  }

                  var data = skillSnapshot.data!;
                  var skillName = data['skillName'];
                  var levelName = data['levelName'];

                  return Card(
                    child: ListTile(
                      tileColor:
                          document["isDisabled"] ? Colors.grey[400] : null,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                skillName ?? 'Missing skill',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                levelName ?? 'Missing level',
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 13),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: document['isDisabled']
                                    ? SizedBox()
                                    : Icon(
                                        CupertinoIcons.pencil,
                                        color: kEditColor,
                                      ),
                                onPressed: document['isDisabled']
                                    ? null
                                    : () async {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AssignSkillLevel(
                                              userSkillsLevelsID: document[
                                                  "userSkillsLevelsID"],
                                              userID: widget.userID,
                                              selectedSkill: skillName,
                                              selectedLevel: levelName,
                                            ),
                                          ),
                                        );
                                      },
                              ),
                              IconButton(
                                icon: document['isDisabled']
                                    ? Icon(
                                        Icons.visibility_off,
                                        color: kDeleteColor,
                                      )
                                    : Icon(
                                        Icons.visibility,
                                        color: kAppBarColor,
                                      ),
                                onPressed: () async {
                                  updateUserStatus(userID: widget.userID);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        isExtended: true,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AssignSkillLevel(
                userSkillsLevelsID: "",
                userID: widget.userID,
              ),
            ),
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

  Future<Map<String, dynamic>> fetchSkillData({required String skillID}) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('skills')
          .where('skillID', isEqualTo: skillID)
          .where('isDisabled', isEqualTo: false)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final skillSnapshot = querySnapshot.docs.first;
        final skillData = skillSnapshot.data() as Map<String, dynamic>?;

        if (skillData != null) {
          return skillData;
        } else {
          throw ('Document data is null or empty');
        }
      } else {
        throw ('Skill with ID $skillID not found.');
      }
    } catch (e) {
      throw ('Error updating skill details: $e');
    }
  }

  Future<Map<String, dynamic>> fetchSkillAndLevelData(
      {required String skillID, required String levelID}) async {
    Map<String, dynamic>? skillData;
    Map<String, dynamic>? levelData;
    try {
      final skillQuerySnapshot = await FirebaseFirestore.instance
          .collection('skills')
          .where('skillID', isEqualTo: skillID)
          .where('isDisabled', isEqualTo: false)
          .get();

      if (skillQuerySnapshot.docs.isNotEmpty) {
        final skillSnapshot = skillQuerySnapshot.docs.first;
        skillData = skillSnapshot.data() as Map<String, dynamic>?;
      }

      final levelQuerySnapshot = await FirebaseFirestore.instance
          .collection('levels')
          .where('levelID', isEqualTo: levelID)
          .get();

      if (levelQuerySnapshot.docs.isNotEmpty) {
        final levelSnapshot = levelQuerySnapshot.docs.first;
        levelData = levelSnapshot.data() as Map<String, dynamic>?;
      }

      if (skillData != null && levelData != null) {
        return {
          'skillName': skillData['skillName'],
          'levelName': levelData['levelName'],
        };
      } else {
        throw ('Skill or level data not found.');
      }
    } catch (e) {
      throw ('Error fetching skill and level data: $e');
    }
  }

  Future<void> updateUserStatus({required String userID}) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('userSkillsLevels')
          .where('userID', isEqualTo: widget.userID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userSnapShot = querySnapshot.docs.first;
        final userData = userSnapShot.data() as Map<String, dynamic>?;

        if (userData != null) {
          await userSnapShot.reference
              .update({'isDisabled': !(userData['isDisabled'] ?? false)});
        } else {
          throw ('Document data is null or empty');
        }
      } else {
        throw ('Skill with ID $userID not found.');
      }
    } catch (e) {
      throw ('Error updating user details: $e');
    }
  }
}
