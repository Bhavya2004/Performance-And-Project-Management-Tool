import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/screens/admin/members/skill_level.dart';

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
        title: Text('Users'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where(
                    'role',
                    isEqualTo: 'user',
                  )
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    print("UserID: ${document.id}");
                    return GestureDetector(
                      onTap: () {
                        print("UserID: ${document.id}");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SkillLevel(
                              UserID: document.id,
                              UserName: data['name'],
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        title: Text(data['name']),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/add_user');
        },
        label: Text(
          "Add Member",
        ),
      ),
    );
  }
}
