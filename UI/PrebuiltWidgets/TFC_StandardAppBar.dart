import 'package:flutter/material.dart';
import '../FoundationalElements/TFC_AppStyle.dart';
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
        foregroundColor: TFC_AppStyle.COLOR_BACKGROUND,
        backgroundColor: TFC_AppStyle.colorPrimary,
        iconTheme: IconThemeData(
          color: TFC_AppStyle.COLOR_BACKGROUND,
        ),
        flexibleSpace: Container(
          height: preferredHeight,
          alignment: Alignment.center,
          child: TFC_Text.subheading(
            () => _titleText,
            color: TFC_AppStyle.COLOR_BACKGROUND,
          ),
        ),
      ),
    );
  }
}
