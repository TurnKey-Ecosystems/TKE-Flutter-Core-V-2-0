import 'package:flutter/cupertino.dart';
import 'package:tke_dev_time_tracker_flutter_tryw/TKE-Flutter-Core/UI/FoundationalElements/TU.dart';
import './TFC_Configuration.dart';

class TFC_AxisSize extends TFC_Configuration {
  final double? size_fu;
  final MainAxisSize? axisSize;

  CrossAxisAlignment? get crossAxisAlignment {
    if (axisSize == MainAxisSize.max) {
      return CrossAxisAlignment.stretch;
    } else {
      return null;
    }
  }

  TFC_AxisSize.static_number_tu(double size_tu)
    : this.size_fu = TU.toFU(size_tu)!,
      this.axisSize = null;

  const TFC_AxisSize.static_number_fu(this.size_fu)
    : axisSize = null;

  const TFC_AxisSize.shrinkToFitContents()
    : size_fu = null,
      axisSize = MainAxisSize.min;

  const TFC_AxisSize.growToFillSpace()
    : size_fu = null,
      axisSize = MainAxisSize.max;
}