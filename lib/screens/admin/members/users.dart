import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/screens/admin/members/skill_level.dart';

class Users extends StatefulWidget {
  const Users({Key? key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: CupertinoColors.white,
        ),
        backgroundColor: kAppBarColor,
        title: Text(
          'Users',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firebaseFirestore
            .collection('users')
            .where('role', isEqualTo: 'user')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final activeItems = <QueryDocumentSnapshot>[];
          final disabledItems = <QueryDocumentSnapshot>[];

          snapshot.data!.docs.forEach((doc) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['isDisabled'] == true) {
              disabledItems.add(doc);
            } else {
              activeItems.add(doc);
            }
          });

          return ListView(
            children: [
              ..._buildUserList(activeItems),
              ..._buildDisabledUserList(disabledItems),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/add_user');
        },
        icon: Icon(
          Icons.add,
          color: CupertinoColors.black,
        ),
        label: Text(
          "Add Member",
          style: TextStyle(
            color: CupertinoColors.black,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildUserList(List<QueryDocumentSnapshot> items) {
    return items.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return _buildUserListItem(doc, data);
    }).toList();
  }

  List<Widget> _buildDisabledUserList(List<QueryDocumentSnapshot> items) {
    return items.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return _buildDisabledUserListItem(doc, data);
    }).toList();
  }

  Widget _buildUserListItem(
      QueryDocumentSnapshot document, Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SkillLevel(
              userID: document.id,
              userName: data['name'],
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.all(5),
        child: ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data['name'],
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              IconButton(
                icon: Icon(Icons.visibility),
                onPressed: () async {
                  await _updateUserStatus(document.id, true);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisabledUserListItem(
      QueryDocumentSnapshot document, Map<String, dynamic> data) {
    return Card(
      margin: EdgeInsets.all(5),
      color: Colors.grey[400],
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              data['name'],
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            IconButton(
              icon: Icon(Icons.visibility_off),
              onPressed: () async {
                await _updateUserStatus(document.id, false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateUserStatus(String userId, bool status) async {
    try {
      await _firebaseFirestore
          .collection('users')
          .doc(userId)
          .update({'isDisabled': status});
    } catch (e) {
      print('Error updating user status: $e');
    }
  }
}
