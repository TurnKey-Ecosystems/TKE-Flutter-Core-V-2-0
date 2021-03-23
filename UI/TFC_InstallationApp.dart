import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../AppManagment/TFC_FlutterApp.dart';
import '../UI/TFC_Button.dart';
import 'TFC_CustomWidgets.dart';
import 'TFC_ReloadableWidget.dart';
import 'TFC_AppStyle.dart';
import '../APIs/TFC_WebExclusiveAPI.dart';

class TFC_InstallationApp extends StatelessWidget {
  static TFC_Browser browser;

  TFC_InstallationApp(TFC_Browser browser) {
    TFC_InstallationApp.browser = browser;
  }

  @override
  Widget build(BuildContext context) {
    // Set the ios status bar color
    TFC_WebExclusiveAPI.setWebBackgroundColor("#ffffff");

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
        body: Center(
          child: Container(
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
                  height: 1.0 * TFC_AppStyle.instance.lineHeight,
                ),
                TFC_Button.flat(
                    onPressed: TFC_WebExclusiveAPI.showInstallPrompt,
                    child: TFC_Text.body(
                      "Install",
                      color: TFC_AppStyle.COLOR_BACKGROUND,
                    )),
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        body: Center(
          child: Container(
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
                  "Press the share button at the bottom of the page.",
                  textAlign: TextAlign.center,
                ),
                Container(
                  height: TFC_AppStyle.instance.lineHeight,
                ),
                TFC_Text.subheading("Step 2"),
                TFC_Text.body(
                  "Scroll down and tap the \"Add to Home Screen\" button.",
                  textAlign: TextAlign.center,
                ),
                Container(
                  height: TFC_AppStyle.instance.lineHeight,
                ),
                TFC_Text.subheading("Step 3"),
                TFC_Text.body(
                  "Wait for a few seconds to let the icon load, and then tap \"Add\".",
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
