import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/components/button.dart';
import 'package:ppmt/components/textfield.dart';

class AddSkill extends StatefulWidget {
  final String skillName;
  final String skillID;

  const AddSkill({Key? key, required this.skillName, required this.skillID})
      : super(key: key);

  @override
  State<AddSkill> createState() => addSkillState();
}

class addSkillState extends State<AddSkill> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController skillController = TextEditingController();

  @override
  void initState() {
    super.initState();
    skillController.text = widget.skillName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Skill'),
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
                    return 'Please enter a skill name';
                  }
                  return null;
                },
                keyboardType: TextInputType.name,
                labelText: 'Skill Name',
                obscureText: false,
              ),
              SizedBox(height: 20.0),
              button(
                buttonName:
                    widget.skillName.isNotEmpty ? 'Update Skill' : 'Add Skill',
                onPressed: submit,
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
          // Update existing skill
          await updateSkill();
        } else {
          // Add new skill
          await addSkill();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Skill ${widget.skillName.isNotEmpty ? 'updated' : 'added'} successfully')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> addSkill() async {
    try {
      await FirebaseFirestore.instance.collection('skills').add({
        'skillName': skillController.text.trim(),
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
