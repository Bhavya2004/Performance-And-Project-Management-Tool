import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:ppmt/components/button.dart";
import "package:ppmt/components/snackbar.dart";
import "package:ppmt/components/textfield.dart";
import "package:ppmt/constants/color.dart";
import "package:ppmt/constants/generate_id.dart";

class AddTaskType extends StatefulWidget {
  final String taskTypeID;
  final String taskTypeName;

  const AddTaskType({
    required this.taskTypeID,
    required this.taskTypeName,
    Key? key,
  }) : super(key: key);

  @override
  State<AddTaskType> createState() => _AddTaskTypeState();
}

class _AddTaskTypeState extends State<AddTaskType> {
  TextEditingController taskTypeController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    taskTypeController.text = widget.taskTypeName;
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
          widget.taskTypeID != "" ? "Update Task Type" : "Add Task Type",
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
                controller: taskTypeController,
                keyboardType: TextInputType.text,
                labelText: "Task Type",
                obscureText: false,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Task Type is Required";
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: button(
                  buttonName: widget.taskTypeID != ""
                      ? "Update Task Type"
                      : "Add Task Type",
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

  Future<void> AddTaskType() async {
    try {
      // adding in taskType Collection

      int lastTaskTypeID =
          await getLastID(collectionName: "taskType", primaryKey: "taskTypeID");
      int newTaskTypeID = lastTaskTypeID + 1;

      await FirebaseFirestore.instance.collection("taskType").add({
        "taskTypeID": newTaskTypeID.toString(),
        "taskTypeName": taskTypeController.text.trim(),
        "isDisabled": false
      });

      CollectionReference statusRef =
          FirebaseFirestore.instance.collection("taskTypeStatus");

      await statusRef.add({
        "taskTypeID": newTaskTypeID.toString(),
        "taskTypeStatusName": "To Do",
        "taskTypeStatusColor": "ff8c8c8c",
        "taskTypeStatusID": "1",
        "isDisabled": false,
      });

      await statusRef.add({
        "taskTypeID": newTaskTypeID.toString(),
        "taskTypeStatusName": "Done",
        "taskTypeStatusColor": "ff8bc34a",
        "taskTypeStatusID": "2",
        "isDisabled": false,
      });
    } catch (e) {
      throw ("Error adding level: $e");
    }
  }

  Future<void> updateTask() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("taskType")
          .where("taskTypeID", isEqualTo: widget.taskTypeID)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference taskRef = querySnapshot.docs.first.reference;
        await taskRef.update({
          "taskTypeName": taskTypeController.text.trim(),
        });
      }
    } catch (e) {
      throw ("Error updating task: $e");
    }
  }

  Future<void> submit() async {
    if (formKey.currentState!.validate()) {
      try {
        if (widget.taskTypeID != "") {
          await updateTask();
          showSnackBar(
              context: context, message: "Task Type Updated Successfully");
        } else {
          // If not in edit mode, add a new task
          await AddTaskType();
          showSnackBar(
              context: context, message: "Task Type Added Successfully");
        }
        Navigator.of(context).pop();
      } catch (e) {
        showSnackBar(context: context, message: "Error: $e");
      }
    }
  }
}
