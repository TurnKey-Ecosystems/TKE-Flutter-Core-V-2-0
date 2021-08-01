import 'package:flutter/material.dart';
import './TU.dart';
import '../ConfigurationTypes/TFC_Shadow.dart';
import 'TFC_IOSKeyboardDoneButton.dart';

enum TFC_TextType { HEADING, SUBHEADING, TITLE, BODY }
enum TFC_BorderType {
  OUTLINED,
  UNDERLINED,
}
enum TFC_ShadowType { SMALL, MEDIUM, LARGE }

class TFC_AppStyle {
  // Colors
  static late Color colorPrimary;

  ///Color(0xFF006eb6);
  static const Color COLOR_ACCENT = Colors.white;
  static const Color COLOR_BACKGROUND = Colors.white;
  static const Color COLOR_BLACK = Colors.black;
  static const Color COLOR_HINT = Color(0xffc4c4c4);
  static const Color COLOR_ERROR = Colors.red;
  static const Color COLOR_TEXT_HEADING = Color(0xff414042);
  static const Color COLOR_TEXT_SUBHEADING = Color(0xff58595b);
  static const Color COLOR_TEXT_TITLE = Color(0xff5c5c5c);
  static const Color COLOR_TEXT_BODY = Color(0xff5c5c5c);
  static const Color COLOR_SHADOW = Color(0x30000000);//7f?
  static Map<TFC_TextType, Color> get textColors {
    return {
      TFC_TextType.HEADING: COLOR_TEXT_HEADING,
      TFC_TextType.SUBHEADING: COLOR_TEXT_SUBHEADING,
      TFC_TextType.TITLE: COLOR_TEXT_TITLE,
      TFC_TextType.BODY: COLOR_TEXT_BODY,
    };
  }

  static final ThemeData themeData = ThemeData(
    colorScheme: ColorScheme.light().copyWith(
      primary: Colors.green.shade700,
      primaryVariant:  Colors.green.shade700,
      secondary: Colors.green.shade700,
      secondaryVariant: Colors.green.shade700,
    ),
    primaryColor: TFC_AppStyle.colorPrimary,
    accentColor: TFC_AppStyle.COLOR_ACCENT,
    backgroundColor: TFC_AppStyle.COLOR_BACKGROUND,
    hintColor: TFC_AppStyle.COLOR_HINT,
    canvasColor: TFC_AppStyle.COLOR_BACKGROUND,
    unselectedWidgetColor: TFC_AppStyle.COLOR_HINT,
    errorColor: TFC_AppStyle.COLOR_ERROR,
    buttonTheme: ButtonThemeData(
      minWidth: 0.0,
    ),
    shadowColor: TFC_AppStyle.COLOR_SHADOW,
    dialogTheme: DialogTheme(
      titleTextStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: TFC_AppStyle.COLOR_TEXT_BODY),
      contentTextStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: TFC_AppStyle.COLOR_TEXT_BODY),
    ),
  );

  // Logos
  static String? appLoadingLogoAssetPath;
  static String? appBarLogoAssetPath;

  // Sizing
  static const double SCREEN_WIDTH_IN_M2_UNITS = 24;
  static const double MARGINS_IN_M2_UNITS = 1;
  
  // Shadows
  static TFC_Shadow get APP_BAR_SHADOW_STANDARD {
    return TFC_Shadow(
      offset: Offset(TU.toFU(4.5), TU.toFU(4.5)),
      blurRadius: TU.toFU(6),
      spreadRadius: TU.toFU(2),
    );
  }
  static TFC_Shadow get NAV_BAR_SHADOW_STANDARD {
    return TFC_Shadow(
      offset: Offset(TU.toFU(4.5), -1 * TU.toFU(4.5)),
      blurRadius: TU.toFU(6),
      spreadRadius: TU.toFU(2),
    );
  }
  static TFC_Shadow getShadow(TFC_ShadowType shadowType) {
    switch (shadowType) {
      case TFC_ShadowType.SMALL:
        return TFC_Shadow(
          offset: Offset(
            TU.toFU(3),
            TU.toFU(3),
          ),
          blurRadius: TU.toFU(4.5),
          spreadRadius: TU.toFU(0.5),
        );
      case TFC_ShadowType.MEDIUM:
        return TFC_Shadow(
          offset: Offset(
            TU.toFU(4.5),
            TU.toFU(4.5),
          ),
          blurRadius: TU.toFU(6),
          spreadRadius: TU.toFU(2),
        );
      case TFC_ShadowType.LARGE:
        return TFC_Shadow(
          offset: Offset(
            TU.toFU(5.5),
            TU.toFU(5.5),
          ),
          blurRadius: TU.toFU(7),
          spreadRadius: TU.toFU(3),
        );
    }
  }

  // Instance
  static late _TFC_AppStyleInstanceProperties instance;
  static void setupInstance(BuildContext context) {
    instance = _TFC_AppStyleInstanceProperties(context);
  }
}

