import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/components/button.dart';
import 'package:ppmt/components/snackbar.dart';
import 'package:ppmt/components/textfield.dart';
import 'package:ppmt/constants/color.dart';
import 'package:ppmt/constants/generate_id.dart';

class AddSkill extends StatefulWidget {
  final String skillName;
  final String skillID;

  const AddSkill({Key? key, required this.skillName, required this.skillID})
      : super(key: key);

  @override
  State<AddSkill> createState() => AddSkillState();
}

class AddSkillState extends State<AddSkill> {
  final formKey = GlobalKey<FormState>();
  TextEditingController skillNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    skillNameController.text = widget.skillName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: CupertinoColors.white,
        ),
        backgroundColor: kAppBarColor,
        title: Text(
          widget.skillID.isEmpty ? 'Add Skill' : 'Update Skill',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textFormField(
                controller: skillNameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Skill is required";
                  }
                  return null;
                },
                keyboardType: TextInputType.name,
                labelText: 'Skill Name',
                obscureText: false,
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(15),
                child: button(
                  buttonName: widget.skillName.isNotEmpty
                      ? 'Update Skill'
                      : 'Add Skill',
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
        if (widget.skillName.isNotEmpty) {
          await updateSkill();
          showSnackBar(context: context, message: "Skill Updated Successfully");
        } else {
          await addSkill();
          showSnackBar(context: context, message: "Skill Added Successfully");
        }
        Navigator.of(context).pop();
      } catch (e) {
        showSnackBar(context: context, message: "Error: $e");
      }
    }
  }

  Future<void> addSkill() async {
    try {
      int lastSkillID =
          await getLastID(collectionName: "skills", primaryKey: "skillID");
      int newSkillID = lastSkillID + 1;
      await FirebaseFirestore.instance.collection('skills').add({
        "skillID": newSkillID.toString(),
        'skillName': skillNameController.text.trim(),
        'isDisabled': false,
      });
    } catch (e) {
      throw ('Error adding skill: $e');
    }
  }

  Future<void> updateSkill() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('skills')
          .where('skillID', isEqualTo: widget.skillID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final skillSnapShot = querySnapshot.docs.first;
        final skillData = skillSnapShot.data() as Map<String, dynamic>?;

        if (skillData != null) {
          await skillSnapShot.reference
              .update({'skillName': skillNameController.text});
        } else {
          throw ('Document data is null or empty');
        }
      } else {
        throw ('Level with ID ${widget.skillID} not found.');
      }
    } catch (e) {
      throw ('Error updating skill details: $e');
    }
  }
}
