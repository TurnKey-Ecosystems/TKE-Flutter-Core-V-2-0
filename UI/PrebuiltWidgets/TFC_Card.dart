import 'package:flutter/material.dart';
import '../../UI/ConfigurationTypes/TFC_AxisSize.dart';
import '../../UI/ConfigurationTypes/TFC_BackgroundDecoration.dart';
import '../../UI/ConfigurationTypes/TFC_BoxDecoration.dart';
import '../ConfigurationTypes/TFC_ChildToBoxSpacing.dart';
import '../../UI/ConfigurationTypes/TFC_CornerDecoration.dart';
import '../ConfigurationTypes/TFC_ChildToChildSpacing.dart';
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
    List<Widget> children = const [],
    TFC_Axis mainAxis = TFC_Axis.VERTICAL,
    TFC_ChildToBoxSpacing boxToChildAlign =
      const TFC_ChildToBoxSpacing.center(
        padding_tu: 6,
      ),
    TFC_ChildToChildSpacing interChildAlignHorizontal = const TFC_ChildToChildSpacing.uniformPaddingTU(6),
    TFC_ChildToChildSpacing interChildAlignmentVertical = const TFC_ChildToChildSpacing.uniformPaddingTU(6),
    TFC_BackgroundDecoration backgroundDecoration =
      const TFC_BackgroundDecoration.color(TFC_AppStyle.COLOR_BACKGROUND),
    TFC_CornerDecoration cornerDecoration =
      const TFC_CornerDecoration.rounded(radius_tu: 6),
    TFC_Shadow? shadow,
    void Function()? onTap = null,
  }) : super(
    width: width,
    height: height,
    childToBoxSpacing:
      boxToChildAlign,
    mainAxis: mainAxis,
    childToChildSpacingHorizontal: interChildAlignHorizontal,
    childToChildSpacingVertical: interChildAlignmentVertical,
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