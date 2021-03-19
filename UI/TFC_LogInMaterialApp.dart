import 'package:flutter/material.dart';
import 'TFC_AppStyle.dart';
import 'TFC_InputFields.dart';
import 'TFC_PaddedColumn.dart';
import '../APIs/TFC_WebExclusiveAPI.dart';

class TFC_LogInMaterialApp extends StatelessWidget {
  static String correctPasscode;
  static String passcodeAttempt = "";
  static bool get passcodeIsCorrect {
    return passcodeAttempt.toLowerCase() == correctPasscode.toLowerCase();
  }

  TFC_LogInMaterialApp(String correctPasscode) {
    TFC_LogInMaterialApp.correctPasscode = correctPasscode;
  }

  @override
  Widget build(BuildContext context) {
    // Set the ios status bar color
    TFC_WebExclusiveAPI.setWebBackgroundColor("#ffffff");

    return MaterialApp(
      theme: TFC_AppStyle.themeData,
      home: _TFC_LogInScaffold(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _TFC_LogInScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(4 * TFC_AppStyle.instance.pageMargins),
        child: TFC_TextField(
          hintText: "Enter Passcode",
          getSourceValue: () {
            return TFC_LogInMaterialApp.passcodeAttempt;
          },
          setSourceValue: (String newValue) {
            TFC_LogInMaterialApp.passcodeAttempt = newValue;
          },
        ),
      ),
    );
  }
}
