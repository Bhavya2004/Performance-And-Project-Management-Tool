import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ppmt/components/button.dart';
import 'package:ppmt/components/snackbar.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/constants/generate_id.dart';

class AddPoint extends StatefulWidget {
  final QueryDocumentSnapshot<Object?>? document;
  final String pointsID;

  AddPoint({Key? key, this.document, required this.pointsID}) : super(key: key);

  @override
  State<AddPoint> createState() => _AddPointState();
}

class _AddPointState extends State<AddPoint> {
  List<Map<String, dynamic>> complexityList = [];
  List<Map<String, dynamic>> skillList = [];
  List<List<TextEditingController>> controllersList = [];
  List<String> taskTypes = [];
  String? selectedTaskType;

  @override
  void initState() {
    super.initState();
    fetchComplexity();
    fetchSkills();
    fetchTaskTypes();

    if (widget.document != null && widget.document!["taskTypeID"] != null) {
      String taskTypeID = widget.document!["taskTypeID"];
      getTaskTypeName(taskTypeID).then((taskTypeName) {
        setState(() {
          selectedTaskType = taskTypeName;
        });
      }).catchError((error) {
        print("Error fetching task type name: $error");
        showSnackBar(
            context: context, message: "Error fetching task type name");
      });
    } else {
      selectedTaskType = null;
    }
  }

