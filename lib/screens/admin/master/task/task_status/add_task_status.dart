import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:ppmt/components/button.dart';
import 'package:ppmt/components/snackbar.dart';
import 'package:ppmt/components/textfield.dart';
import 'package:ppmt/constants/color.dart';

class AddTaskStatus extends StatefulWidget {
  final String taskId;
  final String? taskStatusID;
  final String? taskStatusName;
  final String? taskStatusColor;
  final bool isEditMode;

  const AddTaskStatus({
    required this.taskId,
    this.isEditMode = false,
    Key? key,
    this.taskStatusID,
    this.taskStatusName,
    this.taskStatusColor,
  }) : super(key: key);

  @override
  State<AddTaskStatus> createState() => _AddTaskStatusState();
}

class _AddTaskStatusState extends State<AddTaskStatus> {
  TextEditingController taskStatusController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Color currentColor = Colors.green;

  @override
  void initState() {
    super.initState();
    taskStatusController =
        TextEditingController(text: widget.taskStatusName ?? '');
    currentColor = widget.taskStatusColor != null
        ? Color(
            int.parse(
              widget.taskStatusColor!,
              radix: 16,
            ),
          )
        : Colors.green;
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
          widget.isEditMode ? "Update Task Status" : "Add Task Status",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              textFormField(
                controller: taskStatusController,
                keyboardType: TextInputType.text,
                labelText: "Task Status",
                obscureText: false,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Task Status Required";
                  }
                  return null;
                },
              ),
              Container(
                color: Colors.white,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Pick a color!'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: currentColor,
                                  onColorChanged: (Color color) {
                                    setState(() {
                                      currentColor = color;
                                    });
                                  },
                                  showLabel: true,
                                ),
                              ),
                              actions: <Widget>[
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Done'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text("Select Color"),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Selected Color:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: 50,
                      height: 50,
                      color: currentColor,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: button(
                  buttonName: widget.isEditMode
                      ? "Update Task Status"
                      : "Add Task Status",
                  backgroundColor: CupertinoColors.black,
                  textColor: CupertinoColors.white,
                  onPressed: submit,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<int> getLastTaskStatusID() async {
    try {
      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      QuerySnapshot<Map<String, dynamic>> snapshot = await firebaseFirestore
          .collection('taskStatus')
          .orderBy('taskStatusID', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        String? taskStatusIDString =
            snapshot.docs.first['taskStatusID'] as String?;
        if (taskStatusIDString != null &&
            int.tryParse(taskStatusIDString) != null) {
          return int.parse(taskStatusIDString);
        }
      }
      return 0;
    } catch (e) {
      throw ('Error getting last Task Status ID: $e');
    }
  }

  Future<void> AddTaskStatus({required String taskStatusName}) async {
    try {
      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      CollectionReference ref = firebaseFirestore.collection('taskStatus');

      int lastTaskStatusID = await getLastTaskStatusID();
      int newTaskStatusID = lastTaskStatusID + 1;

      await ref.add({
        'taskStatusID': newTaskStatusID.toString(),
        'taskStatusName': taskStatusName,
        'taskID': widget.taskId,
        'taskStatusColor': currentColor.value.toRadixString(16),
      });
    } catch (e) {
      throw ('Error adding TaskStatus: $e');
    }
  }

  Future<void> updateTaskStatus(
      {required String taskStatusID, required String taskStatusName}) async {
    try {
      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

      QuerySnapshot querySnapshot = await firebaseFirestore
          .collection('taskStatus')
          .where('taskStatusID', isEqualTo: taskStatusID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot docSnapshot = querySnapshot.docs.first;
        DocumentReference docRef = docSnapshot.reference;
        await docRef.update({
          'taskStatusName': taskStatusName,
          'taskStatusColor': currentColor.value.toRadixString(16),
        });
      } else {}
    } catch (e) {
      throw ('Error updating Task Status: $e');
    }
  }

  Future<void> submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (widget.isEditMode) {
          print(widget.taskStatusID);
          await updateTaskStatus(
              taskStatusID: widget.taskStatusID!,
              taskStatusName: taskStatusController.text.toString());
          showSnackBar(
              context: context, message: "Task Status Updated Successfully");
        } else {
          await AddTaskStatus(
              taskStatusName: taskStatusController.text.toString());
          showSnackBar(
              context: context, message: "Task Status Added Successfully");
        }

        Navigator.of(context).pop();
      } catch (e) {
        showSnackBar(context: context, message: "Error: $e");
      }
    }
  }
}
