import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Serialization/TFC_AutoSaving.dart';
import '../UI/TFC_AppStyle.dart';
import '../UI/TFC_Page.dart';
import '../UI/TFC_ReloadableWidget.dart';
import '../Utilities/TFC_Utilities.dart';
import '../APIs/TFC_WebExclusiveAPI.dart';
import '../Utilities/TFC_ColorExtension.dart';

class TFC_FlutterApp extends TFC_ReloadableWidget {
  static String appName;
  static TFC_Page homePage;
  static TFC_Page settingsPage;
  static TFC_AutoSavingProperty<String> deviceID =
      TFC_AutoSavingProperty("", "deviceID");

  @override
  void onInit() {
    // Set the ios status bar color
    TFC_WebExclusiveAPI.setWebBackgroundColor(
        TFC_AppStyle.colorPrimary.toHex());

    // Lock orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
