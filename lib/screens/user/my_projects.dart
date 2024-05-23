import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/constants/color.dart';
import 'project_details.dart';

class MyProjects extends StatefulWidget {
  @override
  _MyProjectsState createState() => _MyProjectsState();
}

class _MyProjectsState extends State<MyProjects> {
  String searchText = '';
  Set<String> _selectedStatuses = {'All'}; // Initialize with 'All' to show all projects
  String userId = '';

  @override
  void initState() {
    super.initState();
    fetchCurrentUserId();
  }

  Future<void> fetchCurrentUserId() async {
    User user = FirebaseAuth.instance.currentUser!;
    setState(() {
      userId = user.uid;
    });
    print('Current User ID: $userId'); // Debug statement
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
                  selected: _selectedStatuses.contains('To Do'),
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        _selectedStatuses.add('To Do');
                        _selectedStatuses.remove('All');
                      } else {
                        _selectedStatuses.remove('To Do');
                      }
                      if (_selectedStatuses.isEmpty) {
                        _selectedStatuses.add('All');
                      }
                    });
                  },
                ),
                FilterChip(
                  label: Text('In Progress'),
                  selectedColor: Colors.yellow[300],
                  selected: _selectedStatuses.contains('In Progress'),
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        _selectedStatuses.add('In Progress');
                        _selectedStatuses.remove('All');
                      } else {
                        _selectedStatuses.remove('In Progress');
                      }
                      if (_selectedStatuses.isEmpty) {
                        _selectedStatuses.add('All');
                      }
                    });
                  },
                ),
                FilterChip(
                  label: Text('Completed'),
                  selectedColor: Colors.green[300],
                  selected: _selectedStatuses.contains('Completed'),
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        _selectedStatuses.add('Completed');
                        _selectedStatuses.remove('All');
                      } else {
                        _selectedStatuses.remove('Completed');
                      }
                      if (_selectedStatuses.isEmpty) {
                        _selectedStatuses.add('All');
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
                stream: FirebaseFirestore.instance
                    .collection('projects')
                    .where('teamLeadID', isEqualTo: userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CupertinoActivityIndicator(
                        color: kAppBarColor,
                      ),
                    );
                  }
                  // Print the fetched documents
                  print('Fetched Projects: ${snapshot.data!.docs.length}');
                  snapshot.data!.docs.forEach((doc) {
                    print(doc.data());
                  });

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot doc = snapshot.data!.docs[index];
                      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                      if (_shouldShowProject(data)) {
                        return buildCard(context, doc, data);
                      } else {
                        return SizedBox();
                      }
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

  Widget buildCard(BuildContext context, DocumentSnapshot document, Map<String, dynamic> data) {
    Color cardColor = _getStatusColor(data['projectStatus']);
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
                        builder: (context) => ProjectDetails(
                          projectId: document.id,
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
    if (_selectedStatuses.contains('All')) {
      return true;
    }
    if (!_selectedStatuses.contains(data['projectStatus'])) {
      return false;
    }
    if (searchText.isEmpty) {
      return true;
    }
    return data['projectName'].toString().toLowerCase().contains(searchText);
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
