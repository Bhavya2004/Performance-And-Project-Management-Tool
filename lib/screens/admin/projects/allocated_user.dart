import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AllocatedUser extends StatefulWidget {
  final String projectID;
  AllocatedUser({required this.projectID});

  @override
  _AllocatedUserState createState() => _AllocatedUserState();
}

class _AllocatedUserState extends State<AllocatedUser> {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  String? teamLeadName = FirebaseAuth.instance.currentUser?.displayName!;
  String teamLeadID = '';
  List<Map<String, dynamic>> users = [];
  String? selectedUserID;
  double _currentSliderValue = 0.0;
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _mgmtPointsController = TextEditingController();
  final TextEditingController _workPointsController = TextEditingController();
  final TextEditingController userAllocationController = TextEditingController();
  String? selectedUserDocumentId;

  @override
  void initState() {
    super.initState();
    fetchProjectData();
    fetchUsers();
  }

  Future<void> fetchProjectData() async {
    try {
      final projectSnapshot = await firebaseFirestore.collection('projects').doc(widget.projectID).get();
      if (projectSnapshot.exists) {
        final projectData = projectSnapshot.data() as Map<String, dynamic>;
        if (projectData != null) {
          teamLeadID = projectData['teamLeadID'];
          await fetchTeamLeadName(teamLeadID);
        }
      } else {
        print('Project snapshot does not exist');
      }
    } catch (e) {
      print('Error fetching project data: $e');
    }
  }

