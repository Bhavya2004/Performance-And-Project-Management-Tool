import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ppmt/constants/color.dart';

class PersonalDetails extends StatefulWidget {
  final String userID;

  PersonalDetails({super.key, required this.userID});

  @override
  State<PersonalDetails> createState() => _PersonalDetailsState();
}

class _PersonalDetailsState extends State<PersonalDetails> {
  Future<QuerySnapshot> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .where('userID', isEqualTo: widget.userID)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<QuerySnapshot>(
        future: getUserDetails(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CupertinoActivityIndicator(
                color: kAppBarColor,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error fetching user details',
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'User not found',
              ),
            );
          }

          var userData = snapshot.data!.docs.first.data() as Map<String, dynamic>;

          final userName = userData['name'] as String;
          final firstCharacter =
          userName.isNotEmpty ? userName[0].toUpperCase() : '';
          final random = Random();
          final randomColor = Color.fromARGB(
            255,
            random.nextInt(256),
            random.nextInt(256),
            random.nextInt(256),
          );

          final textColor = randomColor.computeLuminance() > 0.5
              ? Colors.black
              : Colors.white;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: randomColor,
                      child: Text(
                        firstCharacter,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 50,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      '${userData['name'] ?? 'No Name'} ${userData['surname'] ?? 'No Surname'}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  buildDetailRow(Icons.email, 'Email', userData['email']),
                  buildDetailRow(Icons.phone, 'Phone', userData['phoneNumber']),
                  buildDetailRow(Icons.location_on, 'Address', userData['address']),
                  buildDetailRow(Icons.person, 'Role', userData['role']),
                  buildDetailRow(
                    userData['isDisabled'] ? Icons.block : Icons.check_circle,
                    'Account Status',
                    userData['isDisabled'] ? 'Disabled' : 'Active',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildDetailRow(IconData icon, String label, String? value) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: kAppBarColor),
            SizedBox(width: 10),
            Text(
              '$label: ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Expanded(
              child: Text(
                value ?? 'N/A',
                style: TextStyle(fontSize: 16),
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
