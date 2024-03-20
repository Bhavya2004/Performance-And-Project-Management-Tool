import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
              return Text('Logged in as ${snapshot.data!.email}');
            }
            return Text('Not logged in');
          },
        ),
      ),
    );
  }
}
