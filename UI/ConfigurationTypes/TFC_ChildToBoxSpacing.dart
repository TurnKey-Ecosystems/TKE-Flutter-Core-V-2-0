import 'package:flutter/cupertino.dart';
import '../FoundationalElements/TU.dart';

enum _TFC_Alignment { START, CENTER, END }

class TFC_ChildToBoxSpacing {
  // Properties
  /**
   * Left=-1.0, Center=0.0, Right=1.0
   */
  //final double x_relative;
  final _TFC_Alignment horizontalAlignment;
  /**
   * Top=-1.0, Center=0.0, Bottom=1.0
   */
  //final double y_relative;
  final _TFC_Alignment verticalAlignment;
  final double? padding_tu;

  // Values for flutter
  Alignment get flutterAlignment {
    return Alignment(
      _alignEnumToAlignValue(horizontalAlignment),
      _alignEnumToAlignValue(verticalAlignment),
    );
  }
  EdgeInsetsGeometry? get flutterPadding {
    if (padding_tu == null) {
      return null;
    } else {
      return EdgeInsets.all(TU.toFU(padding_tu!));
    }
  }

  /*const TFC_ChildToBoxSpacing({
    this.x_relative = 0.0,
    this.y_relative = 0.0,
    this.padding_tu,
  });*/

  const TFC_ChildToBoxSpacing.topLeft({
    this.padding_tu,
  })
    : this.horizontalAlignment = _TFC_Alignment.START,
      this.verticalAlignment = _TFC_Alignment.START;

  const TFC_ChildToBoxSpacing.topCenter({
    this.padding_tu,
  })
    : this.horizontalAlignment = _TFC_Alignment.CENTER,
      this.verticalAlignment = _TFC_Alignment.START;

  const TFC_ChildToBoxSpacing.topRight({
    this.padding_tu,
  })
    : this.horizontalAlignment = _TFC_Alignment.END,
      this.verticalAlignment = _TFC_Alignment.START;

  const TFC_ChildToBoxSpacing.centerLeft({
    this.padding_tu,
  })
    : this.horizontalAlignment = _TFC_Alignment.START,
      this.verticalAlignment = _TFC_Alignment.CENTER;

  const TFC_ChildToBoxSpacing.center({
    this.padding_tu,
  })
    : this.horizontalAlignment = _TFC_Alignment.CENTER,
      this.verticalAlignment = _TFC_Alignment.CENTER;

  const TFC_ChildToBoxSpacing.centerRight({
    this.padding_tu,
  })
    : this.horizontalAlignment = _TFC_Alignment.END,
      this.verticalAlignment = _TFC_Alignment.CENTER;

  const TFC_ChildToBoxSpacing.bottomLeft({
    this.padding_tu,
  })
    : this.horizontalAlignment = _TFC_Alignment.START,
      this.verticalAlignment = _TFC_Alignment.END;

  const TFC_ChildToBoxSpacing.bottomCenter({
    this.padding_tu,
  })
    : this.horizontalAlignment = _TFC_Alignment.CENTER,
      this.verticalAlignment = _TFC_Alignment.END;

  const TFC_ChildToBoxSpacing.bottomRight({
    this.padding_tu,
  })
    : this.horizontalAlignment = _TFC_Alignment.END,
      this.verticalAlignment = _TFC_Alignment.END;
  
  static double _alignEnumToAlignValue(_TFC_Alignment enumAlign) {
    switch(enumAlign) {
      case _TFC_Alignment.START:
        return -1;
      case _TFC_Alignment.CENTER:
        return 0;
      case _TFC_Alignment.END:
        return 1;
    }
  }

  static MainAxisAlignment tfcAlignToMainAxisAlignment(_TFC_Alignment tfcAlign) {
    switch(tfcAlign) {
      case _TFC_Alignment.START:
        return MainAxisAlignment.start;
      case _TFC_Alignment.CENTER:
        return MainAxisAlignment.center;
      case _TFC_Alignment.END:
        return MainAxisAlignment.end;
    }
  }

  static CrossAxisAlignment tfcAlignToCrossAxisAlignment(_TFC_Alignment tfcAlign) {
    switch(tfcAlign) {
      case _TFC_Alignment.START:
        return CrossAxisAlignment.start;
      case _TFC_Alignment.CENTER:
        return CrossAxisAlignment.center;
      case _TFC_Alignment.END:
        return CrossAxisAlignment.end;
    }
  }
}