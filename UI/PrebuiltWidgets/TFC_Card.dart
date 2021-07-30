import 'package:flutter/material.dart';
import '../ConfigurationTypes/AxisSize.dart';
import '../../UI/ConfigurationTypes/TFC_BackgroundDecoration.dart';
import '../../UI/ConfigurationTypes/TFC_BoxDecoration.dart';
import '../ConfigurationTypes/ChildToBoxSpacing.dart';
import '../../UI/ConfigurationTypes/TFC_CornerDecoration.dart';
import '../ConfigurationTypes/ChildToChildSpacing.dart';
import '../../UI/ConfigurationTypes/TFC_Shadow.dart';
import '../../UI/ConfigurationTypes/TFC_TouchInteractionConfig.dart';
import '../../UI/FoundationalElements/TFC_AppStyle.dart';
import '../FoundationalElements/Box.dart';

class TFC_Card extends Box {
  TFC_Card({
    String debugName = "",
    AxisSize width =
      const AxisSize.shrinkToFitContents(),
    AxisSize height =
      const AxisSize.shrinkToFitContents(),
    List<Widget?> children = const [],
    Axis3D mainAxis = Axis3D.VERTICAL,
    ChildToBoxSpacing childToBoxSpacing =
      const ChildToBoxSpacing.center(
        padding_tu: 6,
      ),
    ChildToChildSpacing childToChildSpacingHorizontal = const ChildToChildSpacing.uniformPaddingTU(6),
    ChildToChildSpacing childToChildSpacingVertical = const ChildToChildSpacing.uniformPaddingTU(6),
    TFC_BackgroundDecoration backgroundDecoration =
      const TFC_BackgroundDecoration.color(TFC_AppStyle.COLOR_BACKGROUND),
    TFC_CornerDecoration cornerDecoration =
      const TFC_CornerDecoration.rounded(radius_tu: 6),
    TFC_Shadow? shadow,
    void Function()? onTap = null,
  }) : super(
    debugName: debugName,
    width: width,
    height: height,
    childToBoxSpacing:
      childToBoxSpacing,
    mainAxis: mainAxis,
    childToChildSpacingHorizontal: childToChildSpacingHorizontal,
    childToChildSpacingVertical: childToChildSpacingVertical,
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