import 'dart:convert';
import 'dart:io';
import '../UI/TFC_LogInMaterialApp.dart';
import '../UI/TFC_PostLogInMaterialApp.dart';
import 'package:flutter/foundation.dart';
import '../APIs/TFC_PlatformAPI.dart';
import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';
import '../Serialization/TFC_AutoSaving.dart';
import '../Utilities/TFC_Utilities.dart';
import 'TFC_SyncController.dart';
import '../UI/TFC_AppStyle.dart';
import '../UI/TFC_Page.dart';
import 'TFC_DiskController.dart';
import '../Utilities/TFC_Event.dart';
import 'TFC_FlutterApp.dart';
import '../UI/TFC_StartupMaterialApp.dart';

class TFC_StartupController {
  static final TFC_Event onTFCStartupComplete = TFC_Event();

  static void runStartup({
    @required String appName,
    @required Color colorPrimary,
    @required String appLoadingLogoAssetPath,
    @required String appBarLogoAssetPath,
    @required Set<String> itemTypesInThisApp,
    @required TFC_Page Function() homePageBuilder,
    @required TFC_Page Function() settingsPageBuilder,
    bool shouldStartSync = true,
  }) async {
    // Render splash screen & setup UI base properties
    TFC_FlutterApp.appName = appName;
    TFC_AppStyle.colorPrimary = colorPrimary;
    TFC_AppStyle.appLoadingLogoAssetPath = appLoadingLogoAssetPath;
    TFC_AppStyle.appBarLogoAssetPath = appBarLogoAssetPath;
    runApp(TFC_StartupMaterialApp());

    // We delay to let the app logo load
    await Future.delayed(Duration(milliseconds: 250));

    // Setup the platform API
    await TFC_PlatformAPI.setupPlatformAPI();

    // Setup the disk controller
    await TFC_DiskController.setupTFCDiskController();

    // Setup device properties
    if (TFC_FlutterApp.deviceID.value == null ||
        TFC_FlutterApp.deviceID.value == "") {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (kIsWeb) {
        TFC_FlutterApp.deviceID.value = "BBBBB";
      } else if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        TFC_FlutterApp.deviceID.value = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        TFC_FlutterApp.deviceID.value = iosInfo.identifierForVendor;
      }
    }
    final Map<String, dynamic> clientSettings =
        jsonDecode(await rootBundle.loadString("assets/data.json"));

    /*TFC_AutoSavingProperty<String> isLoggedIn =
        TFC_AutoSavingProperty("false", "isLoggedIn");

    if (isLoggedIn.value == "false") {
      runApp(TFC_LogInMaterialApp());
      await TFC_Utilities.when(() {
        return TFC_LogInMaterialApp.passwordIsCorrect;
      });
      isLoggedIn.value = "true";
      runApp(TFC_PostLogInMaterialApp());
      // We delay to let the loading icon appear
      await Future.delayed(Duration(milliseconds: 250));
    }*/

    // Set up the database sync controller
    await TFC_SyncController.setupDatabaseSyncController(
        clientSettings["clientID"], itemTypesInThisApp,
        shouldStartSync: shouldStartSync);

    // Actually start the app
    TFC_FlutterApp.homePage = homePageBuilder();
    TFC_FlutterApp.settingsPage = settingsPageBuilder();
    runApp(TFC_FlutterApp());

    onTFCStartupComplete.trigger();
  }
}
