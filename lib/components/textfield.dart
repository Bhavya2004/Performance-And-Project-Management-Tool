import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ppmt/constants/color.dart';

Widget textFormField(
    {required String? Function(String?)? validator,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required String labelText,
    Widget? prefixIcon,
    required bool obscureText,
    dynamic inputFormatNumber}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
    child: Focus(
      child: TextFormField(
        obscureText: obscureText,
        validator: validator,
        inputFormatters: [LengthLimitingTextInputFormatter(inputFormatNumber)],
        controller: controller,
        keyboardType: keyboardType,
        cursorColor: AppColor.elephant,
        cursorHeight: 20,
        cursorWidth: 2,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            fontWeight: FontWeight.w400,
            color: AppColor.elephant,
          ),
          prefixIcon: prefixIcon,
          fillColor: AppColor.white,
        ),
      ),
    ),
  );
}
