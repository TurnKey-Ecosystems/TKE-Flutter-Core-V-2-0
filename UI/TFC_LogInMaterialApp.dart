import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'TFC_CustomWidgets.dart';
import 'TFC_ReloadableWidget.dart';
import 'TFC_AppStyle.dart';
import 'TFC_InputFields.dart';
import '../APIs/TFC_PlatformAPI.dart';

class TFC_LogInMaterialApp extends StatelessWidget {
  static late String correctPasscode;
  static String passcodeAttempt = "";
  static String? failedPasscodeAttempt = null;
  static bool passcodeIsCorrect = false;
  static updatePasscodeIsCorrect() {
    if (TFC_LogInMaterialApp.passcodeAttempt.toLowerCase() ==
        TFC_LogInMaterialApp.correctPasscode.toLowerCase()) {
      TFC_LogInMaterialApp.passcodeIsCorrect = true;
    } else {
      failedPasscodeAttempt = passcodeAttempt;
      TFC_LogInMaterialApp.passcodeIsCorrect = false;
    }
  }

  static getTextFieldColor() {
    if (passcodeAttempt == failedPasscodeAttempt) {
      return TFC_AppStyle.COLOR_ERROR;
    } else {
      return TFC_AppStyle.COLOR_HINT;
    }
  }

  TFC_LogInMaterialApp(String correctPasscode) {
    TFC_LogInMaterialApp.correctPasscode = correctPasscode;
  }

  @override
  Widget build(BuildContext context) {
    // Set the ios status bar color
    TFC_PlatformAPI.platformAPI.setWebBackgroundColor("#ffffff");
    TFC_PlatformAPI.platformAPI.hideHTMLSplashScreen();

    return MaterialApp(
      theme: TFC_AppStyle.themeData,
      home: _TFC_LogInScaffold(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _TFC_LogInScaffold extends TFC_ReloadableWidget {
  @override
  void onInit() {
    super.onInit();

    // Lock orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget buildWidget(BuildContext context) {
    final double internalWidth = TFC_AppStyle.instance.internalPageWidth -
        (2.0 * TFC_AppStyle.instance.pageMargins);
    final double textFieldWidth = 0.58 * internalWidth;
    final double submitButtonWidth = internalWidth - textFieldWidth;
    final double submitButtonHeight = (2.0 * TFC_AppStyle.instance.pageMargins);

    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: internalWidth + (2.0 * TFC_AppStyle.instance.pageMargins),
            height:
                submitButtonHeight + (2.0 * TFC_AppStyle.instance.pageMargins),
            //margin: EdgeInsets.all(1.0 * TFC_AppStyle.instance.pageMargins),
            decoration: BoxDecoration(
              border: Border.all(
                  color: TFC_LogInMaterialApp.getTextFieldColor(),
                  width: 0.0625 * TFC_AppStyle.instance.pageMargins),
              borderRadius: BorderRadius.all(
                  Radius.circular(0.25 * TFC_AppStyle.instance.pageMargins)),
            ),
            alignment: Alignment.center,
            child: Container(
              height: submitButtonHeight +
                  (2.0 * TFC_AppStyle.instance.pageMargins),
              width: internalWidth,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    //height: submitButtonHeight,
                    width: textFieldWidth,
                    alignment: Alignment.topCenter,
                    child: TFC_TextField(
                      hintText: "Enter Passcode",
                      getSourceValue: () {
                        return TFC_LogInMaterialApp.passcodeAttempt;
                      },
                      setSourceValue: (String newValue) {
                        TFC_LogInMaterialApp.passcodeAttempt = newValue;
                      },
                      onSubmitted: () {
                        TFC_LogInMaterialApp.updatePasscodeIsCorrect();
                        reload();
                      },
                      unfocusedNonblankInputBorderColor: Colors.transparent,
                      focusedInputBorderColor: Colors.transparent,
                      unfocusedBlankInputBorderColor: Colors.transparent,
                      borderType: TFC_BorderType.UNDERLINED,
                    ),
                  ),
                  Container(
                    height: submitButtonHeight,
                    width: submitButtonWidth,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            TFC_AppStyle.colorPrimary),
                        elevation: MaterialStateProperty.all(0.0),
                      ),
                      onPressed: () {
                        TFC_LogInMaterialApp.updatePasscodeIsCorrect();
                        reload();
                      },
                      child: TFC_Text.body(
                        "Submit Code",
                        color: TFC_AppStyle.COLOR_BACKGROUND,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: submitButtonHeight,
          )
        ]),
      ),
    );
  }
}
