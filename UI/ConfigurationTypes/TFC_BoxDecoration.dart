import 'package:flutter/material.dart';
import '../FoundationalElements/TU.dart';
import '../FoundationalElements/TFC_AppStyle.dart';
import './TFC_BackgroundDecoration.dart';
import './TFC_Configuration.dart';
import './TFC_CornerDecoration.dart';
import 'TFC_Shadow.dart';

class TFC_BoxDecoration extends TFC_Configuration {
  final TFC_BackgroundDecoration backgroundDecoration;
  final Color? borderColor;
  final double? borderWidth_tu;
  final TFC_CornerDecoration cornerDecoration;
  final TFC_Shadow shadow;

  bool get isOutlined {
    return borderWidth_tu != null;
  }

  double? get borderWidth_fu {
    return TU.toFU(borderWidth_tu);
  }

  BoxDecoration get flutterBoxDecoration {
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
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(cornerDecoration.topLeftRadius_fu),
        topRight: Radius.circular(cornerDecoration.topRightRadius_fu),
        bottomLeft: Radius.circular(cornerDecoration.bottomLeftRadius_fu),
        bottomRight: Radius.circular(cornerDecoration.bottomRightRadius_fu),
      ),
      boxShadow: shadow.flutterShadow,
    );
  }

  const TFC_BoxDecoration.undecorated()
    : this.backgroundDecoration =
        const TFC_BackgroundDecoration.color(Colors.transparent),
      this.borderColor = null,
      this.borderWidth_tu = null,
      this.cornerDecoration = const TFC_CornerDecoration.none(),
      this.shadow = const TFC_Shadow.noShadow();

  const TFC_BoxDecoration.outlined({
    this.backgroundDecoration =
      const TFC_BackgroundDecoration.color(Colors.transparent),
    this.borderColor = TFC_AppStyle.COLOR_HINT,
    this.borderWidth_tu = -3,
    this.cornerDecoration = const TFC_CornerDecoration.none(),
    this.shadow = const TFC_Shadow.noShadow(),
  });

  const TFC_BoxDecoration.noOutline({
    this.backgroundDecoration =
      const TFC_BackgroundDecoration.color(Colors.transparent),
    this.cornerDecoration = const TFC_CornerDecoration.none(),
    this.shadow = const TFC_Shadow.noShadow(),
  })
    : this.borderColor = null,
      this.borderWidth_tu = null;
}