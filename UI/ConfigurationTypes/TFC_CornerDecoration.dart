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
  final double topLeftRadius_tu;

  /**
   * The radius of the rounding on the top left corner in flutter units.
   */
  double get topLeftRadius_fu {
    return TU.toFU(topLeftRadius_tu)!;
  }
  
  /**
   * The radius of the rounding on the top right corner in tke units.
   */
  final double topRightRadius_tu;

  /**
   * The radius of the rounding on the top right corner in flutter units.
   */
  double get topRightRadius_fu {
    return TU.toFU(topRightRadius_tu)!;
  }
  
  /**
   * The radius of the rounding on the bottom left corner in tke units.
   */
  final double bottomLeftRadius_tu;

  /**
   * The radius of the rounding on the bottom left corner in flutter units.
   */
  double get bottomLeftRadius_fu {
    return TU.toFU(bottomLeftRadius_tu)!;
  }
  
  /**
   * The radius of the rounding on the bottom right corner in tke units.
   */
  final double bottomRightRadius_tu;

  /**
   * The radius of the rounding on the bottom right corner in flutter units.
   */
  double get bottomRightRadius_fu {
    return TU.toFU(bottomRightRadius_tu)!;
  }


  /**
   * Defines four sharp corners.
   */
  const TFC_CornerDecoration.none()
    : topLeftRadius_tu = 0.0,
      topRightRadius_tu = 0.0,
      bottomLeftRadius_tu = 0.0,
      bottomRightRadius_tu = 0.0;


  /**
   * Rounds all corners with the given radius.
   */
  const TFC_CornerDecoration.rounded({required double radius_tu})
    : topLeftRadius_tu = radius_tu,
      topRightRadius_tu = radius_tu,
      bottomLeftRadius_tu = radius_tu,
      bottomRightRadius_tu = radius_tu;
}