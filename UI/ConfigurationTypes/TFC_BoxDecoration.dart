import 'package:flutter/material.dart';
import '../FoundationalElements/TU.dart';
import '../FoundationalElements/TFC_AppStyle.dart';
import './TFC_BackgroundDecoration.dart';
import './TFC_Configuration.dart';
import './TFC_CornerDecoration.dart';
import 'TFC_Shadow.dart';

class TFC_BoxDecoration extends TFC_Configuration {
  final bool isDecorated;
  final TFC_BackgroundDecoration backgroundDecoration;
  final Color? borderColor;
  final double? borderWidth_tu;
  final TFC_CornerDecoration cornerDecoration;
  final TFC_Shadow shadow;

  bool get isOutlined {
    return borderWidth_tu != null;
  }

  double? get borderWidth_fu {
    return (borderWidth_tu != null) ? TU.toFU(borderWidth_tu!) : null;
  }

  BoxDecoration? get flutterBoxDecoration {
    if (isDecorated) {
      BoxBorder? border = null;
      if (isOutlined) {
        border = Border.all(
          color: borderColor!,
          width: borderWidth_fu!,
        );
      }
      return BoxDecoration(
        color: backgroundDecoration.color,
        image: backgroundDecoration.image,
        gradient: backgroundDecoration.gradient,
        border: border,
        borderRadius: cornerDecoration.flutterBorderRadius,
        boxShadow: shadow.flutterShadow,
      );
    } else {
      return null;
    }
  }

  const TFC_BoxDecoration.undecorated()
    : this.backgroundDecoration =
        const TFC_BackgroundDecoration.color(Colors.transparent),
      this.borderColor = null,
      this.borderWidth_tu = null,
      this.cornerDecoration = const TFC_CornerDecoration.none(),
      this.shadow = const TFC_Shadow.noShadow(),
      this.isDecorated = false;

  const TFC_BoxDecoration.outlined({
    this.backgroundDecoration =
      const TFC_BackgroundDecoration.color(Colors.transparent),
    this.borderColor = TFC_AppStyle.COLOR_HINT,
    this.borderWidth_tu = 4,
    this.cornerDecoration = const TFC_CornerDecoration.none(),
    this.shadow = const TFC_Shadow.noShadow(),
  }) : this.isDecorated = true;

  const TFC_BoxDecoration.noOutline({
    this.backgroundDecoration =
      const TFC_BackgroundDecoration.color(Colors.transparent),
    this.cornerDecoration = const TFC_CornerDecoration.none(),
    this.shadow = const TFC_Shadow.noShadow(),
  })
    : this.borderColor = null,
      this.borderWidth_tu = null,
      this.isDecorated = true;

  TFC_BoxDecoration.flatColor({
    required Color color,
    this.cornerDecoration = const TFC_CornerDecoration.none(),
    this.shadow = const TFC_Shadow.noShadow(),
  })
    : this.backgroundDecoration =
        TFC_BackgroundDecoration.color(color),
      this.borderColor = null,
      this.borderWidth_tu = null,
      this.isDecorated = true;
}