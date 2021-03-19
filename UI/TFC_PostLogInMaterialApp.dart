import 'TFC_LoadingPage.dart';
import 'package:flutter/material.dart';
import 'TFC_AppStyle.dart';
import '../APIs/TFC_WebExclusiveAPI.dart';

class TFC_PostLogInMaterialApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Set the ios status bar color
    TFC_WebExclusiveAPI.setWebBackgroundColor("#ffffff");

    return MaterialApp(
      theme: TFC_AppStyle.themeData,
      home: _TFC_PostLogInScaffold(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _TFC_PostLogInScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
  /*@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TFC_LoadingPage.icon(
        Icons.cloud_download,
        "Syncing...",
        color: TFC_AppStyle.colorPrimary,
      ),
    );
  }*/
}
