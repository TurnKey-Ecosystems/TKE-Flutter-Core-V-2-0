import 'dart:math';
import './TFC_AppStyle.dart';

abstract class TU {
  static const double _offset = 7;
  /**
   * 7 should be about the height of 1 line of body text.
   * For tkeUnits >= 1 the conversion is exponential: 3=1/4, 4=1/2, 5=1, 6=2, 7=4...
   * For tkeUnits < 1 they decrease linerally from 1tu to 0fu.
   * Formula: flutterUnits = conversionConstant * (2 ^ tkeUnits - 7)
   */
  static double toFU(double tkeUnits) {
    if (tkeUnits <= 0) {
      return 0;
    } else if (tkeUnits < 1) {
      return TU.toFU(1) * tkeUnits;
    } else if (tkeUnits == double.infinity) {
      return double.infinity;
    } else {
      return TFC_AppStyle.instance.lineHeight * pow(2, tkeUnits - _offset);
    }
  }

  static double fromFU(double flutterUnits) {
    if (flutterUnits <= 0) {
      return 0;
    } else if (flutterUnits < TU.toFU(1)) {
      return flutterUnits / TU.toFU(1);
    } else if (flutterUnits == double.infinity) {
      return double.infinity;
    } else {
      return (log(flutterUnits / TFC_AppStyle.instance.lineHeight) / log(2)) + _offset;
    }
  }
}