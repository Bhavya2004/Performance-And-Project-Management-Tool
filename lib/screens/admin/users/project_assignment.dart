import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProjectAssignment extends StatefulWidget {
  final String userID;

  const ProjectAssignment({Key? key, required this.userID}) : super(key: key);

  @override
  State<ProjectAssignment> createState() => _ProjectAssignmentState();
}

class _ProjectAssignmentState extends State<ProjectAssignment> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: 'Team Lead Projects'),
                Tab(text: 'Allocated Projects'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildProjectList('teamLeadID'),
                  _buildProjectList('allocated_users'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectList(String field) {
    if (field == 'allocated_users') {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('allocated_users')
            .where('UserID', isEqualTo: widget.userID)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          print('Fetched allocated user documents: ${snapshot.data!.docs.length}');
          return FutureBuilder<List<DocumentSnapshot>>(
            future: _fetchProjects(snapshot.data!.docs),
            builder: (context, projectSnapshot) {
              if (!projectSnapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView.builder(
                itemCount: projectSnapshot.data!.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot doc = projectSnapshot.data![index];
                  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(data['projectName']),
                    subtitle: Text('Role: Allocated Member'),
                  );
                },
              );
            },
          );
        },
      );
    } else {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('projects')
            .where('teamLeadID', isEqualTo: widget.userID)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = snapshot.data!.docs[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['projectName']),
                subtitle: Text('Role: Team Lead'),
              );
            },
          );
        },
      );
    }
  }

  Future<List<DocumentSnapshot>> _fetchProjects(List<DocumentSnapshot> allocatedUserDocs) async {
    List<DocumentSnapshot> projectDocs = [];
    for (var doc in allocatedUserDocs) {
      DocumentSnapshot projectDoc = await FirebaseFirestore.instance
          .collection('projects')
          .doc(doc['projectID'])
          .get();
      print('Fetched project document: ${projectDoc.id}');
      projectDocs.add(projectDoc);
    }
    return projectDocs;
  }
}