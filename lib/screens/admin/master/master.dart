import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
        title: const Text('Master'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed("/level_list");
                  },
                  child: Card(
                    margin: EdgeInsets.all(10),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: StreamBuilder<QuerySnapshot>(
                        stream:
                            firebaseFirestore.collection('levels').snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return SizedBox(
                              height: 60,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Levels",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "${snapshot.data!.docs.length}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const CircularProgressIndicator();
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed("/skill_list");
                  },
                  child: Card(
                    margin: EdgeInsets.all(10),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: StreamBuilder<QuerySnapshot>(
                        stream:
                            firebaseFirestore.collection('skills').snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return SizedBox(
                              height: 60,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Skills",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "${snapshot.data!.docs.length}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const CircularProgressIndicator();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed("/complexity_list");
                  },
                  child: Card(
                    margin: EdgeInsets.all(10),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: firebaseFirestore
                            .collection('complexity')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return SizedBox(
                              height: 60,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Complexity",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "${snapshot.data!.docs.length}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const CircularProgressIndicator();
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed("/task_list");
                  },
                  child: Card(
                    margin: EdgeInsets.all(10),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: StreamBuilder<QuerySnapshot>(
                        stream:
                            firebaseFirestore.collection('task').snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return SizedBox(
                              height: 60,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Task",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "${snapshot.data!.docs.length}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const CircularProgressIndicator();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
