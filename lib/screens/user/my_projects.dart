import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/screens/admin/projects/project_details.dart';

class MyProjects extends StatefulWidget {
  final String userID;

  MyProjects({Key? key, required this.userID}) : super(key: key);

  @override
  _MyProjectsState createState() => _MyProjectsState();
}

class _MyProjectsState extends State<MyProjects> {
  String searchText = '';
  Set<String> selectedStatuses = {'All'};
  String userId = '';
  bool isTeamLead = false;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    print(widget.userID);
  }

  Future<void> checkUserRole() async {
    try {
      String? currentUserID = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserID != null) {
        DocumentSnapshot userSnapshot = await firebaseFirestore
            .collection('users')
            .doc(currentUserID)
            .get();

        if (userSnapshot.exists) {
          setState(() {
            isTeamLead = userSnapshot['userID'] == widget.userID;
          });
        }
      }
    } catch (e) {
      print('Error checking user role: $e');
    }
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
          'My Projects',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Wrap(
              spacing: 8.0,
              children: [
                FilterChip(
                  label: Text('To Do'),
                  selectedColor: Colors.grey[300],
                  selected: selectedStatuses.contains('To Do'),
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        selectedStatuses.add('To Do');
                        selectedStatuses.remove('All');
                      } else {
                        selectedStatuses.remove('To Do');
                      }
                      if (selectedStatuses.isEmpty) {
                        selectedStatuses.add('All');
                      }
                    });
                  },
                ),
                FilterChip(
                  label: Text('In Progress'),
                  selectedColor: Colors.yellow[300],
                  selected: selectedStatuses.contains('In Progress'),
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        selectedStatuses.add('In Progress');
                        selectedStatuses.remove('All');
                      } else {
                        selectedStatuses.remove('In Progress');
                      }
                      if (selectedStatuses.isEmpty) {
                        selectedStatuses.add('All');
                      }
                    });
                  },
                ),
                FilterChip(
                  label: Text('Completed'),
                  selectedColor: Colors.green[300],
                  selected: selectedStatuses.contains('Completed'),
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        selectedStatuses.add('Completed');
                        selectedStatuses.remove('All');
                      } else {
                        selectedStatuses.remove('Completed');
                      }
                      if (selectedStatuses.isEmpty) {
                        selectedStatuses.add('All');
                      }
                    });
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchText = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Search Projects',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: isTeamLead
                    ? FirebaseFirestore.instance
                    .collection('projects')
                    .where('teamLeadID', isEqualTo: widget.userID)
                    .snapshots()
                    : FirebaseFirestore.instance
                    .collection('allocatedUser')
                    .where('userID', isEqualTo: widget.userID)
                    .snapshots(),
                builder: (context, snapshot) {
                  print("object");
                  if (!snapshot.hasData) {
                    print("object not found");

                    return Center(
                      child: CupertinoActivityIndicator(
                        color: kAppBarColor,
                      ),
                    );
                  }
                  print(snapshot.data!.docs.length);
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot doc = snapshot.data!.docs[index];
                      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                      print("$data-----------");

                      return FutureBuilder<Map<String, dynamic>>(
                        future: _fetchProjectData(data["projectID"]),
                        builder: (context, projectSnapshot) {
                          if (projectSnapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (projectSnapshot.hasError) {
                            return Text('Error: ${projectSnapshot.error}');
                          } else if (!projectSnapshot.hasData) {
                            return Text('No project data found');
                          }

                          Map<String, dynamic> mapData = projectSnapshot.data!;
                          if (_shouldShowProject(data)) {
                            return buildCard(context, doc, mapData);
                          } else {
                            return SizedBox();
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCard(BuildContext context, DocumentSnapshot document,
      Map<String, dynamic> data) {
    String status="In Progress";

    FirebaseFirestore.instance
        .collection('projects')
        .where('projectID', isEqualTo: data["projectID"])
        .get()
        .then((QuerySnapshot querySnapshot) {
      // Handle the results of the query
      if (querySnapshot.docs.isNotEmpty) {
        // Process the data
        status= querySnapshot.docs[0]["projectStatus"];
      } else {
        print("No documents found");
      }
    }).catchError((error) {
      print("Error getting documents: $error");
    });
    print("-------------$data");
    Color cardColor = _getStatusColor(status);
    return Card(
      margin: EdgeInsets.all(10),
      color: cardColor,
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              data['projectName'],
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    CupertinoIcons.info_circle_fill,
                    color: CupertinoColors.black,
                  ),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProjectDetails(
                              projectData: data,
                            ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowProject(Map<String, dynamic> data) {
    if (searchText.isNotEmpty &&
        !data['projectName'].toString().toLowerCase().contains(searchText)) {
      return false;
    }
    if (selectedStatuses.contains('All')) {
      return true;
    }
    return selectedStatuses.contains(data['projectStatus']);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'To Do':
        return Colors.grey[300]!;
      case 'In Progress':
        return Colors.yellow[300]!;
      case 'Completed':
        return Colors.green[300]!;
      default:
        return Colors.white;
    }
  }
}

Future<Map<String, dynamic>> _fetchProjectData(String projectID) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('projects')
        .where('projectID', isEqualTo: projectID)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs[0].data() as Map<String, dynamic>;
    } else {
      print("No documents found");
      return {};
    }
  } catch (error) {
    print("Error getting documents: $error");
    throw error;
  }
}