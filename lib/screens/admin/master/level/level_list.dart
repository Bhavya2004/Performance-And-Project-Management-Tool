import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ppmt/screens/admin/master/level/add_level.dart';

// Step 2: Add a new IconButton in your ListTile for the trash button
// Step 3: In the onPressed function of the trash button, update the `isDisabled` field to `true` for the corresponding level in Firestore
// Step 4: Modify your Firestore query to order the documents based on the `isDisabled` field

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

          // Split the documents into active and disabled items
          var activeItems = snapshot.data!.docs
              .where((doc) => doc['isDisabled'] != true)
              .toList();
          var disabledItems = snapshot.data!.docs
              .where((doc) => doc['isDisabled'] == true)
              .toList();

          // Function to build a ListTile from a document
          ListTile buildTile(DocumentSnapshot document, bool isDisabled) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return ListTile(
              tileColor: isDisabled
                  ? Colors.grey[400]
                  : null, // Set color to grey if disabled
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: isDisabled
                        ? null
                        : () async {
                            // Disable button if disabled
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
                    child: Text(
                      data['levelName'],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: isDisabled
                            ? Icon(Icons.visibility_off)
                            : Icon(Icons.visibility),
                        onPressed: isDisabled
                            ? () async {
                                // Enable button if disabled
                                await firebaseFirestore
                                    .collection('levels')
                                    .doc(document.id)
                                    .update({'isDisabled': false});
                              }
                            : () async {
                                // Disable button if disabled
                                await firebaseFirestore
                                    .collection('levels')
                                    .doc(document.id)
                                    .update({'isDisabled': true});
                              },
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          // Build the ListView with active items first and disabled items last
          return ListView(
            children: activeItems.map((doc) => buildTile(doc, false)).toList() +
                disabledItems.map((doc) => buildTile(doc, true)).toList(),
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
