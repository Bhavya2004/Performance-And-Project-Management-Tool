import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ppmt/components/button.dart';
import 'package:ppmt/constants/color.dart';

class AddDays extends StatefulWidget {
  final QueryDocumentSnapshot<Object?>? document;

  const AddDays({Key? key, this.document}) : super(key: key);

  @override
  State<AddDays> createState() => _AddDaysState();
}

class _AddDaysState extends State<AddDays> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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

    setState(() {});
  }


  void fetchLevels() async {
    QuerySnapshot levelsSnapshot = await _firestore.collection('levels').get();

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

    if (widget.document != null) {
      selectedSkill = widget.document!['skillName'] as String?;
      Map<String, dynamic>? daysData =
          widget.document!['days'] as Map<String, dynamic>?;

      if (daysData != null) {
        for (int i = 0; i < levelsList.length; i++) {
          Map<String, dynamic>? levelData =
              daysData[levelsList[i]['levelName']] as Map<String, dynamic>?;

          if (levelData != null) {
            for (int j = 0; j < complexityList.length; j++) {
              String complexityName =
                  complexityList[j]['complexityName'] as String;
              int days = levelData[complexityName] as int? ?? 0;
              controllersList[i][j].text = days.toString();
            }
          }
        }
      }
    }
  }

  void addOrUpdateDays() async {
    if (selectedSkill == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a skill first!'),
        ),
      );
      return;
    }

    Map<String, dynamic> daysData = {};

    for (int i = 0; i < levelsList.length; i++) {
      Map<String, dynamic> levelData = {};

      for (int j = 0; j < complexityList.length; j++) {
        int days = int.tryParse(controllersList[i][j].text) ?? 0;
        levelData[complexityList[j]['complexityName'] as String] = days;
      }

      daysData[levelsList[i]['levelName'] as String] = levelData;
    }

    if (widget.document != null) {
      // Update existing document
      await _firestore.collection('days').doc(widget.document!.id).update({
        'skillName': selectedSkill,
        'days': daysData,
      });
    } else {
      // Add new document
      await _firestore.collection('days').add({
        'skillName': selectedSkill,
        'days': daysData,
      });
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
          widget.document != null ? 'Edit Days' : 'Add Days',
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
                      child: Center(child: Text('Levels')),
                    ),
                    for (var complexity in complexityList)
                      TableCell(
                        child: Center(
                            child:
                                Text(complexity['complexityName'] as String)),
                      ),
                  ],
                ),
                for (int i = 0; i < levelsList.length; i++)
                  TableRow(
                    children: [
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(levelsList[i]['levelName'] as String),
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
              buttonName: widget.document != null ? 'Update Days' : 'Add Days',
              textColor: CupertinoColors.white,
              onPressed: addOrUpdateDays,
            ),
          ],
        ),
      ),
    );
  }
}
