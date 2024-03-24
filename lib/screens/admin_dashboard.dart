import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/screens/account.dart';
import 'package:ppmt/screens/master.dart';
import 'package:ppmt/screens/message.dart';
import 'package:ppmt/screens/projects.dart';
import 'package:ppmt/screens/users.dart';

class AdminDashboard extends StatefulWidget {
  AdminDashboard({Key? key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
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
        child: widgetOptions.elementAt(selectedIndex),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColor.white,
        onDestinationSelected: onItemTapped,
        selectedIndex: selectedIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(CupertinoIcons.bell_fill),
            icon: Icon(CupertinoIcons.bell),
            label: 'Messages',
          ),
          NavigationDestination(
            selectedIcon: Icon(CupertinoIcons.hexagon_fill),
            icon: Icon(CupertinoIcons.hexagon),
            label: 'Master',
          ),
          NavigationDestination(
            selectedIcon: Icon(CupertinoIcons.person_2_alt),
            icon: Icon(CupertinoIcons.person_2),
            label: 'Members',
          ),
          NavigationDestination(
            selectedIcon: Icon(CupertinoIcons.projective),
            icon: Icon(CupertinoIcons.projective),
            label: 'Projects',
          ),
          NavigationDestination(
            selectedIcon: Icon(CupertinoIcons.person_alt),
            icon: Icon(CupertinoIcons.person),
            label: 'Account',
          ),
        ],
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

  int selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> widgetOptions = <Widget>[
    Message(),
    Master(),
    Users(),
    Projects(),
    Account()
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }
}
