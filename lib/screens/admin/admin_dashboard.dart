import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/constants/color.dart';

class AdminDashboard extends StatefulWidget {
  AdminDashboard({Key? key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int currentPageIndex = 0;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Admin Dashboard',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Text("Admin Dashboard"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.all(0),
          children: [
            FutureBuilder(
              future: _getUserDisplayName(),
              builder: (context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return DrawerHeader(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return DrawerHeader(
                    child: Text("Error fetching user data"),
                  );
                }
                return DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: null, // Remove the border
                  ),
                  child: UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    accountName: Text(
                      snapshot.data ?? "Loading...",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    accountEmail: Text(
                      firebaseAuth.currentUser!.email ?? "No email",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    currentAccountPictureSize: Size.square(50),
                    currentAccountPicture: Align(
                      alignment: Alignment.topLeft,
                      child: CircleAvatar(
                        backgroundColor: Colors.black,
                        child: Text(
                          snapshot.data != null
                              ? snapshot.data![0].toUpperCase()
                              : "?",
                          style: TextStyle(
                            fontSize: 25.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(CupertinoIcons.person),
              title: Text('My Profile'),
              onTap: () {
                Navigator.of(context).pushNamed('/profile').then(
                  (value) async {
                    Navigator.pop(context);
                  },
                );
              },
            ),
            ListTile(
              leading: Icon(CupertinoIcons.bell_fill),
              title: Text('Message'),
              onTap: () {
                Navigator.of(context).pushNamed('/message').then(
                  (value) async {
                    Navigator.pop(context);
                  },
                );
              },
            ),
            ListTile(
              leading: Icon(CupertinoIcons.hexagon_fill),
              title: const Text('Master'),
              onTap: () {
                Navigator.of(context).pushNamed('/master').then(
                  (value) async {
                    Navigator.pop(context);
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.projective),
              title: const Text('Projects'),
              onTap: () {
                Navigator.of(context).pushNamed('/projects').then(
                  (value) async {
                    Navigator.pop(context);
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.person_2_fill),
              title: const Text('Members'),
              onTap: () {
                Navigator.of(context).pushNamed('/user_list').then(
                  (value) async {
                    Navigator.pop(context);
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.login_rounded),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/signin');
              },
              title: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _getUserDisplayName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (snapshot.exists) {
        // Check if the document contains the "name" field
        if (snapshot.data()!.containsKey('name')) {
          // Return the value of the "name" field
          return snapshot.get('name');
        } else {
          // Handle the case where the "name" field does not exist
          return "User";
        }
      }
    }
    return "User";
  }
}
