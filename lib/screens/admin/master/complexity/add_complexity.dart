import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:ppmt/components/button.dart";
import "package:ppmt/components/snackbar.dart";
import "package:ppmt/components/textfield.dart";
import "package:ppmt/constants/color.dart";
import "package:ppmt/constants/generate_id.dart";

class AddComplexity extends StatefulWidget {
  const AddComplexity({Key? key}) : super(key: key);

  @override
  State<AddComplexity> createState() => AddComplexityState();
}

class AddComplexityState extends State<AddComplexity> {
  final formKey = GlobalKey<FormState>();
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
          color: CupertinoColors.white,
        ),
        backgroundColor: kAppBarColor,
        title: Text(
          "Add Complexity",
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
                controller: complexityController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Complexity Name Required";
                  }
                  return null;
                },
                keyboardType: TextInputType.name,
                labelText: "Complexity Name",
                obscureText: false,
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: button(
                  buttonName: "Add Complexity",
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
        await addComplexity();
        showSnackBar(
            context: context, message: "Complexity Added Successfully");
        Navigator.of(context).pop();
      } catch (e) {
        showSnackBar(context: context, message: "Error: $e");
      }
    }
  }

  Future<void> addComplexity() async {
    try {
      int lastComplexityID = await getLastID(
          collectionName: "complexity", primaryKey: "complexityID");
      int newComplexityID = lastComplexityID + 1;
      await FirebaseFirestore.instance.collection("complexity").add({
        "complexityID": newComplexityID.toString(),
        "complexityName": complexityController.text.trim(),
      });
    } catch (e) {
      throw ("Error adding complexity: $e",);
    }
  }
}
