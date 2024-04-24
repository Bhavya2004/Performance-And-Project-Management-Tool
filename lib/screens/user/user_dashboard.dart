import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ppmt/screens/admin/members/add_user.dart';
import 'package:ppmt/screens/user/user_skill_level.dart';

class UserDashboard extends StatefulWidget {
  UserDashboard({Key? key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Dashboard'),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: Text('My Profile'),
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
            onSelected: (value) async {
              if (value == 1) {}
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
              return Text('Logged in as ${snapshot.data!.email}');
            }
            return Text('Not logged in');
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
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
              title: Text('My Profile'),
              onTap: () async {
                // Fetch user details from Firestore
                String uid = FirebaseAuth.instance.currentUser!.uid;
                DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .get();
                if (userSnapshot.exists) {
                  // Navigate to AddUser page and pass user's details
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddUser(
                        email: userSnapshot['email'],
                        name: userSnapshot['name'],
                        surname: userSnapshot['surname'],
                        phoneNumber: userSnapshot['phoneNumber'],
                        isProfileEditing: true, // Set flag for editing
                      ),
                    ),
                  );
                }
              },
            ),
            ListTile(
              title: Text('Skill-Level'),
              onTap: () async {
                String uid = FirebaseAuth.instance.currentUser!.uid;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserSkillLevel(
                      UserID: uid, // Pass the user ID to UserSkillLevel widget
                    ),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () async {
                // Perform logout action
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/signin');
              },
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
