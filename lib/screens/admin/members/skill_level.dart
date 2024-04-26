import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SkillLevel extends StatefulWidget {
  final String? UserID;
  final String? UserName;

  SkillLevel({Key? key, this.UserID, this.UserName}) : super(key: key);

  @override
  State<SkillLevel> createState() => _SkillLevelState();
}

class _SkillLevelState extends State<SkillLevel> {
  List<DocumentSnapshot> _userSkillsLevels = [];

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Skill - Level",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Row(
              children: [
                Text(
                  widget.UserName.toString(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
              ],
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
                if (_userSkillsLevels.isEmpty) {
                  return ListTile(
                    title: Text('No data available'),
                  );
                }

                // Fetch the data for the current index
                var data = _userSkillsLevels[index].data();

                // Check if data is null or not a Map<String, dynamic>
                if (data == null || data is! Map<String, dynamic>) {
                  return ListTile(
                    title: Text('Invalid data format at index $index'),
                  );
                }

                // Access 'skill' and 'level' fields from data
                var skill = data['skillName'] as String?;
                var level = data['levelName'] as String?;

                // Check if skill or level is null
                if (skill == null || level == null) {
                  return ListTile(
                    title: Text('Missing skill or level at index $index'),
                  );
                }

                // Display the ListTile with skill and level
                return ListTile(
                  title: Text(skill),
                  subtitle: Text(level),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
