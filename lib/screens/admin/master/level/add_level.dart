import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/components/button.dart';
import 'package:ppmt/components/snackbar.dart';
import 'package:ppmt/components/textfield.dart';
import 'package:ppmt/constants/color.dart';

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
        iconTheme: IconThemeData(
          color: CupertinoColors.white,
        ),
        backgroundColor: kAppBarColor,
        title: Text(
          widget.levelID.isEmpty ? "Add Level" : "Update Level",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formSignInKey,
          child: Column(
            children: [
              buildLevelTextField(),
              SizedBox(height: 10),
              buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLevelTextField() {
    return textFormField(
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
    );
  }

  Widget buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: button(
        buttonName: widget.levelName.isNotEmpty ? "Update Level" : "Add Level",
        onPressed: submit,
        backgroundColor: CupertinoColors.black,
        textColor: CupertinoColors.white,
      ),
    );
  }

  Future<void> submit() async {
    if (_formSignInKey.currentState!.validate()) {
      try {
        if (widget.levelName.isNotEmpty) {
          await updateLevelDetails();
          showSnackBar(context: context, message: "Level Updated Successfully");
        } else {
          await addLevelDetails(level: levelController.text);
          showSnackBar(context: context, message: "Level Added Successfully");
        }
        Navigator.of(context).pop();
      } catch (e) {
        showSnackBar(context: context, message: "Error: $e");
      }
    }
  }

  Future<void> addLevelDetails({required String level}) async {
    try {
      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      CollectionReference ref = firebaseFirestore.collection('levels');
      int lastLevelID = await getLastLevelID();
      int newLevelID = lastLevelID + 1;
      await ref.add({
        'levelID': newLevelID.toString(),
        'levelName': level,
        'isDisabled': false,
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
          levelData['levelName'] = levelController.text;
          levelData['isDisabled'] = false;
          await levelSnapshot.reference.update(levelData);
        } else {
          throw ('Document data is null or empty');
        }
      } else {
        throw ('Level with ID ${widget.levelID} not found.');
      }
    } catch (e) {
      throw ('Error updating level details: $e');
    }
  }
}
