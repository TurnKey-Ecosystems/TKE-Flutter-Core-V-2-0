import 'package:flutter/material.dart';

class TFC_BackgroundDecoration {
  final Color? color;
  final DecorationImage? image;
  final Gradient? gradient;

  const TFC_BackgroundDecoration.color(this.color)
    : this.image = null,
      this.gradient = null;

  const TFC_BackgroundDecoration.image(this.image)
    : this.color = null,
      this.gradient = null;

  const TFC_BackgroundDecoration.gradient(this.gradient)
    : this.color = null,
      this.image = null;
}