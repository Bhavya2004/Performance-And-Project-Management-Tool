import 'package:cloud_firestore/cloud_firestore.dart';
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
      try {
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
      } catch (e) {
        // Handle any errors that occur during level addition or update
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
          ),
        );
      }
    }
  }

  Future<void> addLevelDetails({required String level}) async {
    try {
      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      CollectionReference ref = firebaseFirestore.collection('levels');

      // Get the last assigned levelID from Firestore
      int lastLevelID = await getLastLevelID();
      int newLevelID = lastLevelID + 1;

      // Add the new level with the incremented levelID and isDisabled set to false
      await ref.add({
        'levelID': newLevelID.toString(),
        'levelName': level,
        'isDisabled': false // Set isDisabled to false by default
      });
    } catch (e) {
      throw ('Error adding level: $e');
    }
  }

  Future<int> getLastLevelID() async {
    try {
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
    } catch (e) {
      throw ('Error getting last level ID: $e');
    }
  }

  Future<void> updateLevelDetails() async {
    try {
      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      CollectionReference ref = firebaseFirestore.collection('levels');
      QuerySnapshot<Object?> querySnapshot =
          await ref.where('levelID', isEqualTo: widget.levelID).get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot<Object?> levelSnapshot = querySnapshot.docs.first;

        Map<String, dynamic>? levelData =
            levelSnapshot.data() as Map<String, dynamic>?;

        if (levelData != null) {
          // Update levelName field with the new value
          levelData['levelName'] = levelController.text;
          // Update isDisabled field with the new value
          levelData['isDisabled'] = false; // or true, depending on your needs

          // Update the document with the modified data
          await levelSnapshot.reference.update(levelData);

          print('Level updated successfully');
          // Show success message or perform any additional actions
        } else {
          // Document data is null or empty
          throw ('Document data is null or empty');
        }
      } else {
        // No document found with the specified levelID
        throw ('Level with ID ${widget.levelID} not found.');
      }
    } catch (e) {
      throw ('Error updating level details: $e');
    }
  }
}
