import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  void initState() {
    super.initState();
    print(widget.userID);
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
                stream: FirebaseFirestore.instance
                    .collection('projects')
                    .where('teamLeadID', isEqualTo: widget.userID)
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
    if (searchText.isNotEmpty && !data['projectName'].toString().toLowerCase().contains(searchText)) {
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
