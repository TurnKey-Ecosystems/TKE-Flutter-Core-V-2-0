import 'package:flutter/material.dart';
import '../UI/TFC_AppStyle.dart';

class TFC_Button extends StatelessWidget {
  final double width;
  final double height;
  EdgeInsetsGeometry margin;
  Widget buttonWidget;

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
  }) {
    color = (color != null) ? color : TFC_AppStyle.colorPrimary;
    margin = (margin != null)
        ? margin
        : EdgeInsets.all(TFC_AppStyle.instance.pageMargins);
    buttonWidget = ElevatedButton(
      key: key,
      onPressed: onPressed,
      onLongPress: onLongPress,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(color),
        elevation: MaterialStateProperty.all(0.0),
      ),
      focusNode: focusNode,
      autofocus: autofocus,
      clipBehavior: clipBehavior,
      child: child,
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
    color = (color != null) ? color : TFC_AppStyle.colorPrimary;
    margin = (margin != null)
        ? margin
        : EdgeInsets.all(TFC_AppStyle.instance.pageMargins);
    buttonWidget = OutlinedButton(
      key: key,
      onPressed: onPressed,
      onLongPress: onLongPress,
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all<Color>(color),
        elevation: MaterialStateProperty.all(0.0),
      ),
      focusNode: focusNode,
      autofocus: autofocus,
      clipBehavior: clipBehavior,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: buttonWidget,
    );
  }
}
