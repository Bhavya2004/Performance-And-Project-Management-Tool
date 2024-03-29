import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SkillListPage extends StatelessWidget {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  SkillListPage({super.key});

  // Method to add a new skill
  Future<void> _addNewSkill(BuildContext context) async {
    final TextEditingController _controller = TextEditingController();

    final String? newSkillName = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Skill"),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: "Enter Skill Name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, _controller.text);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );

    // Add the new skill to Firestore
    if (newSkillName != null && newSkillName.isNotEmpty) {
      DocumentReference docRef =
      await _db.collection('skills').add({'skillName': newSkillName});
      await docRef.update({'skillID': docRef.id});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$newSkillName added"),
        ),
      );
    }
  }

  Future<void> _editSkill(BuildContext context, DocumentSnapshot doc) async {
    final TextEditingController _controller =
    TextEditingController(text: doc['skillName']);

    final String? updatedSkillName = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Skill"),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: "Enter Skill Name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, _controller.text);
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );

    // Update the skill in Firestore
    if (updatedSkillName != null && updatedSkillName.isNotEmpty) {
      await _db
          .collection('skills')
          .doc(doc.id)
          .update({'skillName': updatedSkillName});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Skill updated"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Skills"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('skills').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final DocumentSnapshot doc = snapshot.data!.docs[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(doc['skillName']),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _editSkill(context, doc),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewSkill(context),
        child: Icon(Icons.add),
      ),
    );
  }
}