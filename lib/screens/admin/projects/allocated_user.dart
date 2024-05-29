import 'package:cloud_firestore/cloud_firestore.dart';
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
  String? teamLeadName;
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

  final _formKey = GlobalKey<FormState>();
  String? _selectedUser;
  String? _allocationPercentage;

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
      DocumentSnapshot teamLeadSnapshot = await firebaseFirestore.collection('users').doc(teamLeadID).get();
      if (teamLeadSnapshot.exists) {
        setState(() {
          teamLeadName = teamLeadSnapshot['name'];
        });
      } else {
        print('Team lead snapshot does not exist');
        setState(() {
          teamLeadName = 'Not found';
        });
      }
    } catch (e) {
      print('Error fetching team lead name: $e');
      setState(() {
        teamLeadName = 'Error';
      });
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

      userList = userList.where((user) => user['userID'] != teamLeadID && user['role'] != 'admin').toList();

      setState(() {
        users = userList;
      });
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  Future<void> saveAllocation() async {
    try {
      QuerySnapshot existingAllocations = await firebaseFirestore
          .collection('allocated_users')
          .where('UserID', isEqualTo: selectedUserID)
          .where('ProjectID', isEqualTo: widget.projectID)
          .get();

      if (existingAllocations.docs.isNotEmpty) {
        showSnackBar(context: context, message: 'User is already allocated to this project');
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
        'disabled': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User allocation saved successfully')));
    } catch (e) {
      print('Error saving allocation: $e');
      showSnackBar(context: context, message: 'Error saving allocation');
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
        'EndDate': !isDisabled ? DateFormat('yyyy-MM-dd').format(DateTime.now()) : '', // Set end date to current date if user is disabled
      });
      setState(() {});
      showSnackBar(context: context, message: 'User status updated');
    } catch (e) {
      print('Error updating user status: $e');
      showSnackBar(context: context, message: 'Error updating user status');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Add User'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedUser,
                      hint: Text('Select User'),
                      items: users.map((user) {
                        return DropdownMenuItem<String>(
                          value: user['userID'],
                          child: Text(user['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedUser = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a user';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _allocationPercentage,
                      decoration: InputDecoration(
                        labelText: 'Allocation%',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the allocation percentage';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _allocationPercentage = value;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: Text('Add'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // Check if the user is already allocated
                    QuerySnapshot existingAllocations = await firebaseFirestore
                        .collection('allocated_users')
                        .where('UserID', isEqualTo: _selectedUser)
                        .where('ProjectID', isEqualTo: widget.projectID)
                        .get();

                    if (existingAllocations.docs.isNotEmpty) {
                      // If the user is already allocated, show an error message
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User is already allocated to this project')));
                    } else {
                      // If the user is not allocated, add them
                      firebaseFirestore.collection('allocated_users').add({
                        'UserID': _selectedUser,
                        'ProjectID': widget.projectID,
                        'Allocation%': double.parse(_allocationPercentage!),
                        'StartDate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                        'EndDate': '',
                        'Mgmt_Points': 0,
                        'Work_Points': 0,
                        'disabled': false,
                      });
                      Navigator.of(context).pop();
                    }
                  }
                },
              ),
            ],
          ),
        ),
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firebaseFirestore.collection('allocated_users').where('ProjectID', isEqualTo: widget.projectID).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Ensure team lead is displayed even if no users are allocated
          List<Map<String, dynamic>> allocatedUsers = [];
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            allocatedUsers = snapshot.data!.docs.map((doc) {
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
          }

          return Column(
            children: [
              ListTile(
                title: Text('Team Lead: ${teamLeadName}'),
              ),
              Expanded(
                child: allocatedUsers.isEmpty
                    ? Center(child: Text('No allocated users'))
                    : ListView.builder(
                  itemCount: allocatedUsers.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> user = allocatedUsers[index];
                    return ExpansionTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${user['userName']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: Icon(user['disabled'] ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => toggleUserStatus(user['docID'], user['disabled']),
                          ),
                        ],
                      ),
                      children: [
                        ListTile(
                          title: Text('Start Date: ${user['startDate']}'),
                        ),
                        ListTile(
                          title: Text('End Date: ${user['endDate']}'),
                        ),
                        ListTile(
                          title: Text('Management Points: ${user['mgmtPoints']}'),
                        ),
                        ListTile(
                          title: Text('Work Points: ${user['workPoints']}'),
                        ),
                        ListTile(
                          title: Text('Disabled: ${user['disabled']}'),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
