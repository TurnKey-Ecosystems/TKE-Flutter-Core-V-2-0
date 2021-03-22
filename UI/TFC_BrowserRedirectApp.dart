import 'package:flutter/material.dart';
import '../UI/TFC_Button.dart';
import 'TFC_CustomWidgets.dart';
import 'TFC_ReloadableWidget.dart';
import 'TFC_AppStyle.dart';
import '../APIs/TFC_WebExclusiveAPI.dart';

class TFC_BrowserRedirectApp extends StatelessWidget {
  static final String toChromeInstructions =
      "Open the above URL in the Chrome web browser.";
  static final String toSafariInstructions =
      "Open the abvoe URL in the Safari web browser.";
  static final String unkownOSInstructions =
      " - If you are using an Android phone, make sure you are using the Chrome web browser.\n\n - If you are using an iPhone, make sure you are using the Safari web browser.";
  static TFC_BrowserAndOSTestResults browserAndOSTestResults;
  static bool shouldContinuePastThisPage = false;

  TFC_BrowserRedirectApp(TFC_BrowserAndOSTestResults browserAndOSTestResults) {
    TFC_BrowserRedirectApp.browserAndOSTestResults = browserAndOSTestResults;
  }

  @override
  Widget build(BuildContext context) {
    // Set the ios status bar color
    TFC_WebExclusiveAPI.setWebBackgroundColor("#ffffff");

    return MaterialApp(
      theme: TFC_AppStyle.themeData,
      home: _TFC_BrowserRedirectScaffold(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _TFC_BrowserRedirectScaffold extends TFC_ReloadableWidget {
  @override
  void onInit() {
    super.onInit();
    if (TFC_BrowserRedirectApp.browserAndOSTestResults.isCorrectBrowserForOS) {
      TFC_BrowserRedirectApp.shouldContinuePastThisPage = true;
    }
  }

  @override
  Widget buildWidget(BuildContext context) {
    final TFC_OperatingSystem os =
        TFC_BrowserRedirectApp.browserAndOSTestResults.os;
    final TFC_Browser browser =
        TFC_BrowserRedirectApp.browserAndOSTestResults.browser;

    if (os == TFC_OperatingSystem.UNKNOWN) {
      return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TFC_Text.body(TFC_BrowserRedirectApp.unkownOSInstructions),
            TFC_Button.flat(
              onPressed: () {
                TFC_BrowserRedirectApp.shouldContinuePastThisPage = true;
              },
              child: TFC_Text.body(
                "Continue",
                color: TFC_AppStyle.COLOR_BACKGROUND,
              ),
            ),
          ],
        ),
      );
    } else {
      String step2Instructions;
      if (os == TFC_OperatingSystem.ANDROID && browser != TFC_Browser.CHROME) {
        step2Instructions = TFC_BrowserRedirectApp.toChromeInstructions;
      } else if (os == TFC_OperatingSystem.IOS &&
          browser != TFC_Browser.SAFARI) {
        step2Instructions = TFC_BrowserRedirectApp.toSafariInstructions;
      }

      return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TFC_Text.subheading("Step 1"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TFC_Text.body("Copy this website's URL: " +
                    TFC_WebExclusiveAPI.getCurrentURL()),
                TFC_Button.flat(
                    onPressed: () {
                      TFC_WebExclusiveAPI.copyTextToClipBoard(
                          TFC_WebExclusiveAPI.getCurrentURL());
                    },
                    child: TFC_Text.body(
                      "Copy URL",
                      color: TFC_AppStyle.COLOR_BACKGROUND,
                    )),
              ],
            ),
            TFC_Text.subheading("Step 2"),
            TFC_Text.body(step2Instructions),
          ],
        ),
      );
    }
  }
}
