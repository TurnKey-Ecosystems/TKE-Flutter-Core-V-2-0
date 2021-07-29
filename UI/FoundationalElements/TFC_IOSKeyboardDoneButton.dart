import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tke_dev_time_tracker_flutter_tryw/TKE-Flutter-Core/UI/PrebuiltWidgets/TFC_Button.dart';
import 'TFC_AppStyle.dart';
import '../../Utilities/TFC_Utilities.dart';

class TFC_IOSKeyboardDoneButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && Platform.isIOS && MediaQuery.of(context).viewInsets.bottom > 0.0) {
      return Container(
        alignment: Alignment.centerRight,
        width: TFC_AppStyle.instance.screenWidth,
        height: TFC_AppStyle.instance.iosKeyboardDoneButtonHeight,
        color: TFC_AppStyle.COLOR_HINT,
        child: Container(
          width: TFC_AppStyle.instance.iosKeyboardDoneButtonWidth,
          height: TFC_AppStyle.instance.iosKeyboardDoneButtonHeight,
          child: TFC_Button.solid(
            onTap: () {
              TFC_Utilities.closeTheKeyboard(context);
            },
            child: Icon(Icons.done, color: TFC_AppStyle.COLOR_BACKGROUND,),
            color: TFC_AppStyle.colorPrimary,
          ),
        ),
      );
    } else {
      return Container(width: 0.0, height: 0.0);
    }
  }
}

class TFC_IOSKeyboardDoneButtonLocation extends FloatingActionButtonLocation {
  final double _buttonHeight;

  TFC_IOSKeyboardDoneButtonLocation(this._buttonHeight);

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    double offsetY = scaffoldGeometry.contentBottom - _buttonHeight;
    return Offset(0.0, offsetY);
  }
}