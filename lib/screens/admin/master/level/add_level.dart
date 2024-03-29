import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/components/button.dart';
import 'package:ppmt/components/textfield.dart';

class AddLevel extends StatefulWidget {
  final String levelName;
  final String levelID;

  const AddLevel({Key? key, required this.levelName, required this.levelID})
      : super(key: key);

  @override
  State<AddLevel> createState() => _AddLevelState();
}

class _AddLevelState extends State<AddLevel> {
  final _formSignInKey = GlobalKey<FormState>();
  final levelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    levelController.text = widget.levelName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Add Level"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Form(
              key: _formSignInKey,
              child: Column(
                children: [
                  textFormField(
                    controller: levelController,
                    obscureText: false,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Level is required";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.name,
                    labelText: 'Level',
                  ),
                  button(
                    buttonName: widget.levelName.isNotEmpty
                        ? "Update Level"
                        : "Add Level",
                    onPressed: addLevel,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addLevel() async {
    if (_formSignInKey.currentState!.validate()) {
      if (widget.levelName.isNotEmpty) {
        // Update existing level
        await updateLevelDetails();
      } else {
        // Add new level
        await addLevelDetails(level: levelController.text.toString());
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Level Added Successfully'),
          ),
        );
      }
      // Navigate back to previous screen
      Navigator.of(context).pop();
    }
  }

  Future<void> addLevelDetails({required String level}) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    CollectionReference ref = firebaseFirestore.collection('levels');

    // Get the last assigned levelID from Firestore
    int lastLevelID = await getLastLevelID();
    int newLevelID = lastLevelID + 1;

    // Add the new level with the incremented levelID
    await ref.add({'levelID': newLevelID.toString(), 'levelName': level});
  }

  Future<int> getLastLevelID() async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    QuerySnapshot<Map<String, dynamic>> snapshot = await firebaseFirestore
        .collection('levels')
        .orderBy('levelID', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      String? levelIDString = snapshot.docs.first['levelID'] as String?;
      if (levelIDString != null && int.tryParse(levelIDString) != null) {
        return int.parse(levelIDString);
      }
    }
    // If no valid levelID is found, return 0
    return 0;
  }

  Future<void> updateLevelDetails() async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    CollectionReference ref = firebaseFirestore.collection('levels');

    // Convert widget.levelID to a string
    String levelID = widget.levelID.toString();
    print(levelID);
    try {
      // Check if the document with the provided levelID exists
      DocumentSnapshot<Object?> levelSnapshot = await ref.doc(levelID).get();
      print(levelSnapshot);
      if (levelSnapshot.exists) {
        // Document exists, update its levelName
        await ref.doc(levelID).update({'levelName': levelController.text});
        // Show success message or perform any additional actions
      } else {
        // Document does not exist, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: Level with ID $levelID not found.'),
          ),
        );
      }
    } catch (e) {
      // Handle any potential errors (e.g., network issues)
      print('Error updating level details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating level details: $e'),
        ),
      );
    }
  }
}
