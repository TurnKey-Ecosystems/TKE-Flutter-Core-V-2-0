import 'package:flutter/material.dart';
import '../../Utilities/TFC_Event.dart';
import '../FoundationalElements/TFC_SelfReloadingWidget.dart';
import '../FoundationalElements/TFC_AppStyle.dart';

// Tab Widget
class TFC_Tab extends Tab {
  TFC_Tab({Key? key, required String text, Icon? icon, Color? textColor})
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
class TFC_Text extends TFC_SelfReloadingWidget {
  final String Function() getText;
  final TFC_TextType textType;
  final TextAlign? textAlign;
  final Color? color;
  final bool isUnderlined;

  TFC_Text(
    this.getText,
    this.textType, {
    Key? key,
    this.textAlign,
    this.color,
    this.isUnderlined = false,
    List<TFC_Event?> reloadTriggers = const [],
  }) : super(key: key, reloadTriggers: reloadTriggers);

  TFC_Text.heading(
    this.getText, {
    Key? key,
    this.textAlign,
    this.color,
    this.isUnderlined = false,
    List<TFC_Event?> reloadTriggers = const [],
  }) :  this.textType = TFC_TextType.HEADING,
        super(key: key, reloadTriggers: reloadTriggers);


  TFC_Text.subheading(
    this.getText, {
    Key? key,
    this.textAlign,
    this.color,
    this.isUnderlined = false,
    List<TFC_Event?> reloadTriggers = const [],
  }) :  this.textType = TFC_TextType.SUBHEADING,
        super(key: key, reloadTriggers: reloadTriggers);


  TFC_Text.title(
    this.getText, {
    Key? key,
    this.textAlign,
    this.color,
    this.isUnderlined = false,
    List<TFC_Event?> reloadTriggers = const [],
  }) :  this.textType = TFC_TextType.TITLE,
        super(key: key, reloadTriggers: reloadTriggers);


  TFC_Text.body(
    this.getText, {
    Key? key,
    this.textAlign,
    this.color,
    this.isUnderlined = false,
    List<TFC_Event?> reloadTriggers = const [],
  }) :  this.textType = TFC_TextType.BODY,
        super(key: key, reloadTriggers: reloadTriggers);

  @override
  Widget buildWidget(BuildContext context) {
    return Text(
      getText(),
      key: key,
      textAlign: (textAlign != null)
          ? textAlign
          : TFC_AppStyle.instance.textAlignments[textType],
      style: TFC_AppStyle.instance.textStyle[textType]!.apply(
          color:
              (color != null) ? color : TFC_AppStyle.textColors[textType],
          decoration: (isUnderlined) ? TextDecoration.underline : null),
    );
  }
}

// Input Border Widgets
class TFC_InputBorder {
  static InputBorder fromBorderType(
      {required TFC_BorderType borderType, required color}) {
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
  TFC_ProgressIndicator({Key? key, Color? color})
      : super(
          key: key,
          backgroundColor: (color != null) ? color : TFC_AppStyle.colorPrimary,
        );
}

// Outlined Button Widget
/*class TFC_OutlinedButton extends OutlineButton {
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
}*/
