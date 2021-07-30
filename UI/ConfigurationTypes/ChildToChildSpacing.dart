import 'package:flutter/material.dart';

class ChildToChildSpacing {
  final MainAxisAlignment? axisAlignment;
  final double? uniformPadding_tu;

  const ChildToChildSpacing.uniformPaddingTU(double uniformPadding_tu)
    : this.axisAlignment = null,
      this.uniformPadding_tu = uniformPadding_tu;

  const ChildToChildSpacing.noPadding()
    : this.axisAlignment = null,
      this.uniformPadding_tu = null;
  
  const ChildToChildSpacing.spaceAround()
    : this.axisAlignment = MainAxisAlignment.spaceAround,
      this.uniformPadding_tu = null;
  
  const ChildToChildSpacing.spaceBetween()
    : this.axisAlignment = MainAxisAlignment.spaceBetween,
      this.uniformPadding_tu = null;
  
  const ChildToChildSpacing.spaceEvenly()
    : this.axisAlignment = MainAxisAlignment.spaceEvenly,
      this.uniformPadding_tu = null;
}