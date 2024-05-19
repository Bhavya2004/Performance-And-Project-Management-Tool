import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/screens/admin/users/user_details.dart';

class Users extends StatefulWidget {
  const Users({Key? key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
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
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'user')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CupertinoActivityIndicator(
                color: kAppBarColor,
              ),
            );
          }
          List<DocumentSnapshot> sortedDocs = snapshot.data!.docs.toList()
            ..sort((a, b) {
              bool aDisabled = a['isDisabled'] ?? false;
              bool bDisabled = b['isDisabled'] ?? false;
              if (aDisabled && !bDisabled) {
                return 1;
              } else if (!aDisabled && bDisabled) {
                return -1;
              } else {
                return 0;
              }
            });
          return ListView.builder(
            itemCount: sortedDocs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = sortedDocs[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return buildCard(context, doc, data);
            },
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

  Widget buildCard(BuildContext context, DocumentSnapshot document,
      Map<String, dynamic> data) {
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
      color: data["isDisabled"] ? Colors.grey[400] : null,
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
                  icon: data["isDisabled"]
                      ? SizedBox()
                      : Icon(
                          CupertinoIcons.info_circle_fill,
                          color: kAppBarColor,
                        ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserDetails(
                          userID: data['userID'],
                          userName: data['name'],
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: data["isDisabled"]
                      ? Icon(
                          Icons.visibility_off,
                          color: kDeleteColor,
                        )
                      : Icon(
                          Icons.visibility,
                          color: kAppBarColor,
                        ),
                  onPressed: () async {
                    await updateUserStatus(
                      userID: data["userID"].toString(),
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

  Future<void> updateUserStatus({required String userID}) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userID', isEqualTo: userID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userSnapshot = querySnapshot.docs.first;
        final userData = userSnapshot.data() as Map<String, dynamic>?;

        if (userData != null) {
          await userSnapshot.reference
              .update({'isDisabled': !(userData['isDisabled'] ?? false)});
        } else {
          throw ('Document data is null or empty');
        }
      } else {
        throw ('Level with ID $userID not found.');
      }
    } catch (e) {
      throw ('Error updating user details: $e');
    }
  }
}
