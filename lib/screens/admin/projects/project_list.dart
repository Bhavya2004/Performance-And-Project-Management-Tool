import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/screens/admin/projects/project_details.dart';
import 'add_project.dart';

class Projects extends StatefulWidget {
  const Projects({super.key});

  @override
  State<Projects> createState() => _ProjectsState();
}

class _ProjectsState extends State<Projects> {
  String searchText = '';
  String _selectedStatus = 'All'; // Initialize with 'All' to show all projects

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: CupertinoColors.white,
        ),
        backgroundColor: kAppBarColor,
        title: Text(
          'Projects',
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
                  selected: _selectedStatus == 'To Do',
                  onSelected: (value) {
                    setState(() {
                      _selectedStatus = value ? 'To Do' : 'All';
                    });
                  },
                ),
                FilterChip(
                  label: Text('In Progress'),
                  selectedColor: Colors.yellow[300],
                  selected: _selectedStatus == 'In Progress',
                  onSelected: (value) {
                    setState(() {
                      _selectedStatus = value ? 'In Progress' : 'All';
                    });
                  },
                ),
                FilterChip(
                  label: Text('Completed'),
                  selectedColor: Colors.green[300],
                  selected: _selectedStatus == 'Completed',
                  onSelected: (value) {
                    setState(() {
                      _selectedStatus = value ? 'Completed' : 'All';
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
                    searchText = value
                        .toLowerCase(); // Convert search text to lowercase for case-insensitive comparison
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
                    .orderBy('projectID')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CupertinoActivityIndicator(
                        color: kAppBarColor,
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot doc = snapshot.data!.docs[index];
                      Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;
                      if (_shouldShowProject(data)) {
                        return buildCard(context, doc, data);
                      } else {
                        return SizedBox(); // Return an empty SizedBox if project should not be shown
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).pushNamed('/add_project');
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget buildCard(BuildContext context, DocumentSnapshot document,
      Map<String, dynamic> data) {
    Color cardColor = _getStatusColor(data['projectStatus']);

    return Card(
      margin: EdgeInsets.all(10),
      color: cardColor,
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              child: Text(
                data['projectName'],
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    CupertinoIcons.info_circle_fill,
                    color: kAppBarColor,
                  ),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProjectDetails(
                          projectData: data, // Pass the project data
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
    if (_selectedStatus != 'All' && data['projectStatus'] != _selectedStatus) {
      return false; // If the project status doesn't match the selected status, don't show it
    }
    if (searchText.isEmpty) {
      return true; // Show all projects if search text is empty
    }
    // Check if the project name contains the search text (case-insensitive)
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