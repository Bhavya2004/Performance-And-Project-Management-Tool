import 'package:flutter/cupertino.dart';

Future<bool> showConfirmationPopup(context,
    {dynamic yesFunction, dynamic title, dynamic content}) async {
  return await showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            fontFamily: 'SF-Pro',
          ),
        ),
        content: Text(
          content,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontFamily: 'SF-Pro',
          ),
        ),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: yesFunction,
            child: const Text(
              "Yes",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: CupertinoColors.destructiveRed,
                fontFamily: 'SF-Pro',
              ),
            ),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "No",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: CupertinoColors.activeGreen,
                fontFamily: 'SF-Pro',
              ),
            ),
          ),
        ],
      );
    },
  );
}
