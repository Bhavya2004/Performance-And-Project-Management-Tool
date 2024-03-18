import 'package:flutter/material.dart';
import 'package:ppmt/constants/color.dart';

void showSnackBar({dynamic message, dynamic context}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      duration: Duration(seconds: 2),
      backgroundColor: AppColor.elephant,
    ),
  );
}
