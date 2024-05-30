import 'package:flutter/material.dart';
import 'package:ppmt/constants/color.dart';

class ProjectInformation extends StatefulWidget {
  final Map<String, dynamic> projectData;

  ProjectInformation({Key? key, required this.projectData}) : super(key: key);

  @override
  _ProjectInformationState createState() => _ProjectInformationState();
}

class _ProjectInformationState extends State<ProjectInformation> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final projectData = widget.projectData;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
          ),
          padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20),
              _buildCard('Project Name', projectData['projectName']),
              _buildCard('Description', projectData['projectDescription']),
              _buildCard('Start Date', projectData['startDate']),
              _buildCard('End Date', projectData['endDate']),
              _buildCard('Project Status', projectData['projectStatus']),
              _buildCard('Management Points', projectData['managementPoints']),
              _buildCard('Total Bonus', projectData['totalBonus']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String label, dynamic value) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: kAppBarColor,
                ),
              ),
              SizedBox(height: 5),
              Text(
                value.toString().isNotEmpty ? value.toString() : 'N/A',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
