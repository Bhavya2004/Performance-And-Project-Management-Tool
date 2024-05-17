import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppmt/constants/color.dart';
import 'package:intl/intl.dart';

class AddProject extends StatefulWidget {
  final bool isUpdating;
  final String? projectId;
  final String? projectName;
  final String? description;
  final String? startDate;
  final String? endDate;
  final String? creator;
  final String? status;
  final String? managementPoints;
  final String? totalBonus;

  const AddProject({
    Key? key,
    this.isUpdating = false,
    this.projectId,
    this.projectName,
    this.description,
    this.startDate,
    this.endDate,
    this.creator,
    this.status,
    this.managementPoints,
    this.totalBonus,
  }) : super(key: key);

  @override
  State<AddProject> createState() => _AddProjectState();
}

class _AddProjectState extends State<AddProject> {
  final _formKey = GlobalKey<FormState>();
  final projectNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final managementPointsController = TextEditingController();
  final totalBonusController = TextEditingController();
  late String creator;
  late String status;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    projectNameController.text = widget.projectName ?? '';
    descriptionController.text = widget.description ?? '';
    managementPointsController.text = widget.managementPoints ?? '';
    totalBonusController.text = widget.totalBonus ?? '';
    creator =
        widget.creator ?? 'admin@gmail.com'; // Replace with actual admin email
    status = widget.status ?? 'ToDo';
    startDate = widget.startDate != null
        ? DateFormat('yyyy-MM-dd').parse(widget.startDate!)
        : null;
    endDate = widget.endDate != null
        ? DateFormat('yyyy-MM-dd').parse(widget.endDate!)
        : null;
  }

  @override
  void dispose() {
    projectNameController.dispose();
    descriptionController.dispose();
    managementPointsController.dispose();
    totalBonusController.dispose();
    super.dispose();
  }

  String generateProjectId() {
    final random = Random();
    final id = List<int>.generate(6, (_) => random.nextInt(10));
    return 'PR_${id.join()}';
  }

  Future<void> saveProject() async {
    if (_formKey.currentState!.validate()) {
      final projectId = widget.projectId ?? generateProjectId();

      final projectData = {
        'Project_ID': projectId,
        'Name': projectNameController.text,
        'Description': descriptionController.text,
        'Start Date': startDate != null
            ? DateFormat('yyyy-MM-dd').format(startDate!)
            : '',
        'End Date':
            endDate != null ? DateFormat('yyyy-MM-dd').format(endDate!) : '',
        'Status': status,
        'Creator_ID': creator,
        'Management_Points': managementPointsController.text,
        'Total_Bonus': totalBonusController.text,
      };

      final ref = FirebaseFirestore.instance.collection('Projects');
      if (widget.isUpdating) {
        await ref.doc(projectId).update(projectData);
      } else {
        await ref.doc(projectId).set(projectData);
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(widget.isUpdating
            ? 'Project updated successfully'
            : 'Project added successfully'),
      ));
      Navigator.pop(context);
    }
  }

  Future<void> deleteProject() async {
    if (widget.projectId != null) {
      final ref = FirebaseFirestore.instance.collection('Projects');
      await ref.doc(widget.projectId).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Project deleted successfully'),
      ));
      Navigator.pop(context);
    }
  }

  Future<void> kickOffProject() async {
    final ref = FirebaseFirestore.instance.collection('Projects');
    await ref.doc(widget.projectId).update({
      'Status': 'InProgress',
      'Start Date': DateFormat('yyyy-MM-dd').format(DateTime.now())
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Project kicked off successfully'),
    ));
    Navigator.pop(context);
  }

  Future<void> markAsComplete() async {
    final ref = FirebaseFirestore.instance.collection('Projects');
    await ref.doc(widget.projectId).update({
      'Status': 'Completed',
      'End Date': DateFormat('yyyy-MM-dd').format(DateTime.now())
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Project marked as complete'),
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    bool isInProgress = status == 'InProgress';
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: CupertinoColors.white,
        ),
        backgroundColor: kAppBarColor,
        title: Text(
          widget.isUpdating ? 'Update Project' : 'Add New Project',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: projectNameController,
                decoration: InputDecoration(labelText: 'Project Name'),
                maxLength: 30,
                enabled: !isInProgress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a project name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLength: 1000,
                maxLines: 5,
                enabled: !isInProgress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              ListTile(
                title: Text('Start Date'),
                subtitle: Text(startDate != null
                    ? DateFormat('yyyy-MM-dd').format(startDate!)
                    : ''),
                enabled: false,
                onTap: !isInProgress
                    ? () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() {
                            startDate = date;
                          });
                        }
                      }
                    : null,
              ),
              ListTile(
                title: Text('End Date'),
                subtitle: Text(endDate != null
                    ? DateFormat('yyyy-MM-dd').format(endDate!)
                    : ''),
                enabled: false,
                onTap: !isInProgress
                    ? () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() {
                            endDate = date;
                          });
                        }
                      }
                    : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Creator'),
                initialValue: creator,
                enabled: false,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Status'),
                initialValue: status,
                enabled: false,
              ),
              TextFormField(
                controller: managementPointsController,
                decoration: InputDecoration(labelText: 'Management Points'),
                keyboardType: TextInputType.number,
                enabled: !isInProgress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter management points';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: totalBonusController,
                decoration: InputDecoration(labelText: 'Total Bonus'),
                keyboardType: TextInputType.number,
                enabled: !isInProgress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter total bonus';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveProject,
                child: Text('Save'),
              ),
              if (widget.isUpdating && status == 'ToDo')
                ElevatedButton(
                  onPressed: deleteProject,
                  child: Text('Delete'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              if (widget.isUpdating && !isInProgress)
                ElevatedButton(
                  onPressed: kickOffProject,
                  child: Text('Kick Off'),
                ),
              if (widget.isUpdating && status == 'InProgress')
                ElevatedButton(
                  onPressed: markAsComplete,
                  child: Text('Mark as Complete'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
