import '../AppManagment/TFC_FlutterApp.dart';
import 'TFC_AppStyle.dart';
import 'TFC_CustomWidgets.dart';
import 'package:flutter/material.dart';

class TFC_AppBarBuilder {
  static PreferredSizeWidget buildDefaultAppBar(BuildContext context) {
    return _buildAppBar(context, true);
  }

  static PreferredSizeWidget buildSettingsAppBar(BuildContext context) {
    return _buildAppBar(context, false);
  }

  static PreferredSizeWidget _buildAppBar(
      BuildContext context, bool shouldShowSettingsButton) {
    Widget title;
    Widget flexibleSpace;

    if (TFC_AppStyle.appBarLogoAssetPath == null) {
      title = TFC_Text.heading(
        TFC_FlutterApp.appName,
        color: TFC_AppStyle.COLOR_BACKGROUND,
      );
      flexibleSpace = PreferredSize(
        preferredSize: Size.fromHeight(2.0 * TFC_AppStyle.instance.lineHeight),
        child: Container(
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              Container(
                height: 2.0 * TFC_AppStyle.instance.lineHeight,
              ),
              Stack(
                children: [
                  _getSettingsButton(context, shouldShowSettingsButton),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      title = Container(
        height: 0,
      );
      flexibleSpace = PreferredSize(
        preferredSize:
            Size.fromHeight(TFC_AppStyle.instance.m2UnitsToFlutterUnits(6)),
        child: Container(
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              Container(
                height: TFC_AppStyle.instance.m2UnitsToFlutterUnits(1.85),
              ),
              Stack(
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: TFC_AppStyle.instance.m2UnitsToFlutterUnits(4),
                    child: Image.asset(TFC_AppStyle.appBarLogoAssetPath!),
                  ),
                  _getSettingsButton(context, shouldShowSettingsButton),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return PreferredSize(
      preferredSize:
          Size.fromHeight(TFC_AppStyle.instance.m2UnitsToFlutterUnits(7)),
      child: AppBar(
        backgroundColor: TFC_AppStyle.colorPrimary,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: TFC_AppStyle.COLOR_BACKGROUND,
        ),
        flexibleSpace: flexibleSpace,
        title: title,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(
              TFC_AppStyle.instance.m2UnitsToFlutterUnits(1.25)),
          child: Container(
            height: 0,
          ),
        ),
      ),
    );
  }

  static Widget _getSettingsButton(
      BuildContext context, bool shouldShowSettingsButton) {
    if (shouldShowSettingsButton) {
      return Container(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          child: Container(
            color: TFC_AppStyle.colorPrimary,
            alignment: Alignment.centerRight,
            width: 0.175 * TFC_AppStyle.instance.internalPageWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  height: 0.5 * TFC_AppStyle.instance.lineHeight,
                ),
                Container(
                  height: 3 * TFC_AppStyle.instance.lineHeight,
                  width: 0.15 * TFC_AppStyle.instance.internalPageWidth,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.settings,
                    color: TFC_AppStyle.COLOR_BACKGROUND,
                  ),
                ),
                Container(
                  height: 0.5 * TFC_AppStyle.instance.lineHeight,
                ),
              ],
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TFC_FlutterApp.settingsPage,
              ),
            );
          },
        ),
      );
    } else {
      return Container();
    }
  }
}
