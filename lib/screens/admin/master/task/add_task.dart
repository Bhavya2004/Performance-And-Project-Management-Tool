import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/components/button.dart';
import 'package:ppmt/components/snackbar.dart';
import 'package:ppmt/components/textfield.dart';
import 'package:ppmt/constants/color.dart';

class AddTask extends StatefulWidget {
  final String? taskId;
  final String? taskName;
  final bool isEditMode;

  const AddTask({
    this.taskId,
    this.taskName,
    this.isEditMode = false,
    Key? key,
  }) : super(key: key);

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  late TextEditingController taskController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    taskController = TextEditingController(text: widget.taskName ?? '');
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
          widget.isEditMode ? "Update Task" : "Add Task",
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
                controller: taskController,
                keyboardType: TextInputType.text,
                labelText: "Task Name",
                obscureText: false,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a Task name';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: button(
                  buttonName: widget.isEditMode ? "Update Task" : "Add Task",
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

  Future<int> getLastTaskID() async {
    try {
      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      QuerySnapshot<Map<String, dynamic>> snapshot = await firebaseFirestore
          .collection('tasks')
          .orderBy('taskID', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        String? taskIDString = snapshot.docs.first['taskID'] as String?;
        if (taskIDString != null && int.tryParse(taskIDString) != null) {
          return int.parse(taskIDString);
        }
      }
      return 0;
    } catch (e) {
      throw ('Error getting last level ID: $e');
    }
  }

  Future<void> addTask({required String taskName}) async {
    try {
      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      CollectionReference tasksRef = firebaseFirestore.collection('tasks');
      CollectionReference statusRef =
          firebaseFirestore.collection('taskStatus');

      int lastTaskID = await getLastTaskID();
      int newTaskID = lastTaskID + 1;

      DocumentReference taskDocRef = await tasksRef.add({
        'taskID': newTaskID.toString(),
        'taskName': taskName,
      });

      await statusRef.add({
        'taskID': newTaskID.toString(),
        'taskStatusName': "To Do",
        "taskStatusColor": "ff8c8c8c",
        'taskStatusID': "1"
      });

      await statusRef.add({
        'taskID': newTaskID.toString(),
        'taskStatusName': "Done",
        "taskStatusColor": "ff8bc34a",
        'taskStatusID': "2"
      });
    } catch (e) {
      throw ('Error adding level: $e');
    }
  }

  Future<void> updateTask(
      {required String taskId, required String taskName}) async {
    try {
      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await firebaseFirestore
          .collection('tasks')
          .where('taskID', isEqualTo: taskId)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference taskRef = querySnapshot.docs.first.reference;
        await taskRef.update({'taskName': taskName});
      }
    } catch (e) {
      throw ('Error updating task: $e');
    }
  }

  Future<void> submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (widget.isEditMode) {
          await updateTask(
              taskId: widget.taskId!, taskName: taskController.text.toString());
          showSnackBar(context: context, message: "Task Updated Successfully");
        } else {
          // If not in edit mode, add a new task
          await addTask(taskName: taskController.text.toString());
          showSnackBar(context: context, message: "Task Added Successfully");
        }

        Navigator.of(context).pop();
      } catch (e) {
        showSnackBar(context: context, message: "Error: $e");
      }
    }
  }
}
