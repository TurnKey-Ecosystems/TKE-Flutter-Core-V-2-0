import 'package:flutter/material.dart';
import 'TFC_AppStyle.dart';

// Tab Widget
class TFC_Tab extends Tab {
  TFC_Tab({Key key, String text, Icon icon, Color textColor})
      : super(
          key: key,
          child: Text(
            text,
            style: TFC_AppStyle.instance.textStyleBody.apply(color: textColor),
          ),
          icon: icon,
        );
}

// Text widget factory
class TFC_Text extends Text {
  TFC_Text(
    String text,
    TFC_TextType textType, {
    Key key,
    TextAlign textAlign,
    Color color,
  }) : super(
          text,
          key: key,
          textAlign: (textAlign != null)
              ? textAlign
              : TFC_AppStyle.instance.textAlignments[textType],
          style: TFC_AppStyle.instance.textStyle[textType].apply(
            color: (color != null) ? color : TFC_AppStyle.textColors[textType],
          ),
        );

  factory TFC_Text.heading(
    String text, {
    Key key,
    TextAlign textAlign,
    Color color,
  }) {
    return TFC_Text(text, TFC_TextType.HEADING,
        key: key, textAlign: textAlign, color: color);
  }

  factory TFC_Text.subheading(
    String text, {
    Key key,
    TextAlign textAlign,
    Color color,
  }) {
    return TFC_Text(text, TFC_TextType.SUBHEADING,
        key: key, textAlign: textAlign, color: color);
  }

  factory TFC_Text.title(
    String text, {
    Key key,
    TextAlign textAlign,
    Color color,
  }) {
    return TFC_Text(text, TFC_TextType.TITLE,
        key: key, textAlign: textAlign, color: color);
  }

  factory TFC_Text.body(
    String text, {
    Key key,
    TextAlign textAlign,
    Color color,
  }) {
    return TFC_Text(text, TFC_TextType.BODY,
        key: key, textAlign: textAlign, color: color);
  }
}

// Input Border Widgets
class TFC_InputBorder {
  static InputBorder fromBorderType(
      {@required TFC_BorderType borderType, @required color}) {
    if (borderType == TFC_BorderType.OUTLINED) {
      return OutlineInputBorder(
        borderSide: BorderSide(color: color),
      );
    } else if (borderType == TFC_BorderType.UNDERLINED) {
      return UnderlineInputBorder(
        borderSide: BorderSide(color: color),
      );
    } else {
      throw ("TFC_CustomWidgets.dart TFC_InputBorder.fromBorderType() does not handle the " +
          borderType.toString() +
          " border type.");
    }
  }
}

// Progress Indicator Widget
class TFC_ProgressIndicator extends CircularProgressIndicator {
  TFC_ProgressIndicator({Key key, Color color})
      : super(
          key: key,
          backgroundColor: (color != null) ? color : TFC_AppStyle.colorPrimary,
        );
}

// Outlined Button Widget
class TFC_OutlinedButton extends OutlineButton {
  TFC_OutlinedButton({
    Key key,
    Function onPressed,
    Widget child,
  }) : super(
          key: key,
          color: TFC_AppStyle.colorPrimary,
          onPressed: onPressed,
          child: child,
        );
}
