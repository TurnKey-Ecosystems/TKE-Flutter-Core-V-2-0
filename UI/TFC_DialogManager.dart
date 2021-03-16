import 'package:flutter/material.dart';
import '../Utilities/TFC_Utilities.dart';
import 'TFC_AppStyle.dart';
import 'TFC_CustomWidgets.dart';

class TFC_DialogManager {
  static void showYesNoDialog({
    @required BuildContext context,
    @required String description,
    void Function() onYes,
    void Function() onNo,
  }) {
    showTwoButtonDialog(
      context: context,
      content: TFC_Text.body(
        description,
        color: TFC_AppStyle.COLOR_TEXT_HEADING,
      ),
      button1Text: "Yes",
      onButton1: onYes,
      button2Text: "No",
      onButton2: onNo,
    );
  }

  static void showTwoButtonDialog({
    @required BuildContext context,
    @required Widget content,
    @required String button1Text,
    void Function() onButton1,
    @required String button2Text,
    void Function() onButton2,
  }) {
    Widget dialog = SimpleDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
            Radius.circular(0.25 * TFC_AppStyle.instance.pageMargins)),
      ),
      backgroundColor: TFC_AppStyle.COLOR_BACKGROUND,
      contentPadding: EdgeInsets.all(0.75 * TFC_AppStyle.instance.pageMargins),
      children: [
        content,
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FlatButton(
              child: TFC_Text.body(
                button1Text,
                color: TFC_AppStyle.colorPrimary,
              ),
              color: TFC_AppStyle.COLOR_BACKGROUND,
              hoverColor: TFC_Utilities.blendColors(
                  TFC_AppStyle.colorPrimary, TFC_AppStyle.COLOR_BACKGROUND,
                  color1Weight: 0.125),
              highlightColor: TFC_Utilities.blendColors(
                  TFC_AppStyle.colorPrimary, TFC_AppStyle.COLOR_BACKGROUND,
                  color1Weight: 0.25),
              splashColor: TFC_Utilities.blendColors(
                  TFC_AppStyle.colorPrimary, TFC_AppStyle.COLOR_BACKGROUND,
                  color1Weight: 0.25),
              onPressed: () {
                if (onButton1 != null) {
                  onButton1();
                }
              },
            ),
            Container(
              width: 0.125 * TFC_AppStyle.instance.pageMargins,
            ),
            FlatButton(
              child: TFC_Text.body(
                button2Text,
                color: TFC_AppStyle.colorPrimary,
              ),
              color: TFC_AppStyle.COLOR_BACKGROUND,
              hoverColor: TFC_Utilities.blendColors(
                  TFC_AppStyle.colorPrimary, TFC_AppStyle.COLOR_BACKGROUND,
                  color1Weight: 0.125),
              highlightColor: TFC_Utilities.blendColors(
                  TFC_AppStyle.colorPrimary, TFC_AppStyle.COLOR_BACKGROUND,
                  color1Weight: 0.25),
              splashColor: TFC_Utilities.blendColors(
                  TFC_AppStyle.colorPrimary, TFC_AppStyle.COLOR_BACKGROUND,
                  color1Weight: 0.25),
              onPressed: () {
                if (onButton2 != null) {
                  onButton2();
                }
              },
            ),
          ],
        ),
      ],
    );

    showDialog(
      context: context,
      child: dialog,
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
