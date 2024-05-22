import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/components/button.dart';
import 'package:ppmt/components/dateFormat.dart';
import 'package:ppmt/components/snackbar.dart';
import 'package:ppmt/components/textfield.dart';
import 'package:ppmt/constants/color.dart';
import 'package:intl/intl.dart';

class AddProject extends StatefulWidget {
  final String projectID;
  final String projectName;
  final String description;
  final String startDate;
  final String endDate;
  final String projectCreator;
  final String projectStatus;
  final String managementPoints;
  final String totalBonus;

  const AddProject({
    super.key,
    required this.projectID,
    required this.projectName,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.projectCreator,
    required this.projectStatus,
    required this.managementPoints,
    required this.totalBonus,
  });

  @override
  State<AddProject> createState() => _AddProjectState();
}

class _AddProjectState extends State<AddProject> {
  final formKey = GlobalKey<FormState>();
  TextEditingController projectNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController managementPointsController = TextEditingController();
  TextEditingController totalBonusController = TextEditingController();
  TextEditingController userAllocationController = TextEditingController();
  String projectCreator = "";
  String projectStatus = "";
  DateTime? startDate;
  DateTime? endDate;
  String? selectedUserId;
  String? selectedUserDocumentId;
  List<DropdownMenuItem<String>> userItems = [];

  bool get isEditable =>
      projectStatus == 'To Do' || projectStatus == 'In Progress';

