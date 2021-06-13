import 'dart:developer';

import 'package:flutter/material.dart';
import '../UI/TFC_AppStyle.dart';

class TFC_Button extends StatelessWidget {
  final double width;
  final double height;
  EdgeInsetsGeometry margin;
  Widget buttonWidget;
  BoxDecoration boxDecoration;

  TFC_Button.flat({
    Key key,
    @required VoidCallback onPressed,
    VoidCallback onLongPress,
    FocusNode focusNode,
    bool autofocus = false,
    Clip clipBehavior = Clip.none,
    @required Widget child,
    Color color,
    this.margin,
    this.width,
    this.height,
    double elevation = 0.0,
  }) {
    color = (color == null) ? TFC_AppStyle.colorPrimary : color;
    margin = (margin == null)
        ? EdgeInsets.all(0.5 * TFC_AppStyle.instance.pageMargins)
        : margin;
    buttonWidget = ElevatedButton(
      key: key,
      onPressed: onPressed,
      onLongPress: onLongPress,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(color),
        elevation: MaterialStateProperty.all(
            elevation * TFC_AppStyle.instance.lineHeight),
      ),
      focusNode: focusNode,
      autofocus: autofocus,
      clipBehavior: clipBehavior,
      child: Container(margin: margin, child: child),
    );
  }

  TFC_Button.outlined({
    Key key,
    @required VoidCallback onPressed,
    VoidCallback onLongPress,
    FocusNode focusNode,
    bool autofocus = false,
    Clip clipBehavior = Clip.none,
    @required Widget child,
    Color color,
    this.margin,
    this.width,
    this.height,
  }) {
    color = (color == null) ? TFC_AppStyle.colorPrimary : color;
    margin = (margin == null)
        ? EdgeInsets.all(0.5 * TFC_AppStyle.instance.pageMargins)
        : margin;
    buttonWidget = OutlinedButton(
      key: key,
      onPressed: onPressed,
      onLongPress: onLongPress,
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all<Color>(color),
        foregroundColor: MaterialStateProperty.all<Color>(color),
        elevation: MaterialStateProperty.all(0.0),
        side: MaterialStateProperty.all<BorderSide>(BorderSide(color: color)),
      ),
      focusNode: focusNode,
      autofocus: autofocus,
      clipBehavior: clipBehavior,
      child: Container(margin: margin, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: buttonWidget,
    );
  }
}