  Future<void> fetchTeamLeadName(String teamLeadID) async {
    try {
      DocumentSnapshot teamLeadSnapshot = await firebaseFirestore.collection('projects').doc(teamLeadID).get();
      print(teamLeadSnapshot.data());
      if (teamLeadSnapshot.exists) {

        setState(() {
          teamLeadName = teamLeadSnapshot['name'];
        });
      } else {
        print('Team lead snapshot does not exist');
      }
    } catch (e) {
      print('Error fetching team lead name: $e');
    }
  }
  Future<void> fetchUsers() async {
    try {
      QuerySnapshot userSnapshot = await firebaseFirestore.collection('users').get();
      List<Map<String, dynamic>> userList = userSnapshot.docs.map((doc) {
        return {
          'userID': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();

      // Filter out the team lead
      userList = userList.where((user) => user['userID'] != teamLeadID).toList();

      setState(() {
        users = userList;
      });
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  Future<void> saveAllocation() async {
    try {
      // Check if the user is already allocated
      QuerySnapshot existingAllocations = await firebaseFirestore
          .collection('allocated_users')
          .where('UserID', isEqualTo: selectedUserID)
          .where('ProjectID', isEqualTo: widget.projectID)
          .get();

      if (existingAllocations.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User is already allocated to this project')));
        return;
      }

      await firebaseFirestore.collection('allocated_users').add({
        'UserID': selectedUserID,
        'ProjectID': widget.projectID,
        'Allocation%': _currentSliderValue,
        'Mgmt_Points': int.parse(_mgmtPointsController.text),
        'Work_Points': int.parse(_workPointsController.text),
        'StartDate': _startDateController.text,
        'EndDate': _endDateController.text,
        'disabled': false, // Add a field to track if the user is disabled
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User allocation saved successfully')));
    } catch (e) {
      print('Error saving allocation: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving allocation')));
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> toggleUserStatus(String docID, bool isDisabled) async {
    try {
      await firebaseFirestore.collection('allocated_users').doc(docID).update({
        'disabled': !isDisabled,
      });
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User status updated')));
    } catch (e) {
      print('Error updating user status: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating user status')));
    }
  }

  Future<void> setTeamLead() async {
    if (selectedUserDocumentId != null) {
      final userDoc = await firebaseFirestore.collection('users').doc(selectedUserDocumentId).get();
      final userId = userDoc['userID'];

      final querySnapshot = await firebaseFirestore.collection('projects').doc(widget.projectID).get();

      if (querySnapshot.exists) {
        final projectData = querySnapshot.data() as Map<String, dynamic>?;

        if (projectData != null) {
          await querySnapshot.reference.update({
            'teamLeadID': userId,
            "userAllocation": userAllocationController.text.trim().toString()
          }).then((value) {
            Navigator.pop(context);
            showSnackBar(context: context, message: "Team Lead Selected Successfully");
          });
        } else {
          throw ('Document data is null or empty');
        }
      } else {
        throw ('Project with ID ${widget.projectID} not found.');
      }
    }
  }

  void showSnackBar({required BuildContext context, required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showChangeTLDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Team Lead'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedUserDocumentId,
                hint: Text('Select User'),
                items: users.map((user) {
                  return DropdownMenuItem<String>(
                    value: user['userID'],
                    child: Text(user['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedUserDocumentId = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Team Lead',
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: userAllocationController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'User Allocation (%)',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Confirm'),
              onPressed: setTeamLead,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.group, color: Colors.blue),
                title: Text(
                  "$teamLeadName's Team",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Form(
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedUserID,
                      hint: Text('Select User'),
                      items: users.map((user) {
                        return DropdownMenuItem<String>(
                          value: user['userID'],
                          child: Text(user['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedUserID = value;
                        });
                      },
                      decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'User'),
                    ),
                    SizedBox(height: 10),
                    Text('Allocation%: ${_currentSliderValue.round()}'),
                    Slider(
                      value: _currentSliderValue,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      onChanged: (double value) {
                        setState(() {
                          _currentSliderValue = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _startDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Start Date',
                        border: OutlineInputBorder(),
                      ),
                      onTap: () => _selectDate(context, _startDateController),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _endDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'End Date',
                        border: OutlineInputBorder(),
                      ),
                      onTap: () => _selectDate(context, _endDateController),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _mgmtPointsController,
                      decoration: InputDecoration(labelText: 'Management Points', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _workPointsController,
                      decoration: InputDecoration(labelText: 'Work Points', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      child: Text('Add'),
                      onPressed: selectedUserID != null ? saveAllocation : null,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: firebaseFirestore.collection('allocated_users').where('ProjectID', isEqualTo: widget.projectID).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No allocated users'));
                  }

                  List<Map<String, dynamic>> allocatedUsers = snapshot.data!.docs.map((doc) {
                    final docData = doc.data() as Map<String, dynamic>;
                    return {
                      'docID': doc.id,
                      'userID': docData['UserID'],
                      'userName': users.firstWhere((user) => user['userID'] == docData['UserID'], orElse: () => {'name': 'Unknown'})['name'],
                      'allocation': docData['Allocation%'],
                      'startDate': docData['StartDate'],
                      'endDate': docData['EndDate'],
                      'mgmtPoints': docData['Mgmt_Points'],
                      'workPoints': docData['Work_Points'],
                      'disabled': docData['disabled'] ?? false,
                    };
                  }).toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: allocatedUsers.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> user = allocatedUsers[index];
                      return Card(
                        child: ListTile(
                          title: Text('Name: ${user['userName']}'),
                          subtitle: Text(
                              'Allocation: ${user['allocation']}%\nStart Date: ${user['startDate']}\nEnd Date: ${user['endDate']}\nManagement Points: ${user['mgmtPoints']}\nWork Points: ${user['workPoints']}'),
                          trailing: IconButton(
                            icon: Icon(user['disabled'] ? Icons.visibility_off : Icons.visibility, color: user['disabled'] ? Colors.red : Colors.green),
                            onPressed: () => toggleUserStatus(user['docID'], user['disabled']),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    child: Text('Calculate Points'),
                    onPressed: () {
                      // Handle calculate points button press
                    },
                  ),
                  ElevatedButton(
                    child: Text('Change TL'),
                    onPressed: _showChangeTLDialog,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
