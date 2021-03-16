import 'dart:async';
import 'dart:developer';
import '../UI/TFC_InputFields.dart';
import '../AppManagment/TFC_FlutterApp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import '../AppManagment/TFC_DiskController.dart';
import '../AppManagment/TFC_EmailController.dart';

class TFC_Utilities {
  static Future<void> when(bool Function() condition) async {
    // Wait until the condition has been met
    while (!condition()) {
      await Future.delayed(const Duration(milliseconds: 100), () => "100");
    }
  }

  static ObjectType tryReadJson<ObjectType>(
      Map<String, dynamic> decodedJson, String jsonKey) {
    if (decodedJson != null && decodedJson.containsKey(jsonKey)) {
      return decodedJson[jsonKey];
    } else {
      return null;
    }
  }

  static String getPrintableNum(num number, int decimalCount) {
    List<String> numberTextParts =
        number.toStringAsFixed(decimalCount).split(".");
    RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    Function commaFunction = (Match match) => '${match[1]},';
    String numberText = numberTextParts[0].replaceAllMapped(reg, commaFunction);
    if (numberTextParts.length > 1) {
      numberText += "." + numberTextParts[1];
    }
    return numberText;
  }

  static void closeTheKeyboard(BuildContext context) {
    if (TFC_InputField.focus != null && TFC_InputField.focus.hasFocus) {
      TFC_InputField.focus.unfocus();
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  static Future<void> tryToEmailAllLocalFilesToTKE() async {
    String exportFilePath = TFC_DiskController.exportAllFiles();

    MailOptions mailOptions = MailOptions(
      // TODO: Put more information in the export body and subject
      subject: "Here are all the files from ${TFC_FlutterApp.appName}.",
      body:
          "Something may have gone wrong. Exported all files from ${TFC_FlutterApp.appName}.",
      recipients: ["dev@tke.us"],
      isHTML: false,
      attachments: [
        exportFilePath,
      ],
    );

    TFC_EmailController.tryToSendEmail(mailOptions);

    return null;
  }

  static const String _ELLIPSIS = "...";
  static String formatTextToMaxLength(String text, int maxLength) {
    String formattedText = text;

    if (formattedText != null && formattedText.length > maxLength) {
      formattedText = formattedText.substring(0, maxLength - _ELLIPSIS.length);
      formattedText += _ELLIPSIS;
    }

    return formattedText;
  }

  static Color blendColors(Color color1, Color color2,
      {double color1Weight = 0.5}) {
    double color2Weight = 1 - color1Weight;
    int alpha =
        ((color1Weight * color1.alpha) + (color2Weight * color2.alpha)).toInt();
    int red =
        ((color1Weight * color1.red) + (color2Weight * color2.red)).toInt();
    int green =
        ((color1Weight * color1.green) + (color2Weight * color2.green)).toInt();
    int blue =
        ((color1Weight * color1.blue) + (color2Weight * color2.blue)).toInt();
    return Color.fromARGB(alpha, red, green, blue);
  }

  static int timeOfLastLog = 0;
  static void logChangeInTime(String message) {
    int timeDifference = DateTime.now().millisecondsSinceEpoch - timeOfLastLog;
    log("$timeDifference: " + message);
    timeOfLastLog = DateTime.now().millisecondsSinceEpoch;
  }
}
