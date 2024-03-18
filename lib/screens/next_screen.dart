import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/components/confirmation.dart';

class NextScreen extends StatelessWidget {
  NextScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Next Screen'),
        actions: [
          IconButton(
            onPressed: () async {
              await showConfirmationPopup(
                context,
                yesFunction: () async {
                  try {
                    await FirebaseAuth.instance.signOut();
                    // Navigate to a different screen after sign out
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } catch (e) {
                    print("Error signing out: $e");
                  }
                },
                title: "Logout?",
                content: "Are you sure you want to logout of your Account?",
              );
            },
            icon: Icon(Icons.logout),
          )
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: Icon(
          CupertinoIcons.add,
        ),
        label: Text("Add User"),
      ),
    );
  }
}
