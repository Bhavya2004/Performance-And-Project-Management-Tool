// ComplexityListPage.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ppmt/screens/admin/master/complexity/add_complexity.dart';

class ComplexityListPage extends StatelessWidget {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  ComplexityListPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complexity Levels"),
      ),
      body: StreamBuilder(
        stream: firebaseFirestore.collection('complexity').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          // Extract the documents from the snapshot
          var complexityItems = snapshot.data!.docs;

          // Function to build a ListTile from a document
          ListTile buildTile(DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return ListTile(
              title: Text(
                data['complexityName'],
              ),
              // You can add more functionality or customize ListTile as needed
            );
          }

          // Build the ListView with complexity items
          return ListView(
            children: complexityItems.map((doc) => buildTile(doc)).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text("Add Complexity"),
        icon: Icon(CupertinoIcons.add),
        onPressed: () {
          // Navigate to the screen for adding a new complexity level
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddComplexity(),
            ),
          );
        },
      ),
    );
  }
}
