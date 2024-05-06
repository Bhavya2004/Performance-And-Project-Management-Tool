import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ppmt/components/button.dart';
import 'package:ppmt/constants/color.dart';

class AddDays extends StatefulWidget {
  AddDays({Key? key}) : super(key: key);

  @override
  State<AddDays> createState() => _AddDaysState();
}

class _AddDaysState extends State<AddDays> {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> complexityList = [];
  List<Map<String, dynamic>> levelsList = [];
  List<List<TextEditingController>> controllersList = [];
  List<String> skills = [];
  String? selectedSkill;

  @override
  void initState() {
    super.initState();
    fetchComplexity();
    fetchLevels();
    fetchSkills();
  }

  void fetchSkills() async {
    QuerySnapshot skillsSnapshot = await firebaseFirestore
        .collection('skills')
        .where('isDisabled', isEqualTo: false)
        .get();
    skills = skillsSnapshot.docs
        .map((doc) => doc['skillName'])
        .toList()
        .cast<String>();

    setState(() {});
  }

  Future<void> fetchComplexity() async {
    QuerySnapshot complexitySnapshot =
        await firebaseFirestore.collection('complexity').get();

    setState(() {
      complexityList = complexitySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
    initializeControllers();
  }

  Future<void> fetchLevels() async {
    QuerySnapshot levelsSnapshot =
        await firebaseFirestore.collection('levels').get();

    setState(() {
      levelsList = levelsSnapshot.docs
          .where((doc) => doc['isDisabled'] == false)
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
    initializeControllers();
  }

  void initializeControllers() {
    controllersList.clear();
    for (int i = 0; i < levelsList.length; i++) {
      List<TextEditingController> controllers = [];
      for (int j = 0; j < complexityList.length; j++) {
        controllers.add(TextEditingController());
      }
      controllersList.add(controllers);
    }
  }

  void addDaysToDatabase() async {
    if (selectedSkill == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a skill first!'),
        ),
      );
      return;
    }
    for (int i = 0; i < levelsList.length; i++) {
      for (int j = 0; j < complexityList.length; j++) {
        String days = controllersList[i][j].text;
        await firebaseFirestore.collection('days').add({
          'skill_id': selectedSkill,
          'level_id': levelsList[i]['levelID'],
          'complexity_name': complexityList[j]['complexityName'],
          'days': days,
        });
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Days added successfully!'),
      ),
    );
    Navigator.pop(context);
  }

  void resetControllers() {
    for (List<TextEditingController> controllers in controllersList) {
      for (TextEditingController controller in controllers) {
        controller.text = '0';
      }
    }
  }

  @override
  void dispose() {
    for (List<TextEditingController> controllers in controllersList) {
      for (TextEditingController controller in controllers) {
        controller.dispose();
      }
    }
    super.dispose();
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
          "Add Days",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
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
            Row(
              children: [
                Expanded(
                  child: Container(),
                ),
                for (var complexity in complexityList)
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(10.0),
                      child: Text(
                        complexity['complexityName'] ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            for (var level in levelsList)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(8.0),
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        level['levelName'] ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  for (int i = 0; i < complexityList.length; i++)
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.all(7.0),
                        child: SizedBox(
                          width: 25,
                          child: TextField(
                            controller:
                                controllersList[levelsList.indexOf(level)][i],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: button(
                textColor: CupertinoColors.white,
                backgroundColor: CupertinoColors.black,
                buttonName: "Add Days",
                onPressed: addDaysToDatabase,
              ),
            )
          ],
        ),
      ),
    );
  }
}
