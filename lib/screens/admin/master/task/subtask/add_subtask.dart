import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/components/button.dart';
import 'package:ppmt/components/textfield.dart';
import 'package:ppmt/constants/color.dart';

class AddSubTask extends StatefulWidget {
  final String taskId;
  final String?
      subTaskID;
  final String? subTaskName;
  final bool isEditMode;

  const AddSubTask({
    required this.taskId,
    this.subTaskID,
    this.subTaskName,
    this.isEditMode = false,
    Key? key,
  }) : super(key: key);

  @override
  State<AddSubTask> createState() => _AddSubTaskState();
}

class _AddSubTaskState extends State<AddSubTask> {
  late TextEditingController subTaskController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    subTaskController = TextEditingController(text: widget.subTaskName ?? '');
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
          widget.isEditMode ? "Update Sub Task" : "Add Sub Task",
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
                controller: subTaskController,
                keyboardType: TextInputType.text,
                labelText: "Sub Task Name",
                obscureText: false,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a Sub Task name';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: button(
                  buttonName:
                      widget.isEditMode ? "Update Sub Task" : "Add Sub Task",
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

  Future<int> getLastSubTaskID() async {
    try {
      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      QuerySnapshot<Map<String, dynamic>> snapshot = await firebaseFirestore
          .collection('subtasks')
          .orderBy('subTaskID', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        String? subTaskIDString = snapshot.docs.first['subTaskID'] as String?;
        if (subTaskIDString != null && int.tryParse(subTaskIDString) != null) {
          return int.parse(subTaskIDString);
        }
      }
      return 0;
    } catch (e) {
      throw ('Error getting last subtask ID: $e');
    }
  }

  Future<void> AddSubTask({required String subTaskName}) async {
    try {
      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      CollectionReference ref = firebaseFirestore.collection('subtasks');

      int lastSubTaskID = await getLastSubTaskID();
      int newSubTaskID = lastSubTaskID + 1;

      await ref.add({
        'subTaskID': newSubTaskID.toString(),
        'subTaskName': subTaskName,
        'taskId': widget.taskId,
        'isDisabled': false,
      });
    } catch (e) {
      throw ('Error adding subtask: $e');
    }
  }

  Future<void> updateSubTask(
      {required String subTaskId, required String subTaskName}) async {
    try {
      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      DocumentReference ref =
          firebaseFirestore.collection('subtasks').doc(subTaskId);

      await ref.update({'subTaskName': subTaskName});
    } catch (e) {
      throw ('Error updating subtask: $e');
    }
  }

  Future<void> submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (widget.isEditMode) {
          await updateSubTask(
              subTaskId: widget.subTaskID!,
              subTaskName: subTaskController.text.toString());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Sub Task Updated Successfully',
              ),
            ),
          );
        } else {
          await AddSubTask(subTaskName: subTaskController.text.toString());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sub Task Added Successfully'),
            ),
          );
        }

        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
          ),
        );
      }
    }
  }
}
