import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/components/button.dart';
import 'package:ppmt/components/snackbar.dart';
import 'package:ppmt/components/textfield.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/constants/generate_id.dart';

class AddLevel extends StatefulWidget {
  final String levelName;
  final String levelID;

  const AddLevel({Key? key, required this.levelName, required this.levelID})
      : super(key: key);

  @override
  State<AddLevel> createState() => _AddLevelState();
}

class _AddLevelState extends State<AddLevel> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController levelNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    levelNameController.text = widget.levelName;
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
          key: formKey,
          child: Column(
            children: [
              textFormField(
                controller: levelNameController,
                obscureText: false,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Level is required";
                  }
                  return null;
                },
                keyboardType: TextInputType.name,
                labelText: 'Level Name',
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(15),
                child: button(
                  buttonName: widget.levelName.isNotEmpty
                      ? "Update Level"
                      : "Add Level",
                  onPressed: submit,
                  backgroundColor: CupertinoColors.black,
                  textColor: CupertinoColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> submit() async {
    if (formKey.currentState!.validate()) {
      try {
        if (widget.levelName.isNotEmpty) {
          await updateLevel();
          showSnackBar(context: context, message: "Level Updated Successfully");
        } else {
          await addLevel();
          showSnackBar(context: context, message: "Level Added Successfully");
        }
        Navigator.of(context).pop();
      } catch (e) {
        showSnackBar(context: context, message: "Error: $e");
      }
    }
  }

  Future<void> addLevel() async {
    try {
      int lastLevelID =
          await getLastID(collectionName: "levels", primaryKey: "levelID");
      int newLevelID = lastLevelID + 1;
      await FirebaseFirestore.instance.collection('levels').add({
        'levelID': newLevelID.toString(),
        'levelName': levelNameController.text.trim(),
        'isDisabled': false,
      });
    } catch (e) {
      throw ('Error adding level: $e');
    }
  }

  Future<void> updateLevel() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('levels')
          .where('levelID', isEqualTo: widget.levelID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final levelSnapshot = querySnapshot.docs.first;
        final levelData = levelSnapshot.data() as Map<String, dynamic>?;

        if (levelData != null) {
          await levelSnapshot.reference
              .update({'levelName': levelNameController.text});
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
