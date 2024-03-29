import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/screens/admin/master/level/add_level.dart';

class LevelListPage extends StatelessWidget {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  LevelListPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Levels"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firebaseFirestore.collection('levels').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(data['levelName']),
                    GestureDetector(
                      onTap: () async {
                        // Fetch level details from Firestore
                        String levelName = data['levelName'];
                        String levelID = data['levelID'];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddLevel(
                              levelName: levelName,
                              levelID: levelID,
                            ),
                          ),
                        );
                      },
                      child: Icon(Icons.edit),
                    )
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text("Add Level"),
        icon: Icon(CupertinoIcons.add),
        onPressed: () {
          Navigator.of(context).pushNamed('/add_level');
        },
      ),
    );
  }
}
