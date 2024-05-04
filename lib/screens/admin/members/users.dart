import 'dart:math';
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
        iconTheme: const IconThemeData(
          color: CupertinoColors.white,
        ),
        backgroundColor: kAppBarColor,
        title: const Text(
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
              child: CupertinoActivityIndicator(
                color: kAppBarColor,
              ),
            );
          }

          final activeItems = <QueryDocumentSnapshot>[];
          final disabledItems = <QueryDocumentSnapshot>[];

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['isDisabled'] == true) {
              disabledItems.add(doc);
            } else {
              activeItems.add(doc);
            }
          }

          return ListView(
            children: [
              ..._buildUserList(activeItems, false),
              ..._buildUserList(disabledItems, true),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        isExtended: true,
        onPressed: () {
          Navigator.of(context).pushNamed('/add_user');
        },
        backgroundColor: Colors.orange.shade700,
        child: Icon(
          Icons.add,
          color: Colors.orange.shade100,
        ),
      ),
    );
  }

  List<Widget> _buildUserList(
      List<QueryDocumentSnapshot> items, bool isDisabled) {
    return items.map((doc) {
      final data = _getUserData(doc);
      return _buildUserListItem(doc, data, isDisabled);
    }).toList();
  }

  Map<String, dynamic> _getUserData(QueryDocumentSnapshot document) {
    return document.data() as Map<String, dynamic>;
  }

  Widget _buildUserListItem(QueryDocumentSnapshot document,
      Map<String, dynamic> data, bool isDisabled) {
    final userName = data['name'] as String;
    final firstCharacter = userName.isNotEmpty ? userName[0].toUpperCase() : '';

    final random = Random();
    final randomColor = Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );

    final textColor =
        randomColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return Card(
      margin: const EdgeInsets.all(5),
      color: isDisabled ? Colors.grey[400] : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: randomColor,
          child: Text(
            firstCharacter,
            style: TextStyle(
              color: textColor,
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              userName,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: isDisabled
                      ? Icon(
                          Icons.visibility_off,
                          color: kDeleteColor,
                        )
                      : Icon(
                          Icons.visibility,
                          color: kAppBarColor,
                        ),
                  onPressed: () async {
                    await _updateUserStatus(document.id, !isDisabled);
                  },
                ),
                IconButton(
                  icon: Icon(
                    CupertinoIcons.info_circle_fill,
                    color: kAppBarColor,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SkillLevel(
                          userID: document.id,
                          userName: userName,
                        ),
                      ),
                    );
                  },
                ),
              ],
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
    } catch (e) {}
  }
}
