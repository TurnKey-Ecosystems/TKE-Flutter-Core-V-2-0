import 'package:flutter/cupertino.dart';
import '../../UI/FoundationalElements/TU.dart';
import './TFC_Configuration.dart';

class AxisSize extends TFC_Configuration {
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

  const AxisSize.tu(double size_tu)
    : this.size_tu = size_tu,
      this.isScrollable = false;

  AxisSize.fu(double size_fu)
    : this.size_tu = TU.fromFU(size_fu),
      this.isScrollable = false;

  const AxisSize.shrinkToFitContents()
    : size_tu = null,
      this.isScrollable = false;

  const AxisSize.growToFillSpace()
    : size_tu = double.infinity,
      isScrollable = false;

  const AxisSize.scrollableSizedTU(double size_tu)
    : this.size_tu = size_tu,
      this.isScrollable = true;

  AxisSize.scrollableSizedFU(double size_fu)
    : this.size_tu = TU.fromFU(size_fu),
      this.isScrollable = true;

  const AxisSize.scrollableShrinkToFitContents()
    : this.size_tu = null,
      this.isScrollable = true;
}