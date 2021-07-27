import 'package:flutter/material.dart';

class TFC_InterChildAlign {
  final MainAxisAlignment? axisAlignment;
  final double? uniformPadding_tu;

  const TFC_InterChildAlign.uniformPaddingTU(this.uniformPadding_tu)
    : axisAlignment = null;

  const TFC_InterChildAlign.noPadding()
    : axisAlignment = null,
      uniformPadding_tu = null;
  
  const TFC_InterChildAlign.spaceAround()
    : axisAlignment = MainAxisAlignment.spaceAround,
      uniformPadding_tu = 0;
  
  const TFC_InterChildAlign.spaceBetween()
    : axisAlignment = MainAxisAlignment.spaceBetween,
      uniformPadding_tu = 0;
  
  const TFC_InterChildAlign.spaceEvenly()
    : axisAlignment = MainAxisAlignment.spaceEvenly,
      uniformPadding_tu = 0;
}