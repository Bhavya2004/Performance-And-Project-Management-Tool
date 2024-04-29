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
    dynamic inputFormatNumber,
    bool enabled = true}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
    child: Focus(
      child: TextFormField(
        style: kBodyText.copyWith(
          color: Colors.black,
        ),
        enabled: enabled,
        obscureText: obscureText,
        validator: validator,
        inputFormatters: [LengthLimitingTextInputFormatter(inputFormatNumber)],
        controller: controller,
        keyboardType: keyboardType,
        cursorColor: AppColor.black,
        cursorHeight: 20,
        cursorWidth: 2,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: kBodyText,
        ),
      ),
    ),
  );
}
