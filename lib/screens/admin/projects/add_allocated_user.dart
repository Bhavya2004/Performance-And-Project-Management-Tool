import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/components/button.dart';
import 'package:ppmt/components/dateFormat.dart';
import 'package:ppmt/components/snackbar.dart';
import 'package:ppmt/components/textfield.dart';
import 'package:ppmt/constants/color.dart';

class AddAllocatedUser extends StatefulWidget {
  final Map<String, dynamic> projectData;

  const AddAllocatedUser({super.key, required this.projectData});

  @override
  State<AddAllocatedUser> createState() => _AddAllocatedUserState();
}

class _AddAllocatedUserState extends State<AddAllocatedUser> {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  String? teamLeadName;
  List<DropdownMenuItem<String>> userItems = [];
  String teamLeadID = '';
  List<Map<String, dynamic>> users = [];
  TextEditingController userAllocationController = TextEditingController();
  String? selectedUserDocumentId;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: CupertinoColors.white,
        ),
        backgroundColor: kAppBarColor,
        title: const Text(
          'Allocate User',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: DropdownButtonFormField<String>(
                  value: selectedUserDocumentId,
                  items: userItems,
                  onChanged: (value) {
                    setState(() {
                      selectedUserDocumentId = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'User',
                    labelStyle: TextStyle(
                      // fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.black,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              textFormField(
                obscureText: false,
                controller: userAllocationController,
                labelText: "User Allocation (%)",
                keyboardType: TextInputType.number,
                inputFormatNumber: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "User Allocation is required";
                  }
                  int allocation = int.tryParse(value.trim()) ?? 0;
                  if (allocation < 1 || allocation > 100) {
                    return "User Allocation must be between 1 and 100";
                  }
                  return null;
                },
              ),
            ],
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: button(
              onPressed: setUserAllocation,
              buttonName: 'Confirm',
              textColor: CupertinoColors.white,
              backgroundColor: CupertinoColors.black,
            ),
          ),
        ],
      ),
    );
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
                child: Text(
                  doc['name'],
                ),
              ))
          .toList();
    });
  }

  Future<void> setUserAllocation() async {
    if (selectedUserDocumentId != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(selectedUserDocumentId)
          .get();
      final userID = userDoc['userID'];

      final querySnapshot = await FirebaseFirestore.instance
          .collection('projects')
          .where('projectID', isEqualTo: widget.projectData["projectID"])
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final projectSnapshot = querySnapshot.docs.first;
        final projectData = projectSnapshot.data() as Map<String, dynamic>?;

        if (projectData != null) {
          await FirebaseFirestore.instance.collection('allocatedUser').add({
            'userID': userID,
            'projectID': widget.projectData["projectID"],
            'userAllocation': userAllocationController.text.trim().toString(),
            'managementPoints': "0",
            'workPoints': "0",
            'startDate': getFormattedDateTime(),
            'endDate': "",
            'isDisabled': false,
          });
          showSnackBar(context: context, message: "User Selected Successfully");
          Navigator.pop(context);
        } else {
          throw ('Document data is null or empty');
        }
      } else {
        throw ('Level with ID ${widget.projectData["projectID"]} not found.');
      }
    }
  }
}
