import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/components/button.dart';
import 'package:ppmt/components/textfield.dart';

class AddSubTask extends StatefulWidget {
  final String taskId; // Task ID for associating the subtask with a task
  final String?
      subTaskID; // Subtask ID for identifying the subtask in edit mode
  final String? subTaskName; // Subtask name for pre-filling in edit mode
  final bool isEditMode; // Indicates if it's edit mode or not

  const AddSubTask({
    required this.taskId,
    this.subTaskID,
    this.subTaskName,
    this.isEditMode = false, // Default to false
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
        title: Text(widget.isEditMode ? "Edit Sub Task" : "Add Sub Task"),
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
              button(
                buttonName: widget.isEditMode
                    ? "Update Sub Task"
                    : "Add Sub Task", // Change button label based on mode
                onPressed: submit,
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
        'taskId': widget.taskId, // Associate subtask with the task
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
          // If in edit mode, update the existing subtask
          await updateSubTask(
              subTaskId: widget.subTaskID!,
              subTaskName: subTaskController.text.toString());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sub Task Updated Successfully'),
            ),
          );
        } else {
          // If not in edit mode, add a new subtask
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
