import 'package:flutter/material.dart';
import '../../UI/ConfigurationTypes/TFC_AxisSize.dart';
import '../../UI/ConfigurationTypes/TFC_BackgroundDecoration.dart';
import '../../UI/ConfigurationTypes/TFC_BoxDecoration.dart';
import '../../UI/ConfigurationTypes/TFC_BoxToChildAlign.dart';
import '../../UI/ConfigurationTypes/TFC_CornerDecoration.dart';
import '../../UI/ConfigurationTypes/TFC_InterChildAlign.dart';
import '../../UI/ConfigurationTypes/TFC_Shadow.dart';
import '../../UI/ConfigurationTypes/TFC_TouchInteractionConfig.dart';
import '../../UI/FoundationalElements/TFC_AppStyle.dart';
import '../FoundationalElements/TFC_Box.dart';

class TFC_Card extends TFC_Box {
  TFC_Card({
    TFC_AxisSize width =
      const TFC_AxisSize.shrinkToFitContents(),
    TFC_AxisSize height =
      const TFC_AxisSize.shrinkToFitContents(),
    TFC_BoxToChildAlign boxToChildAlign =
      const TFC_BoxToChildAlign.center(
        paddingBetweenBoxAndContents_tu: -1,
      ),
    TFC_Axis mainAxis = TFC_Axis.VERTICAL,
    TFC_InterChildAlign interChildAlignHorizontal = const TFC_InterChildAlign.uniformPaddingTU(-1),
    TFC_InterChildAlign interChildAlignmentVertical = const TFC_InterChildAlign.uniformPaddingTU(-1),
    List<Widget> children = const [],
    TFC_BackgroundDecoration backgroundDecoration =
      const TFC_BackgroundDecoration.color(TFC_AppStyle.COLOR_BACKGROUND),
    TFC_CornerDecoration cornerDecoration =
      const TFC_CornerDecoration.rounded(radius_tu: -1),
    TFC_Shadow? shadow,
    void Function()? onTap = null,
  }) : super(
    width: width,
    height: height,
    boxToChildAlign:
      boxToChildAlign,
    mainAxis: mainAxis,
    interChildAlignHorizontal: interChildAlignHorizontal,
    interChildAlignmentVertical: interChildAlignmentVertical,
    children: children,
    boxDecoration: TFC_BoxDecoration.noOutline(
      backgroundDecoration: backgroundDecoration,
      cornerDecoration: cornerDecoration,
      shadow: TFC_Shadow.fromAppStyle(TFC_ShadowType.MEDIUM),
    ),
    touchInteractionConfig: TFC_TouchInteractionConfig(
        onTap: onTap
      ),
  );
}