  Future<String> getTaskTypeName(String taskTypeID) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('taskType')
          .where('taskTypeID', isEqualTo: taskTypeID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final taskTypeSnapshot = querySnapshot.docs.first;
        final taskTypeData = taskTypeSnapshot.data() as Map<String, dynamic>?;

        if (taskTypeData != null) {
          return taskTypeData['taskTypeName'];
        } else {
          throw ('Document data is null or empty');
        }
      } else {
        throw ('Skill with ID $taskTypeID not found.');
      }
    } catch (e) {
      throw ('Error fetching Task Type details: $e');
    }
  }

  void fetchComplexity() async {
    try {
      QuerySnapshot complexitySnapshot = await FirebaseFirestore.instance
          .collection("complexity")
          .orderBy("complexityID")
          .get();

      setState(() {
        complexityList = complexitySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });

      initializeControllersIfNeeded();
    } catch (e) {
      print("Error fetching complexity: $e");
      showSnackBar(context: context, message: "Error fetching complexity");
    }
  }

  void resetControllers() {
    for (List<TextEditingController> controllers in controllersList) {
      for (TextEditingController controller in controllers) {
        controller.text = "0";
      }
    }
  }

  void fetchSkills() async {
    try {
      QuerySnapshot skillsSnapshot = await FirebaseFirestore.instance
          .collection("skills")
          .where("isDisabled", isEqualTo: false)
          .get();

      setState(() {
        skillList = skillsSnapshot.docs
            .where((doc) => doc['isDisabled'] == false)
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });

      initializeControllersIfNeeded();
    } catch (e) {
      print("Error fetching skills: $e");
      showSnackBar(context: context, message: "Error fetching skills");
    }
  }

  void fetchTaskTypes() async {
    try {
      QuerySnapshot taskTypesSnapshot = await FirebaseFirestore.instance
          .collection("taskType")
          .where("isDisabled", isEqualTo: false)
          .get();

      setState(() {
        taskTypes = taskTypesSnapshot.docs
            .map((doc) => doc["taskTypeName"] as String)
            .toList();
      });

      initializeControllersIfNeeded();
    } catch (e) {
      print("Error fetching task types: $e");
      showSnackBar(context: context, message: "Error fetching task types");
    }
  }

  void initializeControllersIfNeeded() {
    if (skillList.isNotEmpty && complexityList.isNotEmpty) {
      initializeControllers();
    }
  }

  void initializeControllers() {
    controllersList.clear();
    for (int i = 0; i < skillList.length; i++) {
      List<TextEditingController> controllers = [];
      for (int j = 0; j < complexityList.length; j++) {
        controllers.add(TextEditingController());
      }
      controllersList.add(controllers);
    }

    if (widget.document != null) {
      selectedTaskType = widget.document!["taskTypeID"] as String?;
      Map<String, dynamic>? pointsData =
      widget.document!["points"] as Map<String, dynamic>?;

      if (pointsData != null) {
        for (int i = 0; i < skillList.length; i++) {
          Map<String, dynamic>? taskTypeData =
          pointsData[skillList[i]["skillID"]] as Map<String, dynamic>?;

          if (taskTypeData != null) {
            for (int j = 0; j < complexityList.length; j++) {
              String complexityName =
              complexityList[j]["complexityName"] as String;
              var value = taskTypeData[complexityName];
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

  void addPoints(Map<String, dynamic> pointsData) async {
    try {
      int lastPointsID =
      await getLastID(collectionName: "points", primaryKey: "pointsID");
      int newpointsID = lastPointsID + 1;

      DocumentSnapshot taskTypeSnapshot = await FirebaseFirestore.instance
          .collection("taskType")
          .where("taskTypeName", isEqualTo: selectedTaskType)
          .limit(1)
          .get()
          .then((snapshot) => snapshot.docs.first);
      String taskTypeID = taskTypeSnapshot["taskTypeID"];

      await FirebaseFirestore.instance.collection("points").add({
        "pointsID": newpointsID.toString(),
        "taskTypeID": taskTypeID,
        "points": pointsData,
      });
      showSnackBar(
          context: context, message: "Points Calculation Added Successfully");
      Navigator.pop(context);
    } catch (e) {
      print("Error adding points: $e");
      showSnackBar(context: context, message: "Error adding points: $e");
    }
  }

  void updatePoints(String pointsID, Map<String, dynamic> pointsData) async {
    try {
      DocumentSnapshot taskTypeSnapshot = await FirebaseFirestore.instance
          .collection("taskType")
          .where("taskTypeName", isEqualTo: selectedTaskType)
          .limit(1)
          .get()
          .then((snapshot) => snapshot.docs.first);
      String taskTypeID = taskTypeSnapshot["taskTypeID"];

      final querySnapshot = await FirebaseFirestore.instance
          .collection("points")
          .where("pointsID", isEqualTo: widget.pointsID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final pointsSnapShot = querySnapshot.docs.first;
        final taskTypeData = pointsSnapShot.data() as Map<String, dynamic>?;

        if (taskTypeData != null) {
          await pointsSnapShot.reference.update({
            "taskTypeID": taskTypeID,
            "points": pointsData,
          });
        } else {
          throw ("Document data is null or empty");
        }
      } else {
        throw ("taskType with ID ${widget.pointsID} not found.");
      }
    } catch (e) {
      print("Error updating points: $e");
      showSnackBar(context: context, message: "Error updating points: $e");
    }

    showSnackBar(
        context: context, message: "Points Calculation Updated Successfully");
    Navigator.pop(context);
  }

  void submit() async {
    if (selectedTaskType == null) {
      showSnackBar(
          context: context, message: "Please select a Task Type first!");
      return;
    }

    QuerySnapshot skillSnapshot = await FirebaseFirestore.instance
        .collection("points")
        .where("taskTypeName", isEqualTo: selectedTaskType)
        .get();

    if (widget.document == null && skillSnapshot.docs.isNotEmpty) {
      showSnackBar(
        context: context,
        message: "Skill '$selectedTaskType' already exists!",
      );
      return;
    }

    Map<String, dynamic> pointsData = {};

    for (int i = 0; i < skillList.length; i++) {
      Map<String, dynamic> taskTypeData = {};

      for (int j = 0; j < complexityList.length; j++) {
        int points = int.tryParse(controllersList[i][j].text) ?? 0;
        taskTypeData[complexityList[j]["complexityName"] as String] = points;
      }

      pointsData[skillList[i]["skillID"] as String] = taskTypeData;
    }

    if (widget.document != null) {
      updatePoints(widget.document!.id, pointsData);
    } else {
      addPoints(pointsData);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (complexityList.isEmpty || skillList.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: CupertinoColors.white,
        ),
        backgroundColor: kAppBarColor,
        title: Text(
          widget.document != null ? "Edit points" : "Add points",
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
                items: taskTypes.map((taskType) {
                  return DropdownMenuItem(
                    value: taskType,
                    child: Text(taskType),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedTaskType = value as String?;
                    resetControllers();
                  });
                },
                value: selectedTaskType,
                decoration: InputDecoration(
                  labelText: "Task Type",
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
                for (int i = 0; i < skillList.length; i++)
                  TableRow(
                    children: [
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            skillList[i]["skillName"] as String,
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
              buttonName:
              widget.document != null ? "Update points" : "Add points",
              textColor: CupertinoColors.white,
              onPressed: submit,
            ),
          ],
        ),
      ),
    );
  }
}
