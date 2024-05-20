import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget textFormField({
  required String? Function(String?)? validator,
  required TextEditingController controller,
  required TextInputType keyboardType,
  required String labelText,
  Widget? prefixIcon,
  required bool obscureText,
  dynamic inputFormatNumber,
  bool enabled = true,
  dynamic maxLength,
  dynamic maxLine, dynamic initialValue,
}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
    child: Focus(
      child: TextFormField(
        enabled: enabled,
        initialValue: initialValue,
        obscureText: obscureText,
        validator: validator,
        inputFormatters: [LengthLimitingTextInputFormatter(inputFormatNumber)],
        controller: controller,
        keyboardType: keyboardType,
        cursorColor: CupertinoColors.black,
        cursorHeight: 20,
        cursorWidth: 2,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: Colors.black,
            fontSize: 15,
          ),
        ),
      ),
    ),
  );
}
