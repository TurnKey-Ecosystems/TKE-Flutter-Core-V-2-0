import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Serialization/TFC_AutoSaving.dart';
import '../UI/TFC_AppStyle.dart';
import '../UI/TFC_Page.dart';
import '../UI/TFC_ReloadableWidget.dart';
import '../Utilities/TFC_Utilities.dart';
import '../APIs/TFC_PlatformAPI.dart';
import '../Utilities/TFC_ColorExtension.dart';

class TFC_FlutterApp extends TFC_ReloadableWidget {
  static String appName;
  static TFC_Page homePage;
  static TFC_Page settingsPage;
  static TFC_AutoSavingProperty<String> deviceID =
      TFC_AutoSavingProperty("", "deviceID");
  static void Function() _onAfterStartUpComplete;

  TFC_FlutterApp({void Function() onAfterStartUpComplete}) : super() {
    _onAfterStartUpComplete = onAfterStartUpComplete;
  }

  @override
  void onInit() {
    // Set the ios status bar color
    TFC_PlatformAPI.platformAPI
        .setWebBackgroundColor(TFC_AppStyle.colorPrimary.toHex());
    TFC_PlatformAPI.platformAPI.hideHTMLSplashScreen();

    // Lock orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Tell the app that startup is complete
    if (_onAfterStartUpComplete != null) {
      _onAfterStartUpComplete();
    }
  }

  @override
  Widget buildWidget(BuildContext context) {
    return GestureDetector(
      onTap: () {
        TFC_Utilities.closeTheKeyboard(context);
      },
      child: MaterialApp(
        title: appName,
        theme: TFC_AppStyle.themeData,
        home: homePage,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
