import 'package:flutter/cupertino.dart';
import '../FoundationalElements/TU.dart';

class TFC_BoxToChildAlign {
  // Properties
  /**
   * Left=-1.0, Center=0.0, Right=1.0
   */
  final double x_relative;
  /**
   * Top=-1.0, Center=0.0, Bottom=1.0
   */
  final double y_relative;
  final double? paddingBetweenBoxAndContents_tu;

  // Values for flutter
  Alignment get flutterAlignment {
    return Alignment(x_relative, y_relative);
  }
  EdgeInsetsGeometry? get flutterPadding {
    if (TU.toFU(paddingBetweenBoxAndContents_tu) != null) {
      return EdgeInsets.all(TU.toFU(paddingBetweenBoxAndContents_tu)!);
    } else {
      return null;
    }
  }

  const TFC_BoxToChildAlign({
    this.x_relative = 0.0,
    this.y_relative = 0.0,
    this.paddingBetweenBoxAndContents_tu,
  });

  const TFC_BoxToChildAlign.topLeft({
    this.paddingBetweenBoxAndContents_tu,
  })
    : x_relative = -1.0,
      y_relative = -1.0;

  const TFC_BoxToChildAlign.topCenter({
    this.paddingBetweenBoxAndContents_tu,
  })
    : x_relative = 0.0,
      y_relative = -1.0;

  const TFC_BoxToChildAlign.topRight({
    this.paddingBetweenBoxAndContents_tu,
  })
    : x_relative = 1.0,
      y_relative = -1.0;

  const TFC_BoxToChildAlign.centerLeft({
    this.paddingBetweenBoxAndContents_tu,
  })
    : x_relative = -1.0,
      y_relative = 0.0;

  const TFC_BoxToChildAlign.center({
    this.paddingBetweenBoxAndContents_tu,
  })
    : x_relative = 0.0,
      y_relative = 0.0;

  const TFC_BoxToChildAlign.centerRight({
    this.paddingBetweenBoxAndContents_tu,
  })
    : x_relative = 1.0,
      y_relative = 0.0;

  const TFC_BoxToChildAlign.bottomLeft({
    this.paddingBetweenBoxAndContents_tu,
  })
    : x_relative = -1.0,
      y_relative = 1.0;

  const TFC_BoxToChildAlign.bottomCenter({
    this.paddingBetweenBoxAndContents_tu,
  })
    : x_relative = 0.0,
      y_relative = 1.0;

  const TFC_BoxToChildAlign.bottomRight({
    this.paddingBetweenBoxAndContents_tu,
  })
    : x_relative = 1.0,
      y_relative = 1.0;
}