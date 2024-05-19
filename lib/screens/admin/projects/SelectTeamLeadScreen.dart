import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SelectTeamLeadScreen extends StatefulWidget {
  final String? projectId;

  const SelectTeamLeadScreen({Key? key, this.projectId}) : super(key: key);

  @override
  _SelectTeamLeadScreenState createState() => _SelectTeamLeadScreenState();
}

class _SelectTeamLeadScreenState extends State<SelectTeamLeadScreen> {
  String? selectedUserId;
  String? selectedUserDocumentId;
  List<DropdownMenuItem<String>> userItems = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final users = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'user')
        .get();

    setState(() {
      userItems = users.docs
          .map((doc) => DropdownMenuItem(
                value: doc.id,
                child: Text(doc['name']),
              ))
          .toList();
    });
  }

  Future<void> updateProject() async {
    if (selectedUserDocumentId != null && widget.projectId != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(selectedUserDocumentId)
          .get();
      final userId = userDoc['userID'];

      final ref = FirebaseFirestore.instance.collection('Projects');
      await ref.doc(widget.projectId).update({
        'Status': 'InProgress',
        'Start Date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'Team_Lead_ID': userId,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('Project kicked off successfully with selected team lead'),
      ));
      Navigator.pop(context);
      Navigator.pop(context); // Go back to main list page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Team Lead'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Please select team lead for this Project'),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedUserDocumentId,
              items: userItems,
              onChanged: (value) {
                setState(() {
                  selectedUserDocumentId = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Team Lead',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateProject,
              child: Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}