class _TFC_AppStyleInstanceProperties {
  // Finals
  final double screenWidth;
  final double screenHeight;
  final double ratioOfM2UnitsToFlutterUnits;

  // Constructor
  _TFC_AppStyleInstanceProperties(BuildContext context)
      : screenWidth = MediaQuery.of(context).size.width,
        screenHeight = MediaQuery.of(context).size.height,
        ratioOfM2UnitsToFlutterUnits = MediaQuery.of(context).size.width /
            TFC_AppStyle.SCREEN_WIDTH_IN_M2_UNITS;

  // Getters
  double get lineHeight {
    return m2UnitsToFlutterUnits(1.0);
  }

  double get buttonHeight {
    return 1.0 * lineHeight;
  }

  double get _internalPageWidthInM2Uits {
    return TFC_AppStyle.SCREEN_WIDTH_IN_M2_UNITS -
        (TFC_AppStyle.MARGINS_IN_M2_UNITS * 2);
  }

  double get internalPageWidth {
    return m2UnitsToFlutterUnits(_internalPageWidthInM2Uits);
  }

  double get pageMargins {
    return m2UnitsToFlutterUnits(TFC_AppStyle.MARGINS_IN_M2_UNITS);
  }

  double m2UnitsToFlutterUnits(double m2Units) {
    return m2Units * ratioOfM2UnitsToFlutterUnits;
  }

  TextStyle get textStyleHeading {
    return TextStyle(
        fontSize: 1.5 * lineHeight,
        fontWeight: FontWeight.bold,
        color: TFC_AppStyle.COLOR_TEXT_HEADING);
  }

  TextStyle get textStyleSubheading {
    return TextStyle(
        fontSize: 1.45 * lineHeight,
        fontWeight: FontWeight.bold,
        color: TFC_AppStyle.COLOR_TEXT_SUBHEADING);
  }

  TextStyle get textStyleTitle {
    return TextStyle(
        fontSize: 1.45 * lineHeight,
        fontWeight: FontWeight.normal,
        color: TFC_AppStyle.COLOR_TEXT_TITLE);
  }

  TextStyle get textStyleBody {
    return TextStyle(
        fontSize: 1.00 * lineHeight,
        fontWeight: FontWeight.normal,
        color: TFC_AppStyle.COLOR_TEXT_BODY);
  }

  Map<TFC_TextType, TextStyle> get textStyle {
    return {
      TFC_TextType.HEADING: textStyleHeading,
      TFC_TextType.SUBHEADING: textStyleSubheading,
      TFC_TextType.TITLE: textStyleTitle,
      TFC_TextType.BODY: textStyleBody,
    };
  }

  Map<TFC_TextType, TextAlign> get textAlignments {
    return {
      TFC_TextType.HEADING: TextAlign.center,
      TFC_TextType.SUBHEADING: TextAlign.center,
      TFC_TextType.TITLE: TextAlign.left,
      TFC_TextType.BODY: TextAlign.left,
    };
  }

  // IosKeyboard Done Button
  double get iosKeyboardDoneButtonWidth {
    return 1.3 * lineHeight;
  }

  double get iosKeyboardDoneButtonHeight {
    return 0.9 * lineHeight;
  }

  Widget get iosKeyboardDoneButton {
    return TFC_IOSKeyboardDoneButton();
  }

  FloatingActionButtonLocation get iosKeyboardDoneButtonLocation {
    return TFC_IOSKeyboardDoneButtonLocation(iosKeyboardDoneButtonHeight);
  }

  FloatingActionButtonAnimator get iosKeyboardDoneButtonAnimator {
    return FloatingActionButtonAnimator.scaling;
  }
}

class _OldStyle {
  /*static const InputBorder DEFAULT_VALUE_BORDER = OutlineInputBorder(
    borderSide: const BorderSide(color: COLOR_HINT, width: 1.0),
  );
  static const InputBorder CUSTOM_VALUE_BORDER = OutlineInputBorder(
    borderSide: const BorderSide(color: COLOR_BLACK, width: 1.0),
  );
  static const InputBorder TEXT_ERROR_BORDER = OutlineInputBorder(
    borderSide: const BorderSide(color: COLOR_ERROR, width: 1.0),
  );*/

}
