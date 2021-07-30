import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../UI/ConfigurationTypes/TFC_AxisSize.dart';
import '../../UI/ConfigurationTypes/TFC_BackgroundDecoration.dart';
import '../../UI/ConfigurationTypes/TFC_BoxDecoration.dart';
import '../../UI/ConfigurationTypes/TFC_ChildToBoxSpacing.dart';
import '../../UI/ConfigurationTypes/TFC_ChildToChildSpacing.dart';
import '../../UI/ConfigurationTypes/TFC_Shadow.dart';
import '../../UI/ConfigurationTypes/TFC_TouchInteractionConfig.dart';
import '../../UI/FoundationalElements/TFC_AppStyle.dart';
import '../../UI/FoundationalElements/TFC_Box.dart';
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
  
  static TFC_Box<TFC_MustBeFixedSize> blankAppBarBuilder(BuildContext context) {
    return TFC_AppBar.blank().build(context);
  }

  @override
  TFC_Box<TFC_MustBeFixedSize> build(BuildContext context) {
    const double sideButtonSize_tu = 8;

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
      backbutton = TFC_Box(
        width: TFC_AxisSize.growToFillSpace(),
        height: TFC_AxisSize.growToFillSpace(),
        touchInteractionConfig: TFC_TouchInteractionConfig(
          onTap: () {
            Navigator.of(context).pop();
          }
        ),
        children: [
          Icon(
            Icons.arrow_back_ios,
            size: TU.toFU(7.5),
            color: TFC_AppStyle.COLOR_BACKGROUND,
          ),
        ],
      );
    }

    // Sometimes add a settings button
    Widget? settingsButton = null;
    if (openTheSettingsPage != null) {
      settingsButton = TFC_Box(
        width: TFC_AxisSize.growToFillSpace(),
        height: TFC_AxisSize.growToFillSpace(),
        touchInteractionConfig: TFC_TouchInteractionConfig(
          onTap: () {
            openTheSettingsPage!(context);
          }
        ),
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
    return TFC_Box.fixedSize(
      widthIsTU: false,
      width_tuORfu: TFC_AppStyle.instance.screenWidth,
      heightIsTU: false,
      height_tuORfu: TU.toFU(sideButtonSize_tu) + (2 * TU.toFU(6)),
      mainAxis: TFC_Axis.HORIZONTAL,
      childToBoxSpacing: TFC_ChildToBoxSpacing.center(
        padding_tu: 6
      ),
      childToChildSpacingHorizontal: TFC_ChildToChildSpacing.spaceBetween(),
      boxDecoration: TFC_BoxDecoration.noOutline(
        backgroundDecoration: TFC_BackgroundDecoration.color(TFC_AppStyle.colorPrimary),
        shadow: TFC_Shadow.fromAppStyle(TFC_ShadowType.MEDIUM),
      ),
      children: [
        // Back Button
        TFC_Box(
          width: TFC_AxisSize.tu(sideButtonSize_tu),
          height: TFC_AxisSize.tu(sideButtonSize_tu),
          children: [
            backbutton
          ],
        ),

        // Title Widget
        TFC_Box(
          width: TFC_AxisSize.shrinkToFitContents(),
          height: TFC_AxisSize.shrinkToFitContents(),
          childToBoxSpacing: TFC_ChildToBoxSpacing.center(),
          children: [
            titleWidget,
          ],
        ),

        // Settings Button
        TFC_Box(
          width: TFC_AxisSize.tu(sideButtonSize_tu),
          height: TFC_AxisSize.tu(sideButtonSize_tu),
          children: [
            settingsButton,
          ],
        ),
      ],
    );
  }
}