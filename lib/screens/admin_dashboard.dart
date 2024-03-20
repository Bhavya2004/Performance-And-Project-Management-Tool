import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AdminDashboard extends StatefulWidget {
  AdminDashboard({Key? key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: Text('Option 1'),
                  value: 1,
                ),
                PopupMenuItem(
                  child: ListTile(
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacementNamed(context, '/signin');
                    },
                    title: Text('Logout'),
                  ),
                  value: 2,
                ),
              ];
            },
            onSelected: (value) {
              // Handle selection from the dropdown here
              print('Selected option: $value');
            },
          ),
        ],
      ),
      body: Center(
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasData && snapshot.data != null) {
              return FutureBuilder<int>(
                future: getUserCount(),
                builder: (context, userCountSnapshot) {
                  if (userCountSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (userCountSnapshot.hasData) {
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed("/user_list");
                          },
                          child: Card(
                            margin: EdgeInsets.all(20),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Total User : ${userCountSnapshot.data}",
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Text('Failed to fetch user count');
                  }
                },
              );
            }
            return Text('Not logged in');
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/add_user');
        },
        icon: Icon(
          CupertinoIcons.add,
        ),
        label: Text("Add User"),
      ),
    );
  }

  Future<int> getUserCount() async {
    User? user = FirebaseAuth.instance.currentUser;
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .where('role', isEqualTo: 'user')
        .get();
    int userCount = snapshot.size;
    print(userCount);
    return userCount;
  }
}
