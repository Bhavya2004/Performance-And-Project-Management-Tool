import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/constants/color.dart';

class AllocatedUserDetail extends StatelessWidget {
  final Map<String, dynamic> data;

  AllocatedUserDetail({required this.data});

  @override
  Widget build(BuildContext context) {
    String userID = data['userID'] ?? '';
    String projectID = data['projectID'] ?? '';
    String startDate = data['startDate'] ?? '';
    String endDate = data['endDate'] ?? '';
    String userAllocation = data['userAllocation'] ?? '';
    String managementPoints = data['managementPoints'] ?? '';
    String workPoints = data['workPoints'] ?? '';
    bool isDisabled = data['isDisabled'] ?? false;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: CupertinoColors.white,
        ),
        backgroundColor: kAppBarColor,
        title: Text(
          'User Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
      ),
      body: Card(
        margin: EdgeInsets.all(10),
        elevation: 5,
        child: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              ListTile(
                title: Text('User ID'),
                subtitle: Text(userID),
              ),
              ListTile(
                title: Text('Project ID'),
                subtitle: Text(projectID),
              ),
              ListTile(
                title: Text('Start Date'),
                subtitle: Text(startDate),
              ),
              ListTile(
                title: Text('End Date'),
                subtitle: Text(endDate),
              ),
              ListTile(
                title: Text('User Allocation'),
                subtitle: Text('$userAllocation%'),
              ),
              ListTile(
                title: Text('Management Points'),
                subtitle: Text(managementPoints),
              ),
              ListTile(
                title: Text('Work Points'),
                subtitle: Text(workPoints),
              ),
              ListTile(
                title: Text('Is Disabled'),
                subtitle: Text(isDisabled ? "Yes" : "No"),
              ),
            ],
          ).toList(),
        ),
      ),
    );
  }
}
