import 'package:flutter/material.dart';

class TFC_ChildToChildSpacing {
  final MainAxisAlignment? axisAlignment;
  final double? uniformPadding_tu;

  const TFC_ChildToChildSpacing.uniformPaddingTU(double uniformPadding_tu)
    : this.axisAlignment = null,
      this.uniformPadding_tu = uniformPadding_tu;

  const TFC_ChildToChildSpacing.noPadding()
    : this.axisAlignment = null,
      this.uniformPadding_tu = null;
  
  const TFC_ChildToChildSpacing.spaceAround()
    : this.axisAlignment = MainAxisAlignment.spaceAround,
      this.uniformPadding_tu = null;
  
  const TFC_ChildToChildSpacing.spaceBetween()
    : this.axisAlignment = MainAxisAlignment.spaceBetween,
      this.uniformPadding_tu = null;
  
  const TFC_ChildToChildSpacing.spaceEvenly()
    : this.axisAlignment = MainAxisAlignment.spaceEvenly,
      this.uniformPadding_tu = null;
}