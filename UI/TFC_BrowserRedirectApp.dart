import 'package:flutter/material.dart';
import '../UI/TFC_Button.dart';
import 'TFC_CustomWidgets.dart';
import 'TFC_ReloadableWidget.dart';
import 'TFC_AppStyle.dart';
import '../APIs/TFC_WebExclusiveAPI.dart';
import 'dart:html' as html;

class TFC_BrowserRedirectApp extends StatelessWidget {
  static final String toChromeInstructions =
      "Paste the above URL into the Chrome web browser.";
  static final String toSafariInstructions =
      "Paste the above URL into the Safari web browser.";
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
            /*TFC_Text.body("Browser: " +
                TFC_BrowserRedirectApp.browserAndOSTestResults.browser
                    .toString()),
            TFC_Text.body("OS: " +
                TFC_BrowserRedirectApp.browserAndOSTestResults.os.toString()),
            TFC_Text.body("isCorrectBrowserForOS: " +
                TFC_BrowserRedirectApp
                    .browserAndOSTestResults.isCorrectBrowserForOS
                    .toString()),
            TFC_Text.body("User Agent: " + html.window.navigator.userAgent),*/
            TFC_Text.body(
              TFC_BrowserRedirectApp.unkownOSInstructions,
              textAlign: TextAlign.center,
            ),
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
        body: Center(
          child: Container(
            alignment: Alignment.center,
            width: TFC_AppStyle.instance.internalPageWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /*TFC_Text.body("Browser: " +
                    TFC_BrowserRedirectApp.browserAndOSTestResults.browser
                        .toString()),
                TFC_Text.body("OS: " +
                    TFC_BrowserRedirectApp.browserAndOSTestResults.os
                        .toString()),
                TFC_Text.body("isCorrectBrowserForOS: " +
                    TFC_BrowserRedirectApp
                        .browserAndOSTestResults.isCorrectBrowserForOS
                        .toString()),
                TFC_Text.body("User Agent: " + html.window.navigator.userAgent),*/
                TFC_Text.heading(
                    "You'll need to use a different browser to install this app."),
                Container(
                  height: 2.0 * TFC_AppStyle.instance.lineHeight,
                ),
                TFC_Text.subheading("Step 1"),
                TFC_Text.body(
                  "Copy this website's URL:",
                  textAlign: TextAlign.center,
                ),
                //TFC_Text.body(TFC_WebExclusiveAPI.getCurrentURL()),
                TFC_Button.flat(
                    onPressed: () {
                      TFC_WebExclusiveAPI.copyTextToClipBoard(
                          TFC_WebExclusiveAPI.getCurrentURL());
                    },
                    child: TFC_Text.body(
                      "Copy URL",
                      color: TFC_AppStyle.COLOR_BACKGROUND,
                    )),
                Container(
                  height: TFC_AppStyle.instance.lineHeight,
                ),
                TFC_Text.subheading("Step 2"),
                TFC_Text.body(
                  step2Instructions,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
