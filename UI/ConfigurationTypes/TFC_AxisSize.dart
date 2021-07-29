import 'package:flutter/cupertino.dart';
import 'package:tke_dev_time_tracker_flutter_tryw/TKE-Flutter-Core/UI/FoundationalElements/TU.dart';
import './TFC_Configuration.dart';

class TFC_AxisSize extends TFC_Configuration {
  final double? size_tu;
  final bool isScrollable;

  double? get size_fu {
    return (size_tu != null) ? TU.toFU(size_tu!) : null;
  }

  MainAxisSize get axisSize {
    if (size_tu == null) {
      return MainAxisSize.min;
    } else {
      return MainAxisSize.max;
    }
  }

  const TFC_AxisSize.tu(double size_tu)
    : this.size_tu = size_tu,
      this.isScrollable = false;

  TFC_AxisSize.fu(double size_fu)
    : this.size_tu = TU.fromFU(size_fu),
      this.isScrollable = false;

  const TFC_AxisSize.shrinkToFitContents()
    : size_tu = null,
      this.isScrollable = false;

  const TFC_AxisSize.growToFillSpace()
    : size_tu = double.infinity,
      isScrollable = false;

  const TFC_AxisSize.scrollableSizedTU(double size_tu)
    : this.size_tu = size_tu,
      this.isScrollable = true;

  TFC_AxisSize.scrollableSizedFU(double size_fu)
    : this.size_tu = TU.fromFU(size_fu),
      this.isScrollable = true;

  const TFC_AxisSize.scrollableShrinkToFitContents()
    : this.size_tu = null,
      this.isScrollable = true;
}