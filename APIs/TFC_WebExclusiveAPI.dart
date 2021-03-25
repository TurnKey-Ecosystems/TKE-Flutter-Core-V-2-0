import 'dart:js';
import 'dart:html';
import 'package:flutter/foundation.dart';

class TFC_WebExclusiveAPI {
  static setWebBackgroundColor(String hexColor) async {
    if (kIsWeb) {
      context.callMethod('setWebBackgroundColor', [hexColor]);
    }
  }

  static hideHTMLSplashScreen() async {
    if (kIsWeb) {
      context.callMethod('hideHTMLSplashScreen', []);
    }
  }

  static TFC_BrowserAndOSTestResults testBrowserAndOS() {
    if (kIsWeb) {
      JsObject resultsObject = context.callMethod('testBrowserAndOS', []);
      return TFC_BrowserAndOSTestResults.fromJSObject(resultsObject);
    } else {
      return null;
    }
  }

  static void copyTextToClipBoard(String textToCopy) {
    if (kIsWeb) {
      context.callMethod('copyTextToClipBoard', [textToCopy]);
    }
  }

  static void showInstallPrompt() {
    if (kIsWeb) {
      context.callMethod('showInstallPrompt', []);
    }
  }

  static bool getIsInstalled() {
    if (kIsWeb) {
      return context.callMethod('getIsInstalled', []);
    } else {
      return false;
    }
  }

  static String getCurrentURL() {
    if (kIsWeb) {
      return window.location.protocol +
          "//" +
          window.location.host +
          "/" +
          window.location.pathname +
          window.location.search;
      //return context.callMethod('getCurrentURL', []);
    } else {
      return null;
    }
  }

  static String getPasscodeFromURL() {
    if (kIsWeb) {
      return window.location.search.substring(("?passcode=").length);
    } else {
      return "";
    }
  }
}

enum TFC_OperatingSystem { ANDROID, IOS, UNKNOWN }
enum TFC_Browser { CHROME, SAFARI, UNKNOWN }

class TFC_BrowserAndOSTestResults {
  TFC_OperatingSystem os;
  TFC_Browser browser;
  bool isCorrectBrowserForOS;

  TFC_BrowserAndOSTestResults.fromJSObject(JsObject resultsObject) {
    os = (resultsObject['os'] == 'android')
        ? TFC_OperatingSystem.ANDROID
        : (resultsObject['os'] == 'ios')
            ? TFC_OperatingSystem.IOS
            : TFC_OperatingSystem.UNKNOWN;
    browser = (resultsObject['browser'] == 'chrome')
        ? TFC_Browser.CHROME
        : (resultsObject['browser'] == 'safari')
            ? TFC_Browser.SAFARI
            : TFC_Browser.UNKNOWN;
    isCorrectBrowserForOS = resultsObject['isCorrectBrowserForOS'];
  }
}
