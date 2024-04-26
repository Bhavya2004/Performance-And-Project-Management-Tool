import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/components/button.dart';
import 'package:ppmt/components/textfield.dart';

class AddComplexity extends StatefulWidget {
  const AddComplexity({Key? key}) : super(key: key);

  @override
  State<AddComplexity> createState() => AddComplexityState();
}

class AddComplexityState extends State<AddComplexity> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController complexityController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Complexity')),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textFormField(
                controller: complexityController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a Complexity name';
                  }
                  return null;
                },
                keyboardType: TextInputType.name,
                labelText: 'Complexity Name',
                obscureText: false,
              ),
              SizedBox(height: 10),
              button(
                buttonName: 'Add Complexity',
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
        // Add new skill
        await AddComplexity();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Complexity added successfully')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> AddComplexity() async {
    try {
      await FirebaseFirestore.instance.collection('complexity').add({
        'complexityName': complexityController.text.trim(),
      });
    } catch (e) {
      throw ('Error adding complexity: $e');
    }
  }
}
