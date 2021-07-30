import 'package:flutter/material.dart';
import '../ConfigurationTypes/AxisSize.dart';
import '../ConfigurationTypes/TFC_BackgroundDecoration.dart';
import '../ConfigurationTypes/TFC_BoxDecoration.dart';
import '../ConfigurationTypes/TFC_CornerDecoration.dart';
import '../ConfigurationTypes/ChildToChildSpacing.dart';
import '../ConfigurationTypes/TFC_Shadow.dart';
import '../ConfigurationTypes/TFC_TouchInteractionConfig.dart';
import '../FoundationalElements/Box.dart';
import '../ConfigurationTypes/ChildToBoxSpacing.dart';
import '../FoundationalElements/TFC_AppStyle.dart';

class TFC_Button extends Box {
  static emptyFunction() {}

  TFC_Button.solid({
    AxisSize width =
      const AxisSize.shrinkToFitContents(),
    AxisSize height =
      const AxisSize.shrinkToFitContents(),
    ChildToBoxSpacing boxToChildAlignmentConfiguration =
      const ChildToBoxSpacing.center(
        padding_tu: 6,
      ),
    Widget child = const Box.empty(),
    Color? color,
    TFC_Shadow shadow =
      const TFC_Shadow.noShadow(),
    void Function() onTap = emptyFunction,
  }) : super(
    width: width,
    height: height,
    childToBoxSpacing:
      boxToChildAlignmentConfiguration,
    mainAxis: Axis3D.VERTICAL,
    childToChildSpacingHorizontal: const ChildToChildSpacing.noPadding(),
    childToChildSpacingVertical: const ChildToChildSpacing.noPadding(),
    children: [ child ],
    boxDecoration: TFC_BoxDecoration.noOutline(
      backgroundDecoration: TFC_BackgroundDecoration.color(color ?? TFC_AppStyle.colorPrimary),
      cornerDecoration: TFC_CornerDecoration.rounded(radius_tu: 4),
      shadow: shadow,
    ),
    touchInteractionConfig: TFC_TouchInteractionConfig(
        onTap: onTap
      ),
  );

  TFC_Button.outlined({
    AxisSize width =
      const AxisSize.shrinkToFitContents(),
    AxisSize height =
      const AxisSize.shrinkToFitContents(),
    ChildToBoxSpacing boxToChildAlignmentConfiguration =
      const ChildToBoxSpacing.center(
        padding_tu: 6,
      ),
    Color? borderColor,
    Color backgroundColor = TFC_AppStyle.COLOR_BACKGROUND,
    double borderWidth_tu = 4,
    TFC_CornerDecoration cornerDecoration =
      const TFC_CornerDecoration.rounded(radius_tu: 4),
    TFC_Shadow shadow =
      const TFC_Shadow.noShadow(),
    Widget child = const Box.empty(),
    void Function() onTap = emptyFunction,
  }) : super(
    width: width,
    height: height,
    childToBoxSpacing:
      boxToChildAlignmentConfiguration,
    mainAxis: Axis3D.VERTICAL,
    childToChildSpacingHorizontal: const ChildToChildSpacing.noPadding(),
    childToChildSpacingVertical: const ChildToChildSpacing.noPadding(),
    children: [ child ],
    boxDecoration: TFC_BoxDecoration.outlined(
      borderColor: borderColor ?? TFC_AppStyle.colorPrimary,
      borderWidth_tu: borderWidth_tu,
      backgroundDecoration: TFC_BackgroundDecoration.color(backgroundColor),
      cornerDecoration: cornerDecoration,
      shadow: shadow,
    ),
    touchInteractionConfig: TFC_TouchInteractionConfig(
        onTap: onTap
      ),
  );

  TFC_Button.roundSolid({
    ChildToBoxSpacing boxToChildAlignmentConfiguration =
      const ChildToBoxSpacing.center(
        padding_tu: 6,
      ),
    Widget child = const Box.empty(),
    Color? color,
    TFC_Shadow shadow =
      const TFC_Shadow.noShadow(),
    void Function() onTap = emptyFunction,
  }) : super(
    width: AxisSize.tu(9),
    height: AxisSize.tu(9),
    childToBoxSpacing:
      boxToChildAlignmentConfiguration,
    mainAxis: Axis3D.VERTICAL,
    childToChildSpacingHorizontal: const ChildToChildSpacing.noPadding(),
    childToChildSpacingVertical: const ChildToChildSpacing.noPadding(),
    children: [ child ],
    boxDecoration: TFC_BoxDecoration.noOutline(
      backgroundDecoration: TFC_BackgroundDecoration.color(color ?? TFC_AppStyle.colorPrimary),
      cornerDecoration: TFC_CornerDecoration.rounded(radius_tu: 8),
      shadow: shadow,
    ),
    touchInteractionConfig: TFC_TouchInteractionConfig(
        onTap: onTap
      ),
  );
}
