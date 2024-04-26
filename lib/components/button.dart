import 'package:flutter/material.dart';
import 'package:ppmt/constants/color.dart';

Widget button({dynamic onPressed, dynamic buttonName}) {
  return Container(
    margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
    height: 58,
    width: double.infinity,
    decoration: BoxDecoration(
      color: AppColor.black,
      borderRadius: BorderRadius.circular(4),
      boxShadow: [
        BoxShadow(
          color: AppColor.black.withOpacity(0.25),
          offset: const Offset(0.0, 4.0),
          blurRadius: 4.0,
          spreadRadius: 0.0,
        ),
      ],
    ),
    child: TextButton(
      onPressed: onPressed,
      child: Text(
        buttonName,
        style: TextStyle(
          color: AppColor.white,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    ),
  );
}
