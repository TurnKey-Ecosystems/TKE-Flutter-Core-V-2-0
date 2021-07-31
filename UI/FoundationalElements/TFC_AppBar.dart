import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../ConfigurationTypes/AxisSize.dart';
import '../../UI/ConfigurationTypes/TFC_BackgroundDecoration.dart';
import '../../UI/ConfigurationTypes/TFC_BoxDecoration.dart';
import '../ConfigurationTypes/ChildToBoxSpacing.dart';
import '../ConfigurationTypes/ChildToChildSpacing.dart';
import '../../UI/ConfigurationTypes/TFC_TouchInteractionConfig.dart';
import '../../UI/FoundationalElements/TFC_AppStyle.dart';
import 'Box.dart';
import '../../UI/FoundationalElements/TFC_BoxLimitations.dart';
import '../../UI/FoundationalElements/TU.dart';
import '../../UI/PrebuiltWidgets/TFC_CustomWidgets.dart';

class TFC_AppBar extends StatelessWidget {
  final Image? image;
  final String? text;
  final void Function(BuildContext)? openTheSettingsPage;

  const TFC_AppBar.image(Image image, {this.openTheSettingsPage = null})
    : this.image = image,
      this.text = null;

  const TFC_AppBar.text(String text, {this.openTheSettingsPage = null})
    : this.image = null,
      this.text = text;

  const TFC_AppBar.blank({this.openTheSettingsPage = null})
    : this.image = null,
      this.text = null;
  
  static Box<TFC_MustBeFixedSize> blankAppBarBuilder(BuildContext context) {
    return TFC_AppBar.blank().build(context);
  }

  @override
  Box<TFC_MustBeFixedSize> build(BuildContext context) {
    const double sideButtonSize_tu = 8.25;

    // Determine what widget to make the title widget.
    Widget? titleWidget;
    if (this.image != null) {
      titleWidget = image;
    } else if (this.text != null) {
      titleWidget = TFC_Text.subheading(
        this.text!,
        color: TFC_AppStyle.COLOR_BACKGROUND,
      );
    }

    // Sometimes add a back button
    Widget? backbutton = null;
    if (Navigator.of(context).canPop()) {
      backbutton = Box(
        width: AxisSize.growToFillSpace(),
        height: AxisSize.growToFillSpace(),
        touchInteractionConfig: TFC_TouchInteractionConfig(
          onTap: () {
            Navigator.of(context).pop();
          }
        ),
        childToBoxSpacing: ChildToBoxSpacing.center(),
        children: [
          Icon(
            Icons.arrow_back,
            size: TU.toFU(7.5),
            color: TFC_AppStyle.COLOR_BACKGROUND,
          ),
        ],
      );
    }

    // Sometimes add a settings button
    Widget? settingsButton = null;
    if (openTheSettingsPage != null) {
      settingsButton = Box(
        width: AxisSize.growToFillSpace(),
        height: AxisSize.growToFillSpace(),
        touchInteractionConfig: TFC_TouchInteractionConfig(
          onTap: () {
            openTheSettingsPage!(context);
          }
        ),
        childToBoxSpacing: ChildToBoxSpacing.center(),
        children: [
          Icon(
            Icons.settings,
            size: TU.toFU(7.5),
            color: TFC_AppStyle.COLOR_BACKGROUND,
          ),
        ],
      );
    }

    // Construct the AppBar
    return Box.fixedSize(
      widthIsTU: false,
      width_tuORfu: TFC_AppStyle.instance.screenWidth,
      heightIsTU: false,
      height_tuORfu: TU.toFU(sideButtonSize_tu),// + (2 * TU.toFU(6)),
      mainAxis: Axis3D.HORIZONTAL,
      /*childToBoxSpacing: ChildToBoxSpacing.center(
        padding_tu: 6
      ),*/
      childToChildSpacingHorizontal: ChildToChildSpacing.spaceBetween(),
      boxDecoration: TFC_BoxDecoration.noOutline(
        backgroundDecoration: TFC_BackgroundDecoration.color(TFC_AppStyle.colorPrimary),
        shadow: TFC_AppStyle.APP_BAR_SHADOW_STANDARD,
      ),
      children: [
        // Back Button
        Box(
          width: AxisSize.tu(sideButtonSize_tu),
          height: AxisSize.tu(sideButtonSize_tu),
          children: [
            backbutton
          ],
        ),

        // Title Widget
        Box(
          width: AxisSize.shrinkToFitContents(),
          height: AxisSize.shrinkToFitContents(),
          childToBoxSpacing: ChildToBoxSpacing.center(),
          children: [
            titleWidget,
          ],
        ),

        // Settings Button
        Box(
          width: AxisSize.tu(sideButtonSize_tu),
          height: AxisSize.tu(sideButtonSize_tu),
          children: [
            settingsButton,
          ],
        ),
      ],
    );
  }
}