import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/components/button.dart';
import 'package:ppmt/components/textfield.dart';
import 'package:ppmt/constants/color.dart';

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
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: AppColor.white,
        ),
        backgroundColor: AppColor.sanMarino,
        title: Text(
          'Add Complexity',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColor.white,
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
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: button(
                  buttonName: 'Add Complexity',
                  onPressed: submit,
                  backgroundColor: AppColor.black,
                  textColor: AppColor.white,
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
        await AddComplexity();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Complexity added successfully',
            ),
          ),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
            ),
          ),
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
      throw ('Error adding complexity: $e',);
    }
  }
}
