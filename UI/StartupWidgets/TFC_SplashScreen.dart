import '../../Utilities/TFC_BasicValueWrapper.dart';
import '../../UI/PrebuiltWidgets/TFC_Button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../AppManagment/TFC_FlutterApp.dart';
import '../PrebuiltWidgets/TFC_CustomWidgets.dart';
import '../PrebuiltWidgets/TFC_LoadingPage.dart';
import '../FoundationalElements/TFC_SelfReloadingWidget.dart';
import '../FoundationalElements/TFC_AppStyle.dart';
//import '../AppManagment/TFC_DiskController.dart';

class _Init_Properties {
  static bool isInInit = false;
  static bool initHasTimedOut = false;
}

enum TFC_SplashScreenType { LOGO, DOWNLOADING }

class TFC_SplashScreen extends TFC_SelfReloadingWidget {
  /** What type of splash screen to show */
  static TFC_BasicValueWrapper<TFC_SplashScreenType> splashScreenType =
    TFC_BasicValueWrapper(TFC_SplashScreenType.LOGO);

  TFC_SplashScreen()
    : super(reloadTriggers: [splashScreenType.onAfterChange]);
  @override
  void onInit() {
    _Init_Properties.isInInit = true;
    checkForTimeOut();
  }

  @override
  void onDispose() {
    _Init_Properties.isInInit = false;
  }

  void checkForTimeOut() async {
    await Future.delayed(Duration(seconds: 1));

    if (_Init_Properties.isInInit == true &&
        !_Init_Properties.initHasTimedOut) {
      if (splashScreenType.value == TFC_SplashScreenType.DOWNLOADING) {
        // Download all time out
        reload();

        await Future.delayed(Duration(seconds: 19));

        if (_Init_Properties.isInInit == true &&
            !_Init_Properties.initHasTimedOut) {
          _Init_Properties.initHasTimedOut = true;
          reload();
        }
      } else {
        // Regular startup time out
        _Init_Properties.initHasTimedOut = true;
        reload();
      }
    }
  }

  @override
  Widget buildWidget(BuildContext context) {
    // Lock orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    Widget scaffold = Scaffold(
      body: getSplashScreen(),
      floatingActionButton: getErrorButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );

    return scaffold;
  }

  Widget getSplashScreen() {
    debugPrint("Reloading!");
    debugPrint("splashScreenType.value: ${splashScreenType.value}");
    if (splashScreenType.value == TFC_SplashScreenType.DOWNLOADING) {
      debugPrint("Building the downloading page.");
      return TFC_LoadingPage.icon(
        Icons.cloud_download,
        "Downloading Files",
        color: TFC_AppStyle.colorPrimary,
      );
    } else if (TFC_AppStyle.appLoadingLogoAssetPath != null) {
      debugPrint("Building the logo page.");
      return TFC_LoadingPage.image(
        TFC_AppStyle.appLoadingLogoAssetPath,
        //"Loading " + TFC_FlutterApp.appName + "...",
        TFC_FlutterApp.appName,
        color: TFC_AppStyle.colorPrimary,
      );
    } else {
      debugPrint("Building the blank page.");
      return Container();
    }
  }

  Widget getErrorButton() {
    if (_Init_Properties.initHasTimedOut) {
      return TFC_Button.solid(
        onTap: () {},
        color: TFC_AppStyle.COLOR_ERROR,
        child: Container(
          width: 12 * TFC_AppStyle.instance.lineHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.error,
                color: TFC_AppStyle.COLOR_BACKGROUND,
              ),
              TFC_Text.body(
                () => " Check your internet!",
                color: TFC_AppStyle.COLOR_BACKGROUND,
              ),
            ],
          ),
        ),
      );
    } /* else if (_Init_Properties.initHasTimedOut) {
      return FlatButton(
        onPressed: TFC_DiskController.emergencyExportAllSavedFiles,
        color: TFC_AppStyle.COLOR_ERROR,
        child: Container(
          width: 15 * TFC_AppStyle.instance.lineHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.error,
                color: TFC_AppStyle.COLOR_BACKGROUND,
              ),
              TFC_Text.body(
                " Possible error! Press this.",
                color: TFC_AppStyle.COLOR_BACKGROUND,
              ),
            ],
          ),
        ),
      );
    } */
    else {
      return Container(
        width: 0,
        height: 0,
      );
    }
  }
}
