import 'package:flutter/material.dart';

Widget button(
    {dynamic onPressed,
    dynamic buttonName,
    dynamic backgroundColor,
    dynamic textColor}) {
  return Container(
    height: 60,
    width: double.infinity,
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(18),
    ),
    child: TextButton(
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.resolveWith(
          (states) => Colors.black12,
        ),
      ),
      onPressed: onPressed,
      child: Text(
        buttonName,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
  );
}
