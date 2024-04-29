import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/components/button.dart';
import 'package:ppmt/components/textfield.dart';
import 'package:ppmt/constants/color.dart';

class AddTask extends StatefulWidget {
  final String? taskId; // Task ID for identifying the task in edit mode
  final String? taskName; // Task name for pre-filling in edit mode
  final Map<String, dynamic>?
      taskStatus; // Task status for pre-filling in edit mode
  final bool isEditMode; // Indicates if it's edit mode or not

  const AddTask({
    this.taskId,
    this.taskName,
    this.taskStatus,
    this.isEditMode = false, // Default to false
    Key? key,
  }) : super(key: key);

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  late TextEditingController taskController;
  final _formKey = GlobalKey<FormState>();
  String selectedStatus = "To Do";
  Map<String, dynamic> taskStatus = {
    "To Do": true,
    'Done': false,
  };

  @override
  void initState() {
    super.initState();
    // Initialize controller with taskName if in edit mode, otherwise create a new one
    taskController = TextEditingController(text: widget.taskName ?? '');
    // Initialize selectedStatus with task status if in edit mode, otherwise keep default
    if (widget.isEditMode && widget.taskStatus != null) {
      // Retrieve all the custom statuses for the task
      taskStatus = Map<String, dynamic>.from(widget.taskStatus!);
      // Find the selected status (true) and set it as the selectedStatus
      for (var entry in taskStatus.entries) {
        if (entry.value == true) {
          selectedStatus = entry.key;
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: AppColor.white,
        ),
        backgroundColor: AppColor.sanMarino,
        title: Text(
          widget.isEditMode ? "Update Task" : "Add Task",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColor.white,
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
              ElevatedButton(
                onPressed: () {
                  _showStatusInputDialog();
                },
                child: Text(
                  'Add Status',
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: DropdownButtonFormField<String>(
                  value: selectedStatus,
                  onChanged: (newValue) {
                    setState(() {
                      selectedStatus = newValue!;
                    });
                  },
                  items: taskStatus.keys.map((String status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: button(
                  buttonName: widget.isEditMode ? "Update Task" : "Add Task",
                  backgroundColor: AppColor.black,
                  textColor: AppColor.white,
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
      CollectionReference ref = firebaseFirestore.collection('tasks');

      int lastTaskID = await getLastTaskID();
      int newTaskID = lastTaskID + 1;

      await ref.add({
        'taskID': newTaskID.toString(),
        'taskName': taskName,
        "taskStatus": taskStatus
      });
    } catch (e) {
      throw ('Error adding level: $e');
    }
  }

  Future<void> updateTask(
      {required String taskId, required String taskName}) async {
    try {
      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      DocumentReference ref = firebaseFirestore.collection('tasks').doc(taskId);

      // Create a new map to store the updated task status
      Map<String, dynamic> updatedTaskStatus = {};
      taskStatus.forEach((key, value) {
        // Set the selected status to true, rest to false
        updatedTaskStatus[key] = (key == selectedStatus);
      });

      await ref.update({'taskName': taskName, "taskStatus": updatedTaskStatus});
    } catch (e) {
      throw ('Error updating task: $e');
    }
  }

  Future<void> submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (widget.isEditMode) {
          // If in edit mode, update the existing task
          await updateTask(
              taskId: widget.taskId!, taskName: taskController.text.toString());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task Updated Successfully'),
            ),
          );
        } else {
          // If not in edit mode, add a new task
          await addTask(taskName: taskController.text.toString());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task Added Successfully'),
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

  void _showStatusInputDialog() {
    TextEditingController statusController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Task Status'),
          content: TextField(
            controller: statusController,
            decoration: InputDecoration(hintText: 'Enter status'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String status = statusController.text.trim();
                if (status.isNotEmpty) {
                  setState(() {
                    addCustomStatus(status);
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void addCustomStatus(String status) {
    Map<String, dynamic> customStatus = {status: false};
    setState(() {
      taskStatus.addAll(customStatus);
    });
  }
}
