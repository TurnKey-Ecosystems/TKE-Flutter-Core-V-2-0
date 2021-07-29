import 'package:flutter/cupertino.dart';
import '../FoundationalElements/TU.dart';

class TFC_ChildToBoxSpacing {
  // Properties
  /**
   * Left=-1.0, Center=0.0, Right=1.0
   */
  final double x_relative;
  /**
   * Top=-1.0, Center=0.0, Bottom=1.0
   */
  final double y_relative;
  final double? padding_tu;

  // Values for flutter
  Alignment get flutterAlignment {
    return Alignment(x_relative, y_relative);
  }
  EdgeInsetsGeometry? get flutterPadding {
    if (padding_tu == null) {
      return null;
    } else {
      return EdgeInsets.all(TU.toFU(padding_tu!));
    }
  }

  const TFC_ChildToBoxSpacing({
    this.x_relative = 0.0,
    this.y_relative = 0.0,
    this.padding_tu,
  });

  const TFC_ChildToBoxSpacing.topLeft({
    this.padding_tu,
  })
    : x_relative = -1.0,
      y_relative = -1.0;

  const TFC_ChildToBoxSpacing.topCenter({
    this.padding_tu,
  })
    : x_relative = 0.0,
      y_relative = -1.0;

  const TFC_ChildToBoxSpacing.topRight({
    this.padding_tu,
  })
    : x_relative = 1.0,
      y_relative = -1.0;

  const TFC_ChildToBoxSpacing.centerLeft({
    this.padding_tu,
  })
    : x_relative = -1.0,
      y_relative = 0.0;

  const TFC_ChildToBoxSpacing.center({
    this.padding_tu,
  })
    : x_relative = 0.0,
      y_relative = 0.0;

  const TFC_ChildToBoxSpacing.centerRight({
    this.padding_tu,
  })
    : x_relative = 1.0,
      y_relative = 0.0;

  const TFC_ChildToBoxSpacing.bottomLeft({
    this.padding_tu,
  })
    : x_relative = -1.0,
      y_relative = 1.0;

  const TFC_ChildToBoxSpacing.bottomCenter({
    this.padding_tu,
  })
    : x_relative = 0.0,
      y_relative = 1.0;

  const TFC_ChildToBoxSpacing.bottomRight({
    this.padding_tu,
  })
    : x_relative = 1.0,
      y_relative = 1.0;
}