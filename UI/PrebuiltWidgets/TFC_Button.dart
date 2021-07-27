import 'package:flutter/material.dart';
import '../ConfigurationTypes/TFC_AxisSize.dart';
import '../ConfigurationTypes/TFC_BackgroundDecoration.dart';
import '../ConfigurationTypes/TFC_BoxDecoration.dart';
import '../ConfigurationTypes/TFC_CornerDecoration.dart';
import '../ConfigurationTypes/TFC_InterChildAlign.dart';
import '../ConfigurationTypes/TFC_Shadow.dart';
import '../ConfigurationTypes/TFC_TouchInteractionConfig.dart';
import '../FoundationalElements/TFC_Box.dart';
import '../ConfigurationTypes/TFC_BoxToChildAlign.dart';
import '../FoundationalElements/TFC_AppStyle.dart';

class TFC_Button extends TFC_Box {
  static _emptyFunction() {}

  TFC_Button.solid({
    TFC_AxisSize width =
      const TFC_AxisSize.shrinkToFitContents(),
    TFC_AxisSize height =
      const TFC_AxisSize.shrinkToFitContents(),
    TFC_BoxToChildAlign boxToChildAlignmentConfiguration =
      const TFC_BoxToChildAlign.center(
        paddingBetweenBoxAndContents_tu: -1,
      ),
    Widget child = const TFC_Box.empty(),
    Color? color,
    TFC_Shadow shadow =
      const TFC_Shadow.noShadow(),
    void Function() onTap = _emptyFunction,
  }) : super(
    width: width,
    height: height,
    boxToChildAlignmentConfiguration:
      boxToChildAlignmentConfiguration,
    mainAxis: TFC_Axis.VERTICAL,
    interChildAlignHorizontal: const TFC_InterChildAlign.noPadding(),
    interChildAlignmentVertical: const TFC_InterChildAlign.noPadding(),
    children: [ child ],
    boxDecoration: TFC_BoxDecoration.noOutline(
      backgroundDecoration: TFC_BackgroundDecoration.color(color ?? TFC_AppStyle.colorPrimary),
      cornerDecoration: TFC_CornerDecoration.rounded(radius_tu: -3),
      shadow: shadow,
    ),
    touchInteractionConfigurations: TFC_TouchInteractionConfig(
        onTap: onTap
      ),
  );

  TFC_Button.outlined({
    TFC_AxisSize width =
      const TFC_AxisSize.shrinkToFitContents(),
    TFC_AxisSize height =
      const TFC_AxisSize.shrinkToFitContents(),
    TFC_BoxToChildAlign boxToChildAlignmentConfiguration =
      const TFC_BoxToChildAlign.center(
        paddingBetweenBoxAndContents_tu: -1,
      ),
    Color? borderColor,
    Color backgroundColor = TFC_AppStyle.COLOR_BACKGROUND,
    double borderWidth_tu = -3,
    TFC_CornerDecoration cornerDecoration =
      const TFC_CornerDecoration.rounded(radius_tu: -3),
    TFC_Shadow shadow =
      const TFC_Shadow.noShadow(),
    Widget child = const TFC_Box.empty(),
    void Function() onTap = _emptyFunction,
  }) : super(
    width: width,
    height: height,
    boxToChildAlignmentConfiguration:
      boxToChildAlignmentConfiguration,
    mainAxis: TFC_Axis.VERTICAL,
    interChildAlignHorizontal: const TFC_InterChildAlign.noPadding(),
    interChildAlignmentVertical: const TFC_InterChildAlign.noPadding(),
    children: [ child ],
    boxDecoration: TFC_BoxDecoration.outlined(
      borderColor: borderColor ?? TFC_AppStyle.colorPrimary,
      borderWidth_tu: borderWidth_tu,
      backgroundDecoration: TFC_BackgroundDecoration.color(backgroundColor),
      cornerDecoration: cornerDecoration,
      shadow: shadow,
    ),
    touchInteractionConfigurations: TFC_TouchInteractionConfig(
        onTap: onTap
      ),
  );
}
