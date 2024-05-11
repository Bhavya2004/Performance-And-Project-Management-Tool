import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:ppmt/components/button.dart";
import "package:ppmt/components/snackbar.dart";
import "package:ppmt/constants/color.dart";
import "package:ppmt/constants/generate_id.dart";

class AddDays extends StatefulWidget {
  final QueryDocumentSnapshot<Object?>? document;
  final String daysID;

  AddDays({Key? key, this.document, required this.daysID}) : super(key: key);

  @override
  State<AddDays> createState() => _AddDaysState();
}

class _AddDaysState extends State<AddDays> {
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

    if (widget.document != null && widget.document!["skillID"] != null) {
      String skillID = widget.document!["skillID"];
      getSkillName(skillID).then((skillName) {
        setState(() {
          selectedSkill = skillName;
        });
      }).catchError((error) {});
    } else {
      selectedSkill = null;
    }
  }

  Future<String> getSkillName(String skillID) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('skills')
          .where('skillID', isEqualTo: skillID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final skillSnapshot = querySnapshot.docs.first;
        final skillData = skillSnapshot.data() as Map<String, dynamic>?;

        if (skillData != null) {
          return skillData['skillName'];
        } else {
          throw ('Document data is null or empty');
        }
      } else {
        throw ('Skill with ID $skillID not found.');
      }
    } catch (e) {
      throw ('Error fetching skill details: $e');
    }
  }

  void fetchComplexity() async {
    QuerySnapshot complexitySnapshot = await FirebaseFirestore.instance
        .collection("complexity")
        .orderBy("complexityID")
        .get();

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
        controller.text = "0";
      }
    }
  }

  void fetchSkills() async {
    QuerySnapshot skillsSnapshot = await FirebaseFirestore.instance
        .collection("skills")
        .where("isDisabled", isEqualTo: false)
        .get();

    setState(() {
      skills =
          skillsSnapshot.docs.map((doc) => doc["skillName"] as String).toList();
    });
  }

  void fetchLevels() async {
    QuerySnapshot levelsSnapshot = await FirebaseFirestore.instance
        .collection("levels")
        .orderBy("levelID")
        .get();

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
      selectedSkill = widget.document!["skillID"] as String?;
      Map<String, dynamic>? daysData =
          widget.document!["days"] as Map<String, dynamic>?;

      if (daysData != null) {
        for (int i = 0; i < levelsList.length; i++) {
          Map<String, dynamic>? levelData =
              daysData[levelsList[i]["levelID"]] as Map<String, dynamic>?;

          if (levelData != null) {
            for (int j = 0; j < complexityList.length; j++) {
              String complexityName =
                  complexityList[j]["complexityName"] as String;
              var value = levelData[complexityName];
              if (value is int || value is double) {
                controllersList[i][j].text = value.toString();
              } else {
                controllersList[i][j].text = "0";
              }
            }
          }
        }
      }
    }
  }

  void addDays(Map<String, dynamic> daysData) async {
    int lastDaysID =
        await getLastID(collectionName: "days", primaryKey: "daysID");
    int newDaysID = lastDaysID + 1;

    DocumentSnapshot skillSnapshot = await FirebaseFirestore.instance
        .collection("skills")
        .where("skillName", isEqualTo: selectedSkill)
        .limit(1)
        .get()
        .then((snapshot) => snapshot.docs.first);
    String skillID = skillSnapshot["skillID"];

    await FirebaseFirestore.instance.collection("days").add({
      "daysID": newDaysID.toString(),
      "skillID": skillID,
      "days": daysData,
    });
    showSnackBar(
        context: context, message: "Days Calculation Added Successfully");
    Navigator.pop(context);
  }

  void updateDays(String daysID, Map<String, dynamic> daysData) async {
    try {
      DocumentSnapshot skillSnapshot = await FirebaseFirestore.instance
          .collection("skills")
          .where("skillName", isEqualTo: selectedSkill)
          .limit(1)
          .get()
          .then((snapshot) => snapshot.docs.first);
      String skillID = skillSnapshot["skillID"];

      final querySnapshot = await FirebaseFirestore.instance
          .collection("days")
          .where("daysID", isEqualTo: widget.daysID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final daysSnapShot = querySnapshot.docs.first;
        final skillData = daysSnapShot.data() as Map<String, dynamic>?;

        if (skillData != null) {
          await daysSnapShot.reference.update({
            "skillID": skillID,
            "days": daysData,
          });
        } else {
          throw ("Document data is null or empty");
        }
      } else {
        throw ("Level with ID ${widget.daysID} not found.");
      }
    } catch (e) {
      throw ("Error updating skill details: $e");
    }

    showSnackBar(
        context: context, message: "Days Calculation Updated Successfully");
    Navigator.pop(context);
  }

  void submit() async {
    if (selectedSkill == null) {
      showSnackBar(context: context, message: "Please select a skill first!");
      return;
    }

    QuerySnapshot skillSnapshot = await FirebaseFirestore.instance
        .collection("days")
        .where("skillName", isEqualTo: selectedSkill)
        .get();

    if (widget.document == null && skillSnapshot.docs.isNotEmpty) {
      showSnackBar(
        context: context,
        message: "Skill '$selectedSkill' already exists!",
      );
      return;
    }

    Map<String, dynamic> daysData = {};

    for (int i = 0; i < levelsList.length; i++) {
      Map<String, dynamic> levelData = {};

      for (int j = 0; j < complexityList.length; j++) {
        int days = int.tryParse(controllersList[i][j].text) ?? 0;
        levelData[complexityList[j]["complexityName"] as String] = days;
      }

      daysData[levelsList[i]["levelID"] as String] = levelData;
    }

    if (widget.document != null) {
      updateDays(widget.document!.id, daysData);
    } else {
      addDays(daysData);
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
        title: Text(
          widget.document != null ? "Edit Days" : "Add Days",
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
                  labelText: "Skill",
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
                            complexity["complexityName"] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                for (int i = 0; i < levelsList.length; i++)
                  TableRow(
                    children: [
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            levelsList[i]["levelName"] as String,
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
              buttonName: widget.document != null ? "Update Days" : "Add Days",
              textColor: CupertinoColors.white,
              onPressed: submit,
            ),
          ],
        ),
      ),
    );
  }
}
