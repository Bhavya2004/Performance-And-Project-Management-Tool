// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:ppmt/components/button.dart';
// import 'package:ppmt/components/snackbar.dart';
// import 'package:ppmt/components/textfield.dart';
//
// class ProjectDetails extends StatefulWidget {
//   final String projectId;
//
//   const ProjectDetails({Key? key, required this.projectId}) : super(key: key);
//
//   @override
//   _ProjectDetailsState createState() => _ProjectDetailsState();
// }
//
// class _ProjectDetailsState extends State<ProjectDetails> {
//   TextEditingController projectNameController = TextEditingController();
//   TextEditingController descriptionController = TextEditingController();
//   TextEditingController skillController = TextEditingController();
//   List<String> skills = [];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchProjectDetails();
//   }
//
//   Future<void> fetchProjectDetails() async {
//     DocumentSnapshot projectDoc = await FirebaseFirestore.instance
//         .collection('projects')
//         .doc(widget.projectId)
//         .get();
//     var data = projectDoc.data() as Map<String, dynamic>;
//     projectNameController.text = data['projectName'];
//     descriptionController.text = data['projectDescription'];
//     if (data['skills'] != null) {
//       skills = List<String>.from(data['skills']);
//     }
//     setState(() {});
//   }
//
//   Future<void> updateProjectDetails() async {
//     try {
//       await FirebaseFirestore.instance.collection('projects').doc(widget.projectId).update({
//         'projectName': projectNameController.text.trim(),
//         'projectDescription': descriptionController.text.trim(),
//         'skills': skills,
//       });
//       showSnackBar(context: context, message: "Project Updated Successfully");
//     } catch (e) {
//       showSnackBar(context: context, message: "Error: $e");
//     }
//   }
//
//   void addSkill() {
//     if (skillController.text.trim().isNotEmpty) {
//       setState(() {
//         skills.add(skillController.text.trim());
//         skillController.clear();
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     projectNameController.dispose();
//     descriptionController.dispose();
//     skillController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: IconThemeData(
//           color: Colors.white,
//         ),
//         backgroundColor: Colors.blue,
//         title: Text(
//           'Project Details',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           child: ListView(
//             children: [
//               textFormField(
//                 obscureText: false,
//                 controller: projectNameController,
//                 labelText: "Project Name",
//                 maxLength: 30,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a project name';
//                   }
//                   return null;
//                 },
//                 keyboardType: TextInputType.text,
//               ),
//               textFormField(
//                 obscureText: false,
//                 controller: descriptionController,
//                 labelText: "Description",
//                 maxLength: 1000,
//                 maxLine: 5,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a description';
//                   }
//                   return null;
//                 },
//                 keyboardType: TextInputType.multiline,
//               ),
//               SizedBox(height: 20),
//               Text(
//                 "Skills",
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               ...skills.map((skill) => ListTile(
//                 title: Text(skill),
//                 trailing: IconButton(
//                   icon: Icon(Icons.delete),
//                   onPressed: () {
//                     setState(() {
//                       skills.remove(skill);
//                     });
//                   },
//                 ),
//               )),
//               textFormField(
//                 obscureText: false,
//                 controller: skillController,
//                 labelText: "Add Skill",
//                 validator: (value) {
//                   return null; // No validation needed for adding skills
//                 },
//                 keyboardType: TextInputType.text,
//               ),
//               SizedBox(height: 10),
//               button(
//                 onPressed: addSkill,
//                 buttonName: 'Add Skill',
//                 backgroundColor: Colors.blue,
//                 textColor: Colors.white,
//               ),
//               SizedBox(height: 20),
//               button(
//                 onPressed: updateProjectDetails,
//                 buttonName: 'Save',
//                 backgroundColor: Colors.blue,
//                 textColor: Colors.white,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
