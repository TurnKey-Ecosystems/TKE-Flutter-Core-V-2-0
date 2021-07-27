import '../../AppManagment/TFC_SyncController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../AppManagment/TFC_FlutterApp.dart';
import '../PrebuiltWidgets/TFC_CustomWidgets.dart';
import '../PrebuiltWidgets/TFC_LoadingPage.dart';
import '../FoundationalElements/TFC_ReloadableWidget.dart';
import '../FoundationalElements/TFC_AppStyle.dart';
//import '../AppManagment/TFC_DiskController.dart';

class _Init_Properties {
  static bool isInInit = false;
  static bool initHasTimedOut = false;
}

class TFC_SplashScreen extends TFC_ReloadableWidget {
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
      if (!TFC_SyncController.downloadAllIsInProgress) {
        // Regular startup time out
        _Init_Properties.initHasTimedOut = true;
        reload();
      } else {
        // Download all time out
        reload();

        await Future.delayed(Duration(seconds: 19));

        if (_Init_Properties.isInInit == true &&
            !_Init_Properties.initHasTimedOut) {
          _Init_Properties.initHasTimedOut = true;
          reload();
        }
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
    if (TFC_SyncController.downloadAllIsInProgress) {
      return TFC_LoadingPage.icon(
        Icons.cloud_download,
        "Download in Progress",
        color: TFC_AppStyle.colorPrimary,
      );
    } else if (TFC_AppStyle.appLoadingLogoAssetPath != null) {
      return TFC_LoadingPage.image(
        TFC_AppStyle.appLoadingLogoAssetPath,
        //"Loading " + TFC_FlutterApp.appName + "...",
        TFC_FlutterApp.appName,
        color: TFC_AppStyle.colorPrimary,
      );
    } else {
      return Container();
    }
  }

  Widget getErrorButton() {
    if (_Init_Properties.initHasTimedOut) {
      return FlatButton(
        onPressed: () {},
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
                " Check your internet!",
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
