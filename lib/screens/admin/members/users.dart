import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/screens/admin/members/skill_level.dart';

class Users extends StatefulWidget {
  const Users({Key? key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

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

                List<QueryDocumentSnapshot> activeItems = [];
                List<QueryDocumentSnapshot> disabledItems = [];

                snapshot.data!.docs.forEach((doc) {
                  Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;
                  if (data['isDisabled'] == true) {
                    disabledItems.add(doc);
                  } else {
                    activeItems.add(doc);
                  }
                });

                return ListView(
                  children: [
                    ...activeItems.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      return GestureDetector(
                        onTap: () {
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
                                    bool isDisabled =
                                        data['isDisabled'] ?? false;
                                    if (!isDisabled) {
                                      await firebaseFirestore
                                          .collection('users')
                                          .doc(document.id)
                                          .update({'isDisabled': true});
                                    } else {
                                      // Do something else or show a message
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    ...disabledItems.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      return Card(
                        margin: EdgeInsets.all(5),
                        color: Colors.grey[
                            400], // Set grey background for disabled users
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
                                  bool isDisabled = data['isDisabled'] ?? false;
                                  if (isDisabled) {
                                    await firebaseFirestore
                                        .collection('users')
                                        .doc(document.id)
                                        .update({'isDisabled': false});
                                  } else {
                                    // Do something else or show a message
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
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
