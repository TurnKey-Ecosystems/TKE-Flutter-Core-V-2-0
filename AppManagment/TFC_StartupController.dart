import 'dart:convert';
import 'dart:math';
//import 'dart:io';
import 'package:tke_dev_time_tracker_flutter_tryw/TKE-Flutter-Core/UI/StartupWidgets/TFC_SplashScreen.dart';

import '../APIs/TFC_ICloudSyncInterface.dart';
import '../DataStructures/TFC_AllItemsManager.dart';
import '../UI/StartupWidgets/TFC_InstallationApp.dart';
import '../UI/StartupWidgets/TFC_BrowserRedirectApp.dart';
import '../APIs/TFC_PlatformAPI.dart';
import '../Utilities/TFC_ColorExtension.dart';
import '../UI/StartupWidgets/TFC_LogInMaterialApp.dart';
import '../UI/StartupWidgets/TFC_PostLogInMaterialApp.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';
import '../Serialization/TFC_AutoSaving.dart';
import '../Utilities/TFC_Utilities.dart';
//import 'TFC_SyncController.dart';
import '../UI/FoundationalElements/TFC_AppStyle.dart';
import 'TFC_DiskController.dart';
import '../Utilities/TFC_Event.dart';
import 'TFC_FlutterApp.dart';
import '../UI/StartupWidgets/TFC_StartupMaterialApp.dart';
import 'TFC_SyncController.dart';

class TFC_StartupController {
  static final TFC_Event onTFCStartupComplete = TFC_Event();

  static void runStartup({
    required String appConfigPath,
    required String? caseInsensitivePasscode,
    void Function()? onAfterStartUpComplete,
    required Widget Function() homePageBuilder,
    required Widget Function() settingsPageBuilder,
    /** Override this class with your own syncing interface. */
    required TFC_ICloudSyncInterface? cloudSyncInterface,
    bool shouldStartSync = true,
  }) async {
    // We have to have a flutter app running before we can access assets where our app config file resides
    TFC_FlutterApp.appName = "";
    TFC_AppStyle.colorPrimary = Color(0xffffffff);
    TFC_AppStyle.appLoadingLogoAssetPath = null;
    TFC_AppStyle.appBarLogoAssetPath = null;
    runApp(TFC_StartupMaterialApp());

    // Setup the platform API
    await TFC_PlatformAPI.setupPlatformAPI();

    // Render splash screen & setup UI base properties
    final Map<String, dynamic> appConfig =
        jsonDecode(await rootBundle.loadString(appConfigPath));
    TFC_FlutterApp.appName = appConfig["appName"];
    TFC_AppStyle.colorPrimary = HexColor.fromHex(appConfig["primaryColor"]);
    TFC_AppStyle.appLoadingLogoAssetPath = appConfig["appLoadingLogoAssetPath"];
    TFC_AppStyle.appBarLogoAssetPath = appConfig["appBarLogoAssetPath"];
    runApp(TFC_StartupMaterialApp());

    // We delay to let the app logo load
    await Future.delayed(Duration(milliseconds: 250));

    // Setup the disk controller
    await TFC_DiskController.setupTFCDiskController();

    // Setup the items manager
    TFC_AllItemsManager.setupAllItemsManager();

    // Setup device properties
    if (TFC_FlutterApp.deviceID.value == null ||
        TFC_FlutterApp.deviceID.value == "") {
      const String VALID_CHARS = 'bcdfghjklmnpqrstvwxyz0123456789';
      const int ID_LENGTH = 10;
      int Function(int) getRandomInt = Random().nextInt;
      String deviceID = "";

      for (int i = 0; i < ID_LENGTH; i++) {
        deviceID += VALID_CHARS[getRandomInt(VALID_CHARS.length)];
      }
      TFC_FlutterApp.deviceID.value = deviceID;
      /*DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (kIsWeb) {
        TFC_FlutterApp.deviceID.value = "web";
      } else if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        TFC_FlutterApp.deviceID.value = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        TFC_FlutterApp.deviceID.value = iosInfo.identifierForVendor;
      }*/
    }

    // Show the browser redirect page
    if (kIsWeb && kReleaseMode) {
      TFC_BrowserAndOSTestResults results =
          TFC_PlatformAPI.platformAPI.testBrowserAndOS();

      if (!results.isCorrectBrowserForOS) {
        runApp(TFC_BrowserRedirectApp(results));
        await TFC_Utilities.when(() {
          return TFC_BrowserRedirectApp.shouldContinuePastThisPage;
        });
      }
    }

    // Show the installation page
    if (kIsWeb &&
        kReleaseMode &&
        !TFC_PlatformAPI.platformAPI.getIsInstalled()) {
      TFC_BrowserAndOSTestResults results =
          TFC_PlatformAPI.platformAPI.testBrowserAndOS();
      runApp(TFC_InstallationApp(results.browser));
      await TFC_Utilities.when(() {
        return TFC_InstallationApp.shouldContinuePastThisPage;
      });
    }

    // Show the passcode page
    if (kIsWeb && kReleaseMode && caseInsensitivePasscode != null) {
      TFC_AutoSavingProperty<String> lastPasscodeAttempt = TFC_AutoSavingProperty(
        initialValue: "",
        fileNameWithoutExtension: "lastPasscodeAttempt",
      );
      bool lastPasscodeAttemptIsCorrect =
          lastPasscodeAttempt.value.toLowerCase() ==
              caseInsensitivePasscode.toLowerCase();
      /*bool urlSearchPasscodeIsCorrect =
          TFC_WebExclusiveAPI.getPasscodeFromURL().toLowerCase() ==
              caseInsensitivePasscode.toLowerCase();*/

      if (!lastPasscodeAttemptIsCorrect /* && !urlSearchPasscodeIsCorrect*/) {
        runApp(TFC_LogInMaterialApp(caseInsensitivePasscode));
        await TFC_Utilities.when(() {
          return TFC_LogInMaterialApp.passcodeIsCorrect;
        });
        lastPasscodeAttempt.value = caseInsensitivePasscode;
        runApp(TFC_PostLogInMaterialApp());
        // We delay to let the loading icon appear
        await Future.delayed(Duration(milliseconds: 250));
      }
    }

    // Setup the sync controller and start the sync loop
    if (cloudSyncInterface != null) {
      //Future.delayed(Duration());
      TFC_SplashScreen.splashScreenType.value = TFC_SplashScreenType.DOWNLOADING;
      TFC_PlatformAPI.platformAPI.setWebBackgroundColor("#ffffff");
      TFC_PlatformAPI.platformAPI.hideHTMLSplashScreen();
      await TFC_SyncController.startTheSyncLoops(syncInterface: cloudSyncInterface);
      TFC_SplashScreen.splashScreenType.value = TFC_SplashScreenType.LOGO;
      debugPrint("Sync loop has been started.");
    }
    
    // Actually start the app
    TFC_FlutterApp.homePage = homePageBuilder();
    TFC_FlutterApp.settingsPage = settingsPageBuilder();
    runApp(TFC_FlutterApp(
      onAfterStartUpComplete: onAfterStartUpComplete,
    ));

    onTFCStartupComplete.trigger();
  }
}
