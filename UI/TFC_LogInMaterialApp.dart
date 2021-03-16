import 'package:flutter/material.dart';
import 'TFC_AppStyle.dart';
import 'TFC_InputFields.dart';
import 'TFC_PaddedColumn.dart';

class TFC_LogInMaterialApp extends StatelessWidget {
  static String passwordAttempt = "";
  static bool get passwordIsCorrect {
    return passwordAttempt == "Axiom-Hoist-123";
  }

  @override
  Widget build(BuildContext context) {
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
        padding: EdgeInsets.all(TFC_AppStyle.instance.pageMargins),
        child: TFC_TextField(
          hintText: "Enter Password",
          getSourceValue: () {
            return TFC_LogInMaterialApp.passwordAttempt;
          },
          setSourceValue: (String newValue) {
            TFC_LogInMaterialApp.passwordAttempt = newValue;
          },
        ),
      ),
    );
  }
}
