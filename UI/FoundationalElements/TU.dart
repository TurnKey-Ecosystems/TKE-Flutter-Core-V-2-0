import 'dart:math';
import 'package:tke_simple_widget_bricks_flutter_qx9b/TKE-Flutter-Core/UI/FoundationalElements/TFC_AppStyle.dart';

abstract class TU {
  /**
   * Conversion is exponential. -2=1/4, -1=1/2, 0=1, 1=2, 2=4... 
   * Formula: flutterUnits = conversionConstant * (2 ^ tkeUnits)
   */
  static double? toFU(double? tkeUnits) {
    if (tkeUnits == null) {
      return null;
    } else {
      return TFC_AppStyle.instance.lineHeight * pow(2, tkeUnits);
    }
  }
}