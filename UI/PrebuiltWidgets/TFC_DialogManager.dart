import 'package:flutter/material.dart';
import '../../UI/ConfigurationTypes/AxisSize.dart';
import '../../UI/ConfigurationTypes/ChildToBoxSpacing.dart';
import '../../UI/ConfigurationTypes/ChildToChildSpacing.dart';
import '../../UI/FoundationalElements/Box.dart';
import '../../UI/PrebuiltWidgets/TFC_Button.dart';
import '../../UI/PrebuiltWidgets/TFC_Card.dart';
import '../../Utilities/TFC_Utilities.dart';
import '../FoundationalElements/TFC_AppStyle.dart';
import 'TFC_CustomWidgets.dart';

class TFC_DialogManager {
  static void showYesNoDialog({
    required BuildContext context,
    required String description,
    required void Function() onYes,
    required void Function() onNo,
  }) {
    showTwoButtonDialog(
      context: context,
      contents: [
        TFC_Text.body(
          description,
          color: TFC_AppStyle.COLOR_TEXT_HEADING,
        ),
      ],
      button1Text: "Yes",
      onButton1: onYes,
      button2Text: "No",
      onButton2: onNo,
    );
  }

  static void showTwoButtonDialog({
    required BuildContext context,
    required List<Widget?> contents,
    required String button1Text,
    required void Function() onButton1,
    required String button2Text,
    required void Function() onButton2,
    ChildToBoxSpacing childToBoxSpacing =
      const ChildToBoxSpacing.center(
        padding_tu: 7,
      ),
    ChildToChildSpacing childToChildSpacingVertical = const ChildToChildSpacing.uniformPaddingTU(7),
  }) {
    // Compile the children
    List<Widget?> children = List<Widget?>.from(contents);
    children.add(
      Box(
        width: AxisSize.growToFillSpace(),
        height: AxisSize.shrinkToFitContents(),
        mainAxis: Axis3D.HORIZONTAL,
        childToChildSpacingHorizontal:
          ChildToChildSpacing.spaceEvenly(),
        children: [
          TFC_Button.outlined(
            child: TFC_Text.body(
              button1Text,
              color: TFC_AppStyle.colorPrimary,
            ),
            borderColor: TFC_AppStyle.colorPrimary,
            backgroundColor: TFC_AppStyle.COLOR_BACKGROUND,
            onTap: onButton1,
          ),
          TFC_Button.solid(
            child: TFC_Text.body(
              button2Text,
              color: TFC_AppStyle.COLOR_BACKGROUND,
            ),
            color: TFC_AppStyle.colorPrimary,
            onTap: onButton2,
          ),
        ],
      ),
    );

    // Create and open the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Align(
          alignment: Alignment.center,
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TFC_Card(
                  width: AxisSize.tu(11),
                  height: AxisSize.shrinkToFitContents(),
                  childToBoxSpacing: childToBoxSpacing,
                  childToChildSpacingVertical: childToChildSpacingVertical,
                  children: children,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showLoadingDialog(BuildContext context, String loadingMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(TFC_AppStyle.instance.pageMargins),
            height: 7 * TFC_AppStyle.instance.lineHeight,
            child: Column(
              children: [
                Container(
                  height: 1.75 * TFC_AppStyle.instance.lineHeight,
                  child: TFC_Text.body(loadingMessage),
                ),
                Container(
                  height: 3.0 * TFC_AppStyle.instance.lineHeight,
                  width: 3.0 * TFC_AppStyle.instance.lineHeight,
                  child: CircularProgressIndicator(
                    backgroundColor: TFC_AppStyle.colorPrimary,
                    strokeWidth: TFC_AppStyle.instance.pageMargins / 4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
