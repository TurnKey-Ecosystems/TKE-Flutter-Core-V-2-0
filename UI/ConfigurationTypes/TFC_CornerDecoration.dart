import 'package:flutter/material.dart';

import '../FoundationalElements/TU.dart';

import 'TFC_Configuration.dart';

// TODO: Maybe make radiuses be percentages from 0-1.

/**
 * Defines the rounding radius of corners of a rectangle.
 */
class TFC_CornerDecoration extends TFC_Configuration {
  /**
   * The radius of the rounding on the top left corner in tke units.
   */
  final double? topLeftRadius_tu;

  /**
   * The radius of the rounding on the top left corner in flutter units.
   */
  double? get topLeftRadius_fu {
    if (topLeftRadius_tu != null) {
      return TU.toFU(topLeftRadius_tu!);
    } else {
      return null;
    }
  }
  
  /**
   * The radius of the rounding on the top right corner in tke units.
   */
  final double? topRightRadius_tu;

  /**
   * The radius of the rounding on the top right corner in flutter units.
   */
  double? get topRightRadius_fu {
    if (topRightRadius_tu != null) {
      return TU.toFU(topRightRadius_tu!);
    } else {
      return null;
    }
  }
  
  /**
   * The radius of the rounding on the bottom left corner in tke units.
   */
  final double? bottomLeftRadius_tu;

  /**
   * The radius of the rounding on the bottom left corner in flutter units.
   */
  double? get bottomLeftRadius_fu {
    if (bottomLeftRadius_tu != null) {
      return TU.toFU(bottomLeftRadius_tu!);
    } else {
      return null;
    }
  }
  
  /**
   * The radius of the rounding on the bottom right corner in tke units.
   */
  final double? bottomRightRadius_tu;

  /**
   * The radius of the rounding on the bottom right corner in flutter units.
   */
  double? get bottomRightRadius_fu {
    if (bottomRightRadius_tu != null) {
      return TU.toFU(bottomRightRadius_tu!);
    } else {
      return null;
    }
  }

  BorderRadius? get flutterBorderRadius {
    if (
      topLeftRadius_tu == null
      && topRightRadius_tu == null
      && bottomLeftRadius_tu == null
      && bottomLeftRadius_tu == null
    ) {
      return null;
    } else {
      return BorderRadius.only(
        topLeft: Radius.circular(topLeftRadius_fu ?? 0),
        topRight: Radius.circular(topRightRadius_fu ?? 0),
        bottomLeft: Radius.circular(bottomLeftRadius_fu ?? 0),
        bottomRight: Radius.circular(bottomRightRadius_fu ?? 0),
      );
    }
  }


  /**
   * Defines four sharp corners.
   */
  const TFC_CornerDecoration.none()
    : topLeftRadius_tu = null,
      topRightRadius_tu = null,
      bottomLeftRadius_tu = null,
      bottomRightRadius_tu = null;


  /**
   * Rounds all corners with the given radius.
   */
  const TFC_CornerDecoration.rounded({required double radius_tu})
    : topLeftRadius_tu = radius_tu,
      topRightRadius_tu = radius_tu,
      bottomLeftRadius_tu = radius_tu,
      bottomRightRadius_tu = radius_tu;
}