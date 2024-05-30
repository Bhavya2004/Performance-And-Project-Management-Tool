import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/screens/admin/projects/add_allocated_user.dart';
import 'package:ppmt/screens/admin/projects/allocated_user_detail.dart';

class AllocatedUser extends StatefulWidget {
  final Map<String, dynamic> projectData;

  AllocatedUser({required this.projectData});

  @override
  _AllocatedUserState createState() => _AllocatedUserState();
}

class _AllocatedUserState extends State<AllocatedUser> {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  String? teamLeadName;
  String teamLeadID = '';
  bool isTeamLead = false;

  @override
  void initState() {
    super.initState();
    checkUserRole();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('allocatedUser')
            .where('projectID', isEqualTo: widget.projectData['projectID'])
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CupertinoActivityIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text('No data available'),
            );
          }

          List<DocumentSnapshot> documents = snapshot.data!.docs;

          // Sort the documents to have the team lead at the top
          documents.sort((a, b) {
            if (a['userID'] == widget.projectData['teamLeadID']) {
              return -1;
            } else if (b['userID'] == widget.projectData['teamLeadID']) {
              return 1;
            }
            return 0;
          });

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> data =
                  documents[index].data() as Map<String, dynamic>;

              String userID = data['userID'] ?? '';

              String userName = 'Unknown';

              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .where("userID", isEqualTo: userID)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: CupertinoActivityIndicator(),
                    );
                  }

                  if (userSnapshot.hasError || !userSnapshot.hasData) {
                    return ListTile(
                      title: Text('User: Error fetching user data'),
                    );
                  }

                  if (userSnapshot.data!.docs.isNotEmpty) {
                    // User exists, get their name
                    userName = userSnapshot.data!.docs.first['name'];
                  }

                  return Card(
                    margin: EdgeInsets.all(10),
                    elevation: 5,
                    child: ListTile(
                      title: Text(
                        userName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.info,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AllocatedUserDetail(data: data),
                                ),
                              );
                            },
                          ),
                          widget.projectData["teamLeadID"] == userID
                              ? Icon(
                                  CupertinoIcons.person,
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: isTeamLead
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return AddAllocatedUser(
                        projectData: widget.projectData,
                      );
                    },
                  ),
                );
              },
              child: Icon(Icons.edit),
            )
          : null,
    );
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
            isTeamLead =
                userSnapshot['userID'] == widget.projectData["teamLeadID"];
          });
        }
      }
    } catch (e) {
      print('Error checking user role: $e');
    }
  }
}
