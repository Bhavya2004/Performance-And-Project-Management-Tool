import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/constants/color.dart';

class Master extends StatefulWidget {
  const Master({Key? key}) : super(key: key);

  @override
  State<Master> createState() => _MasterState();
}

class _MasterState extends State<Master> {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: AppColor.white,
        ),
        backgroundColor: AppColor.sanMarino,
        title: Text(
          'Master',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColor.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildCard(
              onTap: () {
                Navigator.of(context).pushNamed("/level_list");
              },
              icon: "assets/icons/levels.png",
              label: "Levels",
              stream: firebaseFirestore.collection('levels').snapshots(),
            ),
            buildCard(
              onTap: () {
                Navigator.of(context).pushNamed("/skill_list");
              },
              icon: "assets/icons/skills.png",
              label: "Skills",
              stream: firebaseFirestore.collection('skills').snapshots(),
            ),
            buildCard(
              onTap: () {
                Navigator.of(context).pushNamed("/complexity_list");
              },
              icon: "assets/icons/complexity.png",
              label: "Complexity",
              stream: firebaseFirestore.collection('complexity').snapshots(),
            ),
            buildCard(
              onTap: () {
                Navigator.of(context).pushNamed("/task_list");
              },
              icon: "assets/icons/tasks.png",
              label: "Task",
              stream: firebaseFirestore.collection('tasks').snapshots(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCard({
    required VoidCallback onTap,
    required String icon,
    required String label,
    required Stream<QuerySnapshot> stream,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.all(10),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Image.asset(
                icon,
                height: 75,
                width: 75,
              ),
              SizedBox(width: 20),
              StreamBuilder<QuerySnapshot>(
                stream: stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "(${snapshot.data!.docs.length})",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    );
                  }
                  return CircularProgressIndicator();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
