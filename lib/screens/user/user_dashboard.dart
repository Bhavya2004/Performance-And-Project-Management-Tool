import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ppmt/screens/admin/members/add_user.dart';

class UserDashboard extends StatelessWidget {
  UserDashboard({Key? key});

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
              if (value == 1) {
                // Fetch user details from Firestore
                String uid = FirebaseAuth.instance.currentUser!.uid;
                DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .get();
                if (userSnapshot.exists) {
                  print(userSnapshot.exists);
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
              }
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
    );
  }
}
