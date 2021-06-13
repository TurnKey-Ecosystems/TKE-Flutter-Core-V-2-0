import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../AppManagment/TFC_FlutterApp.dart';
import '../UI/TFC_Button.dart';
import 'TFC_CustomWidgets.dart';
import 'TFC_ReloadableWidget.dart';
import 'TFC_AppStyle.dart';
import '../APIs/TFC_PlatformAPI.dart';

class TFC_InstallationApp extends StatelessWidget {
  static late TFC_Browser browser;
  static late bool shouldContinuePastThisPage = false;

  TFC_InstallationApp(TFC_Browser browser) {
    TFC_InstallationApp.browser = browser;
  }

  @override
  Widget build(BuildContext context) {
    // Set the ios status bar color
    TFC_PlatformAPI.platformAPI.setWebBackgroundColor("#ffffff");
    TFC_PlatformAPI.platformAPI.hideHTMLSplashScreen();

    // Lock orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      theme: TFC_AppStyle.themeData,
      home: _TFC_InstallationScaffold(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _TFC_InstallationScaffold extends TFC_ReloadableWidget {
  TFC_Browser get browser {
    return TFC_InstallationApp.browser;
  }

  @override
  Widget buildWidget(BuildContext context) {
    if (browser == TFC_Browser.CHROME || browser == TFC_Browser.UNKNOWN) {
      return Scaffold(
        body: ListView(
          children: [
            Container(
              padding: EdgeInsets.all(TFC_AppStyle.instance.pageMargins),
              alignment: Alignment.center,
              width: TFC_AppStyle.instance.internalPageWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TFC_Text.subheading(TFC_FlutterApp.appName),
                  Container(
                    height: 1.0 * TFC_AppStyle.instance.lineHeight,
                  ),
                  Container(
                    width: 4.0 * TFC_AppStyle.instance.lineHeight,
                    height: 4.0 * TFC_AppStyle.instance.lineHeight,
                    margin: EdgeInsets.all(0.0),
                    decoration: BoxDecoration(
                      color: TFC_AppStyle.COLOR_BACKGROUND,
                      boxShadow: [
                        BoxShadow(
                          color: TFC_AppStyle.COLOR_HINT.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 0), // changes position of shadow
                        ),
                      ],
                      image: DecorationImage(
                        image: AssetImage("assets/app-icon-small.jpg"),
                        fit: BoxFit.fill,
                      ),
                      border: Border.all(
                          width: 0.0 * TFC_AppStyle.instance.pageMargins,
                          color: Colors.transparent),
                      borderRadius: BorderRadius.all(Radius.circular(
                          0.95 * TFC_AppStyle.instance.pageMargins)),
                    ),
                  ),
                  Container(
                    height: 2.0 * TFC_AppStyle.instance.lineHeight,
                  ),
                  TFC_Text.subheading("Step 1"),
                  TFC_Text.body(
                    "Install the app.",
                    textAlign: TextAlign.center,
                  ),
                  TFC_Button.flat(
                      onPressed: TFC_PlatformAPI.platformAPI.showInstallPrompt,
                      child: TFC_Text.body(
                        "Install",
                        color: TFC_AppStyle.COLOR_BACKGROUND,
                      )),
                  Container(
                    height: TFC_AppStyle.instance.lineHeight,
                  ),
                  TFC_Text.subheading("Step 2"),
                  TFC_Text.body(
                    "Wait for the app to install. (This may take up to 60 seconds. After that, if the app is not on your home screen, then check your app drawer.)",
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    height: TFC_AppStyle.instance.lineHeight,
                  ),
                  TFC_Text.subheading("Step 3"),
                  TFC_Text.body(
                    "Open the app and enter the passcode.",
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    height: 4.0 * TFC_AppStyle.instance.lineHeight,
                  ),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TFC_AppStyle.instance.textStyleBody
                          .apply(color: TFC_AppStyle.COLOR_HINT),
                      children: [
                        TextSpan(
                            text:
                                "Note: If the app is already installed then you can simply "),
                        WidgetSpan(
                          child: GestureDetector(
                            child: TFC_Text.body(
                              "continue",
                              isUnderlined: true,
                              color: TFC_AppStyle.COLOR_HINT,
                            ),
                            onTap: () {
                              TFC_InstallationApp.shouldContinuePastThisPage =
                                  true;
                            },
                          ),
                        ),
                        TextSpan(text: "."),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        body: ListView(
          children: [
            Container(
              padding: EdgeInsets.all(TFC_AppStyle.instance.pageMargins),
              alignment: Alignment.center,
              width: TFC_AppStyle.instance.internalPageWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TFC_Text.subheading(TFC_FlutterApp.appName),
                  Container(
                    height: 1.0 * TFC_AppStyle.instance.lineHeight,
                  ),
                  Container(
                    width: 4.0 * TFC_AppStyle.instance.lineHeight,
                    height: 4.0 * TFC_AppStyle.instance.lineHeight,
                    margin: EdgeInsets.all(0.0),
                    decoration: BoxDecoration(
                      color: TFC_AppStyle.COLOR_BACKGROUND,
                      boxShadow: [
                        BoxShadow(
                          color: TFC_AppStyle.COLOR_HINT.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 0), // changes position of shadow
                        ),
                      ],
                      image: DecorationImage(
                        image: AssetImage("assets/app-icon-small.jpg"),
                        fit: BoxFit.fill,
                      ),
                      border: Border.all(
                          width: 0.0 * TFC_AppStyle.instance.pageMargins,
                          color: Colors.transparent),
                      borderRadius: BorderRadius.all(Radius.circular(
                          0.95 * TFC_AppStyle.instance.pageMargins)),
                    ),
                  ),
                  Container(
                    height: 2.0 * TFC_AppStyle.instance.lineHeight,
                  ),
                  TFC_Text.subheading("Step 1"),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TFC_AppStyle.instance.textStyleBody,
                      children: [
                        TextSpan(text: 'Tap the '),
                        WidgetSpan(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    0.125 * TFC_AppStyle.instance.lineHeight),
                            child: Icon(Icons.ios_share),
                          ),
                        ),
                        TextSpan(text: ' button at the bottom of the page.'),
                      ],
                    ),
                  ),
                  Container(
                    height: 0.5 * TFC_AppStyle.instance.pageMargins,
                  ),
                  Container(
                    width: 0.98 * TFC_AppStyle.instance.internalPageWidth,
                    height:
                        0.2416 * 0.98 * TFC_AppStyle.instance.internalPageWidth,
                    margin: EdgeInsets.all(0.0),
                    decoration: BoxDecoration(
                      color: TFC_AppStyle.COLOR_BACKGROUND,
                      boxShadow: [
                        BoxShadow(
                          color: TFC_AppStyle.COLOR_HINT.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 0), // changes position of shadow
                        ),
                      ],
                      image: DecorationImage(
                        image: AssetImage("assets/tap-share.jpg"),
                        fit: BoxFit.fill,
                      ),
                      border: Border.all(
                          width: 0.0 * TFC_AppStyle.instance.pageMargins,
                          color: Colors.transparent),
                      borderRadius: BorderRadius.all(Radius.circular(
                          1.0 * TFC_AppStyle.instance.pageMargins)),
                    ),
                  ),
                  Container(
                    height: 1.5 * TFC_AppStyle.instance.lineHeight,
                  ),
                  TFC_Text.subheading("Step 2"),
                  TFC_Text.body(
                    "Scroll down and tap \"Add to Home Screen\".",
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    height: 0.5 * TFC_AppStyle.instance.pageMargins,
                  ),
                  Container(
                    width: 0.98 * TFC_AppStyle.instance.internalPageWidth,
                    height:
                        0.2416 * 0.98 * TFC_AppStyle.instance.internalPageWidth,
                    margin: EdgeInsets.all(0.0),
                    decoration: BoxDecoration(
                      color: TFC_AppStyle.COLOR_BACKGROUND,
                      boxShadow: [
                        BoxShadow(
                          color: TFC_AppStyle.COLOR_HINT.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 0), // changes position of shadow
                        ),
                      ],
                      image: DecorationImage(
                        image: AssetImage("assets/tap-add-to-home-screen.jpg"),
                        fit: BoxFit.fill,
                      ),
                      border: Border.all(
                          width: 0.0 * TFC_AppStyle.instance.pageMargins,
                          color: Colors.transparent),
                      borderRadius: BorderRadius.all(Radius.circular(
                          1.0 * TFC_AppStyle.instance.pageMargins)),
                    ),
                  ),
                  Container(
                    height: 1.5 * TFC_AppStyle.instance.lineHeight,
                  ),
                  TFC_Text.subheading("Step 3"),
                  TFC_Text.body(
                    "Wait for a few seconds to let the app icon load, and then tap \"Add\".",
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    height: 0.5 * TFC_AppStyle.instance.pageMargins,
                  ),
                  Container(
                    width: 0.98 * TFC_AppStyle.instance.internalPageWidth,
                    height:
                        0.2416 * 0.98 * TFC_AppStyle.instance.internalPageWidth,
                    margin: EdgeInsets.all(0.0),
                    decoration: BoxDecoration(
                      color: TFC_AppStyle.COLOR_BACKGROUND,
                      boxShadow: [
                        BoxShadow(
                          color: TFC_AppStyle.COLOR_HINT.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 0), // changes position of shadow
                        ),
                      ],
                      image: DecorationImage(
                        image: AssetImage("assets/tap-add-app.jpg"),
                        fit: BoxFit.fill,
                      ),
                      border: Border.all(
                          width: 0.0 * TFC_AppStyle.instance.pageMargins,
                          color: Colors.transparent),
                      borderRadius: BorderRadius.all(Radius.circular(
                          1.0 * TFC_AppStyle.instance.pageMargins)),
                    ),
                  ),
                  Container(
                    height: 1.5 * TFC_AppStyle.instance.lineHeight,
                  ),
                  TFC_Text.subheading("Step 4"),
                  TFC_Text.body(
                    "Open the app and enter the passcode.",
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    height: 0.5 * TFC_AppStyle.instance.pageMargins,
                  ),
                  Container(
                    width: 0.98 * TFC_AppStyle.instance.internalPageWidth,
                    height:
                        0.2416 * 0.98 * TFC_AppStyle.instance.internalPageWidth,
                    margin: EdgeInsets.all(0.0),
                    decoration: BoxDecoration(
                      color: TFC_AppStyle.COLOR_BACKGROUND,
                      boxShadow: [
                        BoxShadow(
                          color: TFC_AppStyle.COLOR_HINT.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 0), // changes position of shadow
                        ),
                      ],
                      image: DecorationImage(
                        image: AssetImage("assets/enter-passcode.jpg"),
                        fit: BoxFit.fill,
                      ),
                      border: Border.all(
                          width: 0.0 * TFC_AppStyle.instance.pageMargins,
                          color: Colors.transparent),
                      borderRadius: BorderRadius.all(Radius.circular(
                          1.0 * TFC_AppStyle.instance.pageMargins)),
                    ),
                  ),
                  Container(
                    height: 4.0 * TFC_AppStyle.instance.lineHeight,
                  ),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TFC_AppStyle.instance.textStyleBody
                          .apply(color: TFC_AppStyle.COLOR_HINT),
                      children: [
                        TextSpan(
                            text:
                                "Note: If the app is already installed then you can simply "),
                        WidgetSpan(
                          child: GestureDetector(
                            child: TFC_Text.body(
                              "continue",
                              isUnderlined: true,
                              color: TFC_AppStyle.COLOR_HINT,
                            ),
                            onTap: () {
                              TFC_InstallationApp.shouldContinuePastThisPage =
                                  true;
                            },
                          ),
                        ),
                        TextSpan(text: "."),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
