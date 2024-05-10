import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:ppmt/components/button.dart";
import "package:ppmt/components/snackbar.dart";
import "package:ppmt/components/textfield.dart";
import "package:ppmt/constants/color.dart";
import "package:ppmt/constants/generate_id.dart";

class AddSubTask extends StatefulWidget {
  final String taskTypeID;
  final String subTaskID;
  final String subTaskName;

  const AddSubTask({
    required this.taskTypeID,
    required this.subTaskID,
    required this.subTaskName,
    Key? key,
  }) : super(key: key);

  @override
  State<AddSubTask> createState() => _AddSubTaskState();
}

class _AddSubTaskState extends State<AddSubTask> {
  TextEditingController subTaskController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    subTaskController.text = widget.subTaskName;
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
          widget.subTaskID != "" ? "Update Sub Task" : "Add Sub Task",
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
                controller: subTaskController,
                keyboardType: TextInputType.text,
                labelText: "Sub Task Name",
                obscureText: false,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Sub Task Required";
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: button(
                  buttonName: widget.subTaskID != ""
                      ? "Update Sub Task"
                      : "Add Sub Task",
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

  Future<void> addSubTask() async {
    try {
      CollectionReference ref =
          FirebaseFirestore.instance.collection("subTask");

      int lastSubTaskID =
          await getLastID(collectionName: "subTask", primaryKey: "subTaskID");
      int newSubTaskID = lastSubTaskID + 1;

      await ref.add({
        "subTaskID": newSubTaskID.toString(),
        "subTaskName": subTaskController.text.trim(),
        "taskTypeID": widget.taskTypeID,
        "isDisabled": false,
      });
    } catch (e) {
      throw ("Error adding subtask: $e");
    }
  }

  Future<void> updateSubTask() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("subTask")
          .where("subTaskID", isEqualTo: widget.subTaskID)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference taskRef = querySnapshot.docs.first.reference;
        await taskRef.update({
          "subTaskName": subTaskController.text.trim(),
        });
      }
    } catch (e) {
      throw ("Error updating subtask: $e");
    }
  }

  Future<void> submit() async {
    if (formKey.currentState!.validate()) {
      try {
        if (widget.subTaskID != "") {
          await updateSubTask();
          showSnackBar(
              context: context, message: "Sub Task Updated Successfully");
        } else {
          await addSubTask();
          showSnackBar(
              context: context, message: "Sub Task Added Successfully");
        }
        Navigator.of(context).pop();
      } catch (e) {
        showSnackBar(context: context, message: "Error : $e");
      }
    }
  }
}
