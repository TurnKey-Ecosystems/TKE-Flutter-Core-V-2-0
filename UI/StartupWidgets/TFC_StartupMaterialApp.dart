import 'package:flutter/material.dart';
import '../FoundationalElements/TFC_AppStyle.dart';
import 'TFC_SplashScreen.dart';
import '../../APIs/TFC_PlatformAPI.dart';

class TFC_StartupMaterialApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Set the ios status bar color
    // We can't set this, because the startup material app must run before the platform api setup
    //TFC_PlatformAPI.platformAPI.setWebBackgroundColor("#ffffff");

    return MaterialApp(
      theme: TFC_AppStyle.themeData,
      home: _TFC_StartupScaffold(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _TFC_StartupScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TFC_AppStyle.setupInstance(context);

    return Scaffold(
      body: TFC_SplashScreen(),
    );
  }
}
