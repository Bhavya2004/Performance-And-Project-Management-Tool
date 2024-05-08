import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ppmt/components/button.dart';
import 'package:ppmt/components/snackbar.dart';
import 'package:ppmt/constants/color.dart';

class AddPoint extends StatefulWidget {
  final QueryDocumentSnapshot<Object?>? document;

  const AddPoint({Key? key, this.document}) : super(key: key);

  @override
  State<AddPoint> createState() => _AddPointState();
}

class _AddPointState extends State<AddPoint> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> complexityList = [];
  List<Map<String, dynamic>> taskTypeList = [];
  List<List<TextEditingController>> controllersList = [];
  List<String> skills = [];
  String? selectedSkill;

  @override
  void initState() {
    super.initState();
    fetchComplexity();
    fetchTaskType();
    fetchSkills();
  }

  void fetchComplexity() async {
    QuerySnapshot complexitySnapshot =
    await _firestore.collection('complexity').get();

    setState(() {
      complexityList = complexitySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
    initializeControllers();
  }

  void resetControllers() {
    for (List<TextEditingController> controllers in controllersList) {
      for (TextEditingController controller in controllers) {
        controller.text = '0';
      }
    }
  }

  void fetchSkills() async {
    QuerySnapshot skillsSnapshot = await _firestore
        .collection('skills')
        .where('isDisabled', isEqualTo: false)
        .get();
    skills = skillsSnapshot.docs
        .map((doc) => doc['skillName'])
        .toList()
        .cast<String>();

    setState(() {
    });
  }

  void fetchTaskType() async {
    QuerySnapshot levelsSnapshot = await _firestore.collection('tasks').get();

    setState(() {
      taskTypeList = levelsSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
    initializeControllers();
  }

  void initializeControllers() {
    controllersList.clear();
    for (int i = 0; i < taskTypeList.length; i++) {
      List<TextEditingController> controllers = [];
      for (int j = 0; j < complexityList.length; j++) {
        controllers.add(TextEditingController());
      }
      controllersList.add(controllers);
    }

    if (widget.document != null) {
      selectedSkill = widget.document!['skillName'] as String?;
      Map<String, dynamic>? pointsData =
      widget.document!['points'] as Map<String, dynamic>?;

      if (pointsData != null) {
        for (int i = 0; i < taskTypeList.length; i++) {
          Map<String, dynamic>? levelData =
          pointsData[taskTypeList[i]['taskName']] as Map<String, dynamic>?;

          if (levelData != null) {
            for (int j = 0; j < complexityList.length; j++) {
              String complexityName =
              complexityList[j]['complexityName'] as String;
              int points = levelData[complexityName] as int? ?? 0;
              controllersList[i][j].text = points.toString();
            }
          }
        }
      }
    }
  }

  void addOrUpdatePoints() async {
    if (selectedSkill == null) {
      showSnackBar(context: context, message: "Please select a skill first!");
      return;
    }

    // Check if the selected skill already exists in the database
    QuerySnapshot skillSnapshot = await _firestore
        .collection('points')
        .where('skillName', isEqualTo: selectedSkill)
        .get();

    if (widget.document == null && skillSnapshot.docs.isNotEmpty) {
      showSnackBar(
        context: context,
        message: "Skill '$selectedSkill' already exists!",
      );
      return;
    }

    Map<String, dynamic> pointsData = {};

    for (int i = 0; i < taskTypeList.length; i++) {
      Map<String, dynamic> levelData = {};

      for (int j = 0; j < complexityList.length; j++) {
        int points = int.tryParse(controllersList[i][j].text) ?? 0;
        levelData[complexityList[j]['complexityName'] as String] = points;
      }

      pointsData[taskTypeList[i]['taskName'] as String] = levelData;
    }

    if (widget.document != null) {
      await _firestore.collection('points').doc(widget.document!.id).update({
        'skillName': selectedSkill,
        'points': pointsData,
      });
      showSnackBar(
          context: context, message: "Points Calculation Updated Successfully");
    } else {
      await _firestore.collection('points').add({
        'skillName': selectedSkill,
        'points': pointsData,
      });
      showSnackBar(
          context: context, message: "Points Calculation Added Successfully");
    }

    Navigator.pop(context);
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
          widget.document != null ? 'Edit Points' : 'Add Points',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: EdgeInsets.all(10),
              child: DropdownButtonFormField(
                style: TextStyle(color: kAppBarColor),
                items: skills.map((skill) {
                  return DropdownMenuItem(
                    value: skill,
                    child: Text(skill),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSkill = value as String?;
                    resetControllers();
                  });
                },
                value: selectedSkill,
                decoration: InputDecoration(
                  labelText: 'Skill',
                  labelStyle: TextStyle(
                    color: kAppBarColor,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Table(
              border: TableBorder.all(),
              children: [
                TableRow(
                  children: [
                    TableCell(
                      child: Center(),
                    ),
                    for (var complexity in complexityList)
                      TableCell(
                        child: Center(
                          child: Text(
                            complexity['complexityName'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                for (int i = 0; i < taskTypeList.length; i++)
                  TableRow(
                    children: [
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            taskTypeList[i]['taskName'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      for (int j = 0; j < complexityList.length; j++)
                        TableCell(
                          child: TextField(
                            controller: controllersList[i][j],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            SizedBox(height: 16.0),
            button(
              backgroundColor: CupertinoColors.black,
              buttonName: widget.document != null ? 'Update Points' : 'Add Points',
              textColor: CupertinoColors.white,
              onPressed: addOrUpdatePoints,
            ),
          ],
        ),
      ),
    );
  }
}
