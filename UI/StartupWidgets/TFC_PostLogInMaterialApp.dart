//import 'TFC_LoadingPage.dart';
import 'package:flutter/material.dart';
import 'package:tke_dev_time_tracker_flutter_tryw/TKE-Flutter-Core/UI/StartupWidgets/TFC_SplashScreen.dart';
import '../FoundationalElements/TFC_AppStyle.dart';
import '../../APIs/TFC_PlatformAPI.dart';

class TFC_PostLogInMaterialApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Set the ios status bar color
    TFC_PlatformAPI.platformAPI.setWebBackgroundColor("#ffffff");

    return MaterialApp(
      theme: TFC_AppStyle.themeData,
      home: TFC_SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
