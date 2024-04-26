import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/components/button.dart';
import 'package:ppmt/components/textfield.dart';

class AddTask extends StatefulWidget {
  const AddTask({super.key});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  TextEditingController taskController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> taskStatus = {
    "To Do": true,
    'Done': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Task"),
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
                child: Text('Add Status'),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: taskStatus.length,
                itemBuilder: (context, index) {
                  String key = taskStatus.keys.elementAt(index);
                  return ListTile(
                    title: Text(key),
                    subtitle: Text(taskStatus[key].toString()),
                  );
                },
              ),
              button(
                buttonName: "Add Task",
                onPressed: submit,
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

  Future<void> submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        await addTask(taskName: taskController.text.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task Added Successfully'),
          ),
        );

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
