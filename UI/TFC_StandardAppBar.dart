import 'package:flutter/material.dart';
import 'TFC_AppStyle.dart';
import 'TFC_CustomWidgets.dart';

class TFC_StandardAppBar extends StatelessWidget {
  final String _titleText;

  TFC_StandardAppBar(this._titleText, { Key? key }) : super(key: key);

  @override
  PreferredSize build(BuildContext context) {
    double preferredHeight = 2.5 * TFC_AppStyle.instance.lineHeight;

    return PreferredSize(
      preferredSize: Size.fromHeight(preferredHeight),
      child: AppBar(
        backgroundColor: TFC_AppStyle.colorPrimary,
        flexibleSpace: Container(
          height: preferredHeight,
          alignment: Alignment.center,
          child: TFC_Text.subheading(
            _titleText,
            color: TFC_AppStyle.COLOR_BACKGROUND,
          ),
        ),
      ),
    );
  }
}
