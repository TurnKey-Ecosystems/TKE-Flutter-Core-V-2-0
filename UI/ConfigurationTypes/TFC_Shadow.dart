import 'package:flutter/cupertino.dart';
import '../FoundationalElements/TFC_AppStyle.dart';

import 'TFC_Configuration.dart';

class TFC_Shadow extends TFC_Configuration {
  final bool hasShadow;
  final Color? color;
  final Offset? offset;
  final double? blurRadius;

  List<BoxShadow>? get flutterShadow {
    if (hasShadow) {
      return [BoxShadow(
        color: color!,
        offset: offset!,
        blurRadius: blurRadius!,
      )];
    } else {
      return null;
    }
  }


  const TFC_Shadow.noShadow()
    : hasShadow = false,
      color = null,
      offset = null,
      blurRadius = null;

  factory TFC_Shadow.fromAppStyle(TFC_ShadowType shadowType) {
    return TFC_AppStyle.getShadow(shadowType);
  }

  const TFC_Shadow({
    this.color = TFC_AppStyle.COLOR_SHADOW,
    this.offset = Offset.zero,
    this.blurRadius = 0.0,
  })
    : hasShadow = true;

}