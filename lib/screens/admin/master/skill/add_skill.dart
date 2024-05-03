import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/components/button.dart';
import 'package:ppmt/components/snackbar.dart';
import 'package:ppmt/components/textfield.dart';
import 'package:ppmt/constants/color.dart';

class AddSkill extends StatefulWidget {
  final String skillName;
  final String skillID;

  const AddSkill({Key? key, required this.skillName, required this.skillID})
      : super(key: key);

  @override
  State<AddSkill> createState() => AddSkillState();
}

class AddSkillState extends State<AddSkill> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController skillController = TextEditingController();

  @override
  void initState() {
    super.initState();
    skillController.text = widget.skillName;
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
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textFormField(
                controller: skillController,
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
    if (_formKey.currentState!.validate()) {
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
      await FirebaseFirestore.instance.collection('skills').add({
        'skillName': skillController.text.trim(),
        'isDisabled': false,
      });
    } catch (e) {
      throw ('Error adding skill: $e');
    }
  }

  Future<void> updateSkill() async {
    try {
      await FirebaseFirestore.instance
          .collection('skills')
          .doc(widget.skillID)
          .update({
        'skillName': skillController.text.trim(),
      });
    } catch (e) {
      throw ('Error updating skill: $e');
    }
  }
}
