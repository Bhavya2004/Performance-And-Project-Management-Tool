import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/screens/admin/master/level/add_level.dart';

class LevelListPage extends StatelessWidget {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  LevelListPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: firebaseFirestore
            .collection('levels')
            .orderBy('levelID')
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
    );
  }

  Widget buildCard(BuildContext context, DocumentSnapshot document,
      Map<String, dynamic> data) {
    return Card(
      color: data['isDisabled'] == true ? Colors.grey[400] : null,
      margin: EdgeInsets.all(10),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              child: Text(
                data['levelName'],
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: data['isDisabled']
                      ? SizedBox()
                      : Icon(
                          CupertinoIcons.pencil,
                          color: kEditColor,
                        ),
                  onPressed: data['isDisabled']
                      ? null
                      : () async {
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
                ),
                IconButton(
                  icon: data['isDisabled']
                      ? Icon(
                          Icons.visibility_off,
                          color: kDeleteColor,
                        )
                      : Icon(
                          Icons.visibility,
                          color: kAppBarColor,
                        ),
                  onPressed: () =>
                      updateLevelStatus(levelID: data["levelID"].toString()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateLevelStatus({required String levelID}) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('levels')
          .where('levelID', isEqualTo: levelID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final levelSnapshot = querySnapshot.docs.first;
        final levelData = levelSnapshot.data() as Map<String, dynamic>?;

        if (levelData != null) {
          await levelSnapshot.reference
              .update({'isDisabled': !(levelData['isDisabled'] ?? false)});
        } else {
          throw ('Document data is null or empty');
        }
      } else {
        throw ('Level with ID $levelID not found.');
      }
    } catch (e) {
      throw ('Error updating level details: $e');
    }
  }
}
