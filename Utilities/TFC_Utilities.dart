import 'dart:async';
import 'dart:developer';
import 'package:tke_dev_time_tracker_flutter_tryw/TKE-Flutter-Core/APIs/TFC_Failable.dart';

import '../UI/PrebuiltWidgets/TFC_InputFields.dart';
import '../AppManagment/TFC_FlutterApp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import '../AppManagment/TFC_DiskController.dart';
import '../AppManagment/TFC_EmailController.dart';

class TFC_Utilities {
  static Future<void> when(bool Function() condition) async {
    // Wait until the condition has been met
    while (!condition()) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }


  /** Attempts a given list of functions concurrently until they all succeed or the maxFailureRate is surpassed. */
  static Future<TFC_Failable<List<ReturnType>>> runFunctionsConcurrently<ReturnType>({
    required List<Future<TFC_Failable<ReturnType>> Function()> functions,
    required double maxFailureRate,
  }) async {
    debugPrint("runFunctionsConcurrently() called!");

    // This will help us track each function
    List<_ConcurrentFunctionManager<ReturnType>> functionManagers = [];

    // Start all the functions
    for (Future<TFC_Failable<ReturnType>> Function() function in functions) {
      // Create a function manager
      _ConcurrentFunctionManager<ReturnType> functionManager =
        _ConcurrentFunctionManager.of(function);

      // Add the function manager
      functionManagers.add(functionManager);

      // Start the function
      functionManager.start();
    }

    // Wait until all the functions stop.
    await TFC_Utilities.when(() {
      // Tally up the stats on all the functions
      bool allFunctionsHaveStopped = true;
      int totalFaliureCount = 0;
      for (_ConcurrentFunctionManager<ReturnType> functionManager in functionManagers) {
        allFunctionsHaveStopped = allFunctionsHaveStopped && functionManager.hasStopped;
        debugPrint("hasStopped: ${functionManager.hasStopped}");
        totalFaliureCount += functionManager.failureCount;
      }
      debugPrint("totalFaliureCount: ${totalFaliureCount}");
      debugPrint("allFunctionsHaveStopped: ${allFunctionsHaveStopped}");

      // If the falure rate is too high, then stop
      if ((totalFaliureCount / functions.length) > maxFailureRate) {
        for (_ConcurrentFunctionManager<ReturnType> functionManager in functionManagers) {
          functionManager.stop();
        }
      }

      // Only continue once all the functions have stopped
      return allFunctionsHaveStopped;
    });

    // Determine whether or not 
    bool allFunctionsSucceeded = true;
    for (_ConcurrentFunctionManager<ReturnType> functionManager in functionManagers) {
      allFunctionsSucceeded = allFunctionsSucceeded && functionManager.succeeded;
    }

    // Handle success
    if (allFunctionsSucceeded) {
      // Compiled all the returned values
      List<ReturnType> returnedValues = [];
      for (_ConcurrentFunctionManager<ReturnType> functionManager in functionManagers) {
        returnedValues.add(functionManager.returnedValue!);
      }

      // Return the returned valeus
      return TFC_Failable.succeeded(returnValue: returnedValues);

    // Handled failure
    } else {
      return TFC_Failable.failed(
        returnValue: [],
        errorObject: Exception("One or more of the functions could not be completed successfully."),
      );
    }
  }

  static ObjectType? tryReadJson<ObjectType>(
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
    String Function(Match) commaFunction = (Match match) => '${match[1]},';
    String numberText = numberTextParts[0].replaceAllMapped(reg, commaFunction);
    if (numberTextParts.length > 1) {
      numberText += "." + numberTextParts[1];
    }
    return numberText;
  }

  static void closeTheKeyboard(BuildContext? context) {
    if (TFC_InputField.focus != null && TFC_InputField.focus!.hasFocus) {
      TFC_InputField.focus!.unfocus();
    } else if (context != null) {
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





/** Manages a concurrent function for TFC_Utilities.runFunctionsConcurrently() */
class _ConcurrentFunctionManager<ReturnType> {
  /** The actual function to run. */
  final Future<TFC_Failable<ReturnType>> Function() _function;

  /** Creates a new concurrent function manager. */
  _ConcurrentFunctionManager.of(this._function);


  /** Actually run the function */
  void start() async {
    // Keep attempting the function until it is time to stop
    while (!_shouldStop) {
      // Attempt the function
      TFC_Failable<ReturnType> result = await _function();

      // Handle function success
      if (result.succeeded) {
        // Record the returned value
        _returnedValue = result.returnValue;

        // Record the fact that this function was a success
        _succeeded = true;

        // There is no need to keep running
        _shouldStop = true;
        
      // Handle function failure
      } else {
        // Record the failure
        _failureCount++;
      }
    }

    // This function has stopped.
    _hasStopped = true;
  }


  /** Whether or not the function should stop after the current attempt finishes. */
  bool _shouldStop = false;
  /** Tell the function to stop after the current attempt finishes. */
  void stop() {
    _shouldStop = true;
  }


  /** Whether or not this function has stopped */
  bool _hasStopped = false;
  /** Whether or not this function has stopped */
  bool get hasStopped {
    return _hasStopped;
  }


  /** Whether or not the function finished successfully. */
  bool _succeeded = false;
  /** Whether or not the function finished successfully. */
  bool get succeeded {
    return _succeeded;
  }

  /** Whether or not the function failed. */
  bool get failed {
    return !_succeeded;
  }


  /** The number of times this function has failed. */
  int _failureCount = 0;
  /** The number of times this function has failed. */
  int get failureCount {
    return _failureCount;
  }


  /** The value returned from the function. */
  ReturnType? _returnedValue = null;
  /** The value returned from the function. */
  ReturnType? get returnedValue {
    return _returnedValue;
  }
}