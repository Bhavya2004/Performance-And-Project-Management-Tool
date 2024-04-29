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
        iconTheme: IconThemeData(
          color: AppColor.white,
        ),
        backgroundColor: AppColor.sanMarino,
        title: Text(
          'Admin Dashboard',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColor.white,
          ),
        ),
      ),
      body: Center(
        child: Text(
          "Admin Dashboard",
        ),
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
                    child: Text(
                      "Error fetching user data",
                    ),
                  );
                }
                return Container(
                  color: AppColor.sanMarino,
                  width: double.infinity,
                  height: 200,
                  padding: EdgeInsets.only(top: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: AppColor.white,
                          child: Text(
                            snapshot.data != null
                                ? snapshot.data![0].toUpperCase()
                                : "?",
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        snapshot.data ?? "Loading...",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Text(
                        firebaseAuth.currentUser!.email ?? "No email",
                        style: TextStyle(
                          color: Colors.grey[200],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                CupertinoIcons.person,
                color: AppColor.sanMarino,
              ),
              title: Text(
                'My Profile',
                style: TextStyle(
                  color: AppColor.black,
                ),
              ),
              onTap: () {
                Navigator.of(context).pushNamed('/profile');
              },
            ),
            ListTile(
              leading: Icon(
                CupertinoIcons.bell_fill,
                color: AppColor.sanMarino,
              ),
              title: Text(
                'Message',
                style: TextStyle(
                  color: AppColor.black,
                ),
              ),
              onTap: () {
                Navigator.of(context).pushNamed('/message');
              },
            ),
            ListTile(
              leading: Icon(
                CupertinoIcons.hexagon_fill,
                color: AppColor.sanMarino,
              ),
              title: Text(
                'Master',
                style: TextStyle(
                  color: AppColor.black,
                ),
              ),
              onTap: () {
                Navigator.of(context).pushNamed('/master');
              },
            ),
            ListTile(
              leading: Icon(
                CupertinoIcons.projective,
                color: AppColor.sanMarino,
              ),
              title: Text(
                'Projects',
                style: TextStyle(
                  color: AppColor.black,
                ),
              ),
              onTap: () {
                Navigator.of(context).pushNamed('/projects');
              },
            ),
            ListTile(
              leading: Icon(
                CupertinoIcons.person_2_fill,
                color: AppColor.sanMarino,
              ),
              title: Text(
                'Members',
                style: TextStyle(
                  color: AppColor.black,
                ),
              ),
              onTap: () {
                Navigator.of(context).pushNamed('/user_list');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.login_rounded,
                color: AppColor.sanMarino,
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/signin');
              },
              title: Text(
                'Logout',
                style: TextStyle(
                  color: AppColor.black,
                ),
              ),
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
        if (snapshot.data()!.containsKey('name')) {
          return snapshot.get('name');
        } else {
          return "User";
        }
      }
    }
    return "User";
  }
}
