import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ppmt/screens/admin/members/add_skill_level.dart';

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
    print("Received UserID: ${widget.UserID}");
    if (widget.UserID != null && widget.UserID!.isNotEmpty) {
      fetchUserSkillsLevels();
    } else {
      print("UserID is empty or null");
    }
  }

  Future<void> fetchUserSkillsLevels() async {
    try {
      QuerySnapshot userSkillsLevelsSnapshot = await FirebaseFirestore.instance
          .collection('userSkillsLevels')
          .where('userId', isEqualTo: widget.UserID)
          .get();
      print(widget.UserID);
      print(userSkillsLevelsSnapshot.docs.first.data());
      setState(() {
        _userSkillsLevels = userSkillsLevelsSnapshot.docs;
      });
    } catch (e) {
      print('Error fetching userSkillsLevels data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.UserID!.isEmpty) {
      // If UserID is not provided, display a message or handle it according to your app logic
      return Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              Text("Skill - Level"),
            ],
          ),
        ),
        body: Center(
          child: Text("UserID is empty"),
        ),
      );
    } else {
      // If UserID is provided, build the SkillLevel screen with the fetched data
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
                  // Check if _userSkillsLevels is empty
                  if (_userSkillsLevels.isEmpty) {
                    return ListTile(
                      title: Text('No data available'),
                    );
                  }

                  // Check if index is out of bounds
                  if (index >= _userSkillsLevels.length) {
                    return ListTile(
                      title: Text('Index out of bounds'),
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // Navigating to AssignSkillLevel screen with userId argument
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AssignSkillLevel(userId: widget.UserID!),
              ),
            ).then(
              (value) {
                setState(() {

                });
                fetchUserSkillsLevels();
              },
            );
          },
          label: Text(
            "Add Skill/Level",
          ),
        ),
      );
    }
  }
}
