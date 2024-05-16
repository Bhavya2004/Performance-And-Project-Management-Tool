import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/components/button.dart';
import 'package:ppmt/components/snackbar.dart';
import 'package:ppmt/components/textfield.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/constants/generate_id.dart';

class AddTaskTypeStatus extends StatefulWidget {
  final String taskTypeID;
  final String taskTypeStatusID;
  final String taskTypeStatusName;
  final String? taskTypeStatusColor;

  const AddTaskTypeStatus({
    required this.taskTypeID,
    Key? key,
    required this.taskTypeStatusID,
    required this.taskTypeStatusName,
    this.taskTypeStatusColor,
  }) : super(key: key);

  @override
  State<AddTaskTypeStatus> createState() => _AddTaskTypeStatusState();
}

class _AddTaskTypeStatusState extends State<AddTaskTypeStatus> {
  TextEditingController taskTypeStatusController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  Color currentColor = Colors.green;

  @override
  void initState() {
    super.initState();
    taskTypeStatusController.text = widget.taskTypeStatusName;
    currentColor = widget.taskTypeStatusColor != null
        ? Color(
      int.parse(
        widget.taskTypeStatusColor!,
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
          widget.taskTypeStatusID != ""
              ? "Update Task Type Status"
              : "Add Task Type Status",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              textFormField(
                controller: taskTypeStatusController,
                keyboardType: TextInputType.text,
                labelText: "Task Type Status",
                obscureText: false,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Task Type Status Required";
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
                                  color: currentColor,
                                  onColorChanged: (Color color) {
                                    setState(() {
                                      currentColor = color;
                                    });
                                  },
                                  width: 44,
                                  height: 44,
                                  borderRadius: 22,
                                  heading: Text(
                                    'Select color',
                                  ),
                                  subheading: Text(
                                    'Select color shade',
                                  ),
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
                  buttonName: widget.taskTypeStatusID != ""
                      ? "Update Task Type Status"
                      : "Add Task Type Status",
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

  Future<void> addTaskTypeStatus() async {
    try {
      CollectionReference ref =
      FirebaseFirestore.instance.collection('taskTypeStatus');

      int lastTaskTypeStatusID = await getLastID(
        collectionName: "taskTypeStatus",
        primaryKey: "taskTypeStatusID",
      );
      int newTaskTypeStatusID = lastTaskTypeStatusID + 1;

      await ref.add({
        'taskTypeStatusID': newTaskTypeStatusID.toString(),
        'taskTypeStatusName': taskTypeStatusController.text.trim(),
        'taskTypeID': widget.taskTypeID,
        'taskTypeStatusColor': currentColor.value.toRadixString(16),
        'isDisabled': false,
      });
    } catch (e) {
      throw ('Error adding taskTypeStatus: $e');
    }
  }

  Future<void> updateTaskTypeStatus() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('taskTypeStatus')
          .where('taskTypeStatusID', isEqualTo: widget.taskTypeStatusID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot docSnapshot = querySnapshot.docs.first;
        DocumentReference docRef = docSnapshot.reference;
        await docRef.update({
          'taskTypeStatusName': taskTypeStatusController.text.trim(),
          'taskTypeStatusColor': currentColor.value.toRadixString(16),
        });
      } else {}
    } catch (e) {
      throw ('Error updating Task Status: $e');
    }
  }

  Future<void> submit() async {
    if (formKey.currentState!.validate()) {
      try {
        if (widget.taskTypeStatusID != "") {
          await updateTaskTypeStatus();
          showSnackBar(
              context: context,
              message: "Task Type Status Updated Successfully");
        } else {
          await addTaskTypeStatus();
          showSnackBar(
              context: context, message: "Task Type Status Added Successfully");
        }
        Navigator.of(context).pop();
      } catch (e) {
        showSnackBar(context: context, message: "Error: $e");
      }
    }
  }
}