  @override
  void initState() {
    super.initState();
    // Set default values for management points and total bonus
    managementPointsController.text =
        widget.managementPoints.isNotEmpty ? widget.managementPoints : "20";
    totalBonusController.text =
        widget.totalBonus.isNotEmpty ? widget.totalBonus : "0";
    fetchUsers();
    fetchCurrentUserEmail();
    projectStatus = "To Do";
    if (widget.projectID != "") {
      projectNameController.text = widget.projectName;
      descriptionController.text = widget.description;
      managementPointsController.text = widget.managementPoints;
      totalBonusController.text = widget.totalBonus;
      projectCreator = widget.projectCreator;
      projectStatus = widget.projectStatus;

      // Check if startDate and endDate are not empty strings before parsing
      if (widget.startDate.isNotEmpty) {
        try {
          startDate = DateFormat('yyyy-MM-dd').parse(widget.startDate);
        } catch (e) {
          print('Error parsing startDate: $e');
        }
      }
      if (widget.endDate.isNotEmpty) {
        try {
          endDate = DateFormat('yyyy-MM-dd').parse(widget.endDate);
        } catch (e) {
          print('Error parsing endDate: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    projectNameController.dispose();
    descriptionController.dispose();
    managementPointsController.dispose();
    totalBonusController.dispose();
    super.dispose();
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

  Future<void> setTeamLead() async {
    if (selectedUserDocumentId != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(selectedUserDocumentId)
          .get();
      final userId = userDoc['userID'];

      final querySnapshot = await FirebaseFirestore.instance
          .collection('projects')
          .where('projectID', isEqualTo: widget.projectID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final projectSnapshot = querySnapshot.docs.first;
        final projectData = projectSnapshot.data() as Map<String, dynamic>?;

        if (projectData != null) {
          await projectSnapshot.reference.update({
            'teamLeadID': userId,
            "userAllocation": userAllocationController.text.trim().toString()
          }).then(
            (value) {
              Navigator.pop(context);
            },
          ).then(
            (value) {
              Navigator.pop(context);
            },
          );
          showSnackBar(
              context: context, message: "Team Lead Selected Successfully");
        } else {
          throw ('Document data is null or empty');
        }
      } else {
        throw ('Level with ID ${widget.projectID} not found.');
      }
    }
  }

  String generateProjectID() {
    return DateFormat('ddMMyyyyHHmmss').format(DateTime.now());
  }

  Future<void> submit() async {
    if (formKey.currentState!.validate()) {
      try {
        if (widget.projectID.isNotEmpty) {
          await updateProject();
          showSnackBar(
              context: context, message: "Project Updated Successfully");
        } else {
          await addProject();
          showSnackBar(context: context, message: "Project Added Successfully");
        }
        Navigator.of(context).pop();
      } catch (e) {
        showSnackBar(context: context, message: "Error: $e");
      }
    }
  }

  Future<void> fetchCurrentUserEmail() async {
    User user = FirebaseAuth.instance.currentUser!;
    setState(() {
      projectCreator = user.email!;
    });
  }

  Future<void> addProject() async {
    String projectID = generateProjectID();
    try {
      await FirebaseFirestore.instance.collection('projects').add({
        'projectID': projectID.toString(),
        'projectName': projectNameController.text.trim().toString(),
        'projectDescription': descriptionController.text.trim().toString(),
        'startDate': "",
        'endDate': "",
        'projectStatus': projectStatus.toString(),
        'projectCreator': projectCreator.toString(),
        'managementPoints': managementPointsController.text,
        'totalBonus': totalBonusController.text,
      });
    } catch (e) {
      throw ('Error adding Project: $e');
    }
  }

  Future<void> updateProject() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('projects')
          .where('projectID', isEqualTo: widget.projectID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final projectSnapshot = querySnapshot.docs.first;
        final projectData = projectSnapshot.data() as Map<String, dynamic>?;

        if (projectData != null) {
          await projectSnapshot.reference.update({
            'projectName': projectNameController.text.trim().toString(),
            'projectDescription': descriptionController.text.trim().toString(),
            'managementPoints': managementPointsController.text,
            'totalBonus': totalBonusController.text,
          });
        } else {
          throw ('Document data is null or empty');
        }
      } else {
        throw ('Level with ID ${widget.projectID} not found.');
      }
    } catch (e) {
      throw ('Error updating Project details: $e');
    }
  }

  Future<void> updateProjectStatusToInProgress() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('projects')
          .where('projectID', isEqualTo: widget.projectID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final projectSnapshot = querySnapshot.docs.first;
        final projectData = projectSnapshot.data() as Map<String, dynamic>?;

        if (projectData != null) {
          await projectSnapshot.reference.update({
            "projectStatus": "In Progress",
            "startDate": getFormattedDateTime()
          });

          showGeneralDialog(
            context: context,
            barrierDismissible: false,
            barrierLabel:
                MaterialLocalizations.of(context).modalBarrierDismissLabel,
            barrierColor: Colors.black45,
            transitionDuration: const Duration(milliseconds: 200),
            pageBuilder: (BuildContext buildContext, Animation animation,
                Animation secondaryAnimation) {
              return Scaffold(
                appBar: AppBar(
                  iconTheme: IconThemeData(
                    color: CupertinoColors.white,
                  ),
                  backgroundColor: kAppBarColor,
                  title: Text(
                    'Select Team Lead',
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
                              labelText: 'Team Lead',
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
                          enabled: isEditable,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "User Allocation is required";
                            }
                            // Parse the entered value as an integer
                            int allocation = int.tryParse(value.trim()) ?? 0;
                            // Check if the value is between 1 and 100
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
                        onPressed: setTeamLead,
                        buttonName: 'Confirm',
                        textColor: CupertinoColors.white,
                        backgroundColor: CupertinoColors.black,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          throw ('Document data is null or empty');
        }
      } else {
        throw ('Level with ID ${widget.projectID} not found.');
      }
    } catch (e) {
      throw ('Error updating Project details: $e');
    }
  }

  Future<void> updateProjectStatusToComplete() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('projects')
          .where('projectID', isEqualTo: widget.projectID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final projectSnapshot = querySnapshot.docs.first;
        final projectData = projectSnapshot.data() as Map<String, dynamic>?;

        if (projectData != null) {
          await projectSnapshot.reference.update({
            "projectStatus": "Completed",
            "endDate": getFormattedDateTime()
          }).then(
            (value) {
              Navigator.of(context).pop();
            },
          );
        } else {
          throw ('Document data is null or empty');
        }
      } else {
        throw ('Level with ID ${widget.projectID} not found.');
      }
    } catch (e) {
      throw ('Error updating Project details: $e');
    }
  }

  Future<void> deleteProject() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('projects')
          .where('projectID', isEqualTo: widget.projectID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final projectSnapshot = querySnapshot.docs.first;
        final projectData = projectSnapshot.data() as Map<String, dynamic>?;

        if (projectData != null) {
          await projectSnapshot.reference.delete().then(
            (value) {
              Navigator.of(context).pop();
            },
          );
          showSnackBar(
              message: "Project Deleted Successfully", context: context);
        } else {
          throw ('Document data is null or empty');
        }
      } else {
        throw ('Level with ID ${widget.projectID} not found.');
      }
    } catch (e) {
      throw ('Error deleting Project details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.projectID == ""
          ? AppBar(
              iconTheme: IconThemeData(
                color: CupertinoColors.white,
              ),
              backgroundColor: kAppBarColor,
              title: Text(
                widget.projectID != "" ? 'Update Project' : 'Add Project',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.white,
                ),
              ),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              textFormField(
                obscureText: false,
                keyboardType: TextInputType.text,
                controller: projectNameController,
                labelText: "Project Name",
                enabled: isEditable,
                maxLength: 30,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Project Name is required";
                  }
                  return null;
                },
              ),
              textFormField(
                obscureText: false,
                keyboardType: TextInputType.text,
                controller: descriptionController,
                labelText: "Description",
                maxLength: 1000,
                maxLine: 5,
                enabled: isEditable,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Project Description is required";
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 5, 0, 0),
                child: ListTile(
                  title: Text(
                    'Start Date',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    startDate != null
                        ? getFormattedDateTime(dateToFormat: startDate)
                        : 'Not Set',
                  ),
                  enabled: false,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 5, 0, 0),
                child: ListTile(
                  title: Text(
                    'End Date',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    endDate != null
                        ? getFormattedDateTime(dateToFormat: endDate)
                        : 'Not Set',
                  ),
                  enabled: false,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Creator',
                  ),
                  initialValue: projectCreator,
                  enabled: false,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Status',
                  ),
                  initialValue: projectStatus,
                  enabled: false,
                ),
              ),
              textFormField(
                obscureText: false,
                controller: managementPointsController,
                labelText: "Management Points (%)",
                keyboardType: TextInputType.number,
                inputFormatNumber: 3,
                enabled: isEditable,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Management Points are required";
                  }
                  // Parse the entered value as an integer
                  int points = int.tryParse(value.trim()) ?? 0;
                  // Check if the value is between 1 and 100
                  if (points < 1 || points > 100) {
                    return "Management Points must be between 1 and 100";
                  }
                  return null;
                },
              ),
              textFormField(
                obscureText: false,
                controller: totalBonusController,
                labelText: "Total Bonus",
                keyboardType: TextInputType.number,
                enabled: isEditable,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Total Bonus is required";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              isEditable
                  ? button(
                      onPressed: submit,
                      buttonName: 'Save',
                      backgroundColor: CupertinoColors.black,
                      textColor: CupertinoColors.white)
                  : Container(),
              SizedBox(height: 10),
              widget.projectID != "" &&
                      projectStatus != "In Progress" &&
                      projectStatus != "Completed"
                  ? button(
                      onPressed: updateProjectStatusToInProgress,
                      buttonName: 'Kick Off',
                      backgroundColor: CupertinoColors.activeOrange,
                      textColor: CupertinoColors.black)
                  : Container(),
              SizedBox(height: 10),
              projectStatus == "In Progress"
                  ? button(
                      onPressed: updateProjectStatusToComplete,
                      buttonName: 'Complete',
                      backgroundColor: CupertinoColors.activeGreen,
                      textColor: CupertinoColors.white)
                  : Container(),
              SizedBox(height: 10),
              widget.projectID != "" &&
                      widget.projectStatus != "In Progress" &&
                      widget.projectStatus != "Completed"
                  ? button(
                      onPressed: deleteProject,
                      buttonName: 'Delete',
                      backgroundColor: CupertinoColors.destructiveRed,
                      textColor: CupertinoColors.white)
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
