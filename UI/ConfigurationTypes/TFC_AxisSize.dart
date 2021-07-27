import 'package:flutter/cupertino.dart';
import 'package:tke_simple_widget_bricks_flutter_qx9b/TKE-Flutter-Core/UI/ConfigurationTypes/TFC_Configuration.dart';

class TFC_AxisSize extends TFC_Configuration {
  final double? size;
  final MainAxisSize? axisSize;

  const TFC_AxisSize.static_tu(this.size)
    : axisSize = null;

  const TFC_AxisSize.shrinkToFitContents()
    : size = null,
      axisSize = MainAxisSize.min;

  const TFC_AxisSize.growToFillSpace()
    : size = null,
      axisSize = MainAxisSize.min;
}