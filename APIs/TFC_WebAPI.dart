import 'dart:developer';
import 'dart:html';
import 'dart:js';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:tke_iquote_flutter_hj4s/TKE-Flutter-Core/APIs/TFC_IDeviceStorageAPI.dart';
import 'package:tke_iquote_flutter_hj4s/TKE-Flutter-Core/AppManagment/TFC_DiskController.dart';
import '../APIs/TFC_WebShareAPI.dart';
import '../APIs/TFC_WebStorageAPI.dart';
import '../APIs/TFC_PlatformAPI.dart';

class TFC_APIForThisPlatform extends TFC_PlatformAPI {
  TFC_WebStorageAPI deviceStorageAPI = TFC_WebStorageAPI();
  TFC_WebShareAPI shareAPI = TFC_WebShareAPI();

  // Web Exclusive Overrides
  @override
  void setWebBackgroundColor(String hexColor) async {
    if (kIsWeb) {
      context.callMethod('setWebBackgroundColor', [hexColor]);
    }
  }

  @override
  void hideHTMLSplashScreen() async {
    if (kIsWeb) {
      context.callMethod('hideHTMLSplashScreen', []);
    }
  }

  @override
  TFC_BrowserAndOSTestResults testBrowserAndOS() {
    if (kIsWeb) {
      JsObject resultsObject = context.callMethod('testBrowserAndOS', []);
      return TFC_BrowserAndOSTestResultsWeb.fromJSObject(resultsObject);
    } else {
      return null;
    }
  }

  @override
  void copyTextToClipBoard(String textToCopy) {
    if (kIsWeb) {
      context.callMethod('copyTextToClipBoard', [textToCopy]);
    }
  }

  @override
  void showInstallPrompt() {
    if (kIsWeb) {
      context.callMethod('showInstallPrompt', []);
    }
  }

  @override
  bool getIsInstalled() {
    if (kIsWeb) {
      return context.callMethod('getIsInstalled', []);
    } else {
      return false;
    }
  }

  @override
  String getCurrentURL() {
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

  @override
  String getPasscodeFromURL() {
    if (kIsWeb) {
      return window.location.search.substring(("?passcode=").length);
    } else {
      return "";
    }
  }
}

class TFC_BrowserAndOSTestResultsWeb extends TFC_BrowserAndOSTestResults {
  TFC_BrowserAndOSTestResultsWeb.fromJSObject(JsObject resultsObject) {
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
