/*import '../Utilities/TFC_KeyedMapWithDefaultValue.dart';
import '../DataStructures/TFC_Attribute.dart';
import '../UI/TFC_CustomWidgets.dart';
import '../UI/TFC_InputFields.dart';
import '../UI/TFC_ReloadableWidget.dart';
import 'package:flutter/material.dart';
import 'TFC_AppStyle.dart';

class TFC_EditableTitle extends TFC_ReloadableWidget {
  static late int _lastEditableTitleID = 0;
  late final TFC_AttributeString _sourceAttribute;
  //final Key _key;
  late final String _hintText;
  late final IconData _blankButtonIconData;
  late final String _blankButtonText;
  late final Color _blankButtonTextColor;
  late final Color _blankButtonBackgroundColor;
  late final int _maxLength;
  late final int _maxDisplayLength;
  late final bool _isMutliline;
  late final TFC_TextType _textType;
  late final TextCapitalization _textCapitalization;
  late final double _height;
  late final double _width;
  late final Key keyB;
  late TFC_TextField _textField;

  static TFC_KeyedMapWithDefaultValue<bool>
      _shouldAllowDescriptionEditingByKey = TFC_KeyedMapWithDefaultValue(false);

  late TFC_ReferenceToKeyedMapValue _shouldAllowDescriptionEditing;

  TFC_EditableTitle(
    this._sourceAttribute, {
    String hintText = "Enter Title",
    IconData blankButtonIconData = Icons.add,
    String blankButtonText = "Add Title",
    Color blankButtonTextColor = TFC_AppStyle.COLOR_BLACK,
    Color blankButtonBackgroundColor = TFC_AppStyle.COLOR_BACKGROUND,
    int maxLength = 128,
    int maxDisplayLength = 128,
    bool isMutliline = false,
    TFC_TextType textType = TFC_TextType.TITLE,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    double height = 0,
    double width = 0,
    required Key keyA,
  })  : _hintText = hintText,
        _blankButtonIconData = blankButtonIconData,
        _blankButtonText = blankButtonText,
        _blankButtonTextColor = blankButtonTextColor,
        _blankButtonBackgroundColor = blankButtonBackgroundColor,
        _maxLength = maxLength,
        _maxDisplayLength = maxDisplayLength,
        _isMutliline = isMutliline,
        _textType = textType,
        _textCapitalization = textCapitalization,
        _height =
            (height != 0) ? height : 2.5 * TFC_AppStyle.instance.lineHeight,
        _width = (width != 0) ? width : TFC_AppStyle.instance.internalPageWidth,
        keyB = keyA;

  @override
  Widget buildWidget(BuildContext context) {
    _shouldAllowDescriptionEditing =
        TFC_ReferenceToKeyedMapValue(keyB, _shouldAllowDescriptionEditingByKey);
    if (!_shouldAllowDescriptionEditing.value &&
        (_sourceAttribute.value == null || _sourceAttribute.value == "")) {
      return _getBlankTitle();
    } else {
      return Container(
        alignment: Alignment.bottomLeft,
        height: (_isMutliline) ? null : _height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _getTextFieldArea(),
            _getEditingToggleButton(),
          ],
        ),
      );
    }
  }

  Widget _getTextFieldArea() {
    _textField = TFC_TextField.fromStringAttribute(
      source: _sourceAttribute,
      hintText: _hintText,
      textCapitalization: _textCapitalization,
      style: TFC_AppStyle.instance.textStyle[_textType]!,
      textAlign: TextAlign.left,
      maxLength: _maxLength,
      maxLines: (_isMutliline) ? null : 1,
      nonDefaultValueColor: TFC_AppStyle.textColors[_textType]!,
      focusedInputBorderColor: Colors.transparent,
      unfocusedBlankInputBorderColor: Colors.transparent,
      unfocusedNonblankInputBorderColor: Colors.transparent,
      bshouldStartWithFocus: _shouldAllowDescriptionEditing.value,
      key: keyB,
      onSubmitted: () {
        swapOutOfEditingMode();
      },
      onFocused: () {
        _shouldAllowDescriptionEditing.value = true;
        reload();
      },
    );
    return Container(
      width: 0.85 * _width,
      alignment: Alignment.bottomLeft,
      child: _textField,
    );
  }

  Widget _getEditingToggleButton() {
    Map<bool, IconData> buttonIconData = {true: Icons.done, false: Icons.edit};

    return Container(
      width: 0.15 * _width,
      child: FlatButton(
        color: TFC_AppStyle.COLOR_BACKGROUND,
        child: Icon(
          buttonIconData[_shouldAllowDescriptionEditing.value],
          color: TFC_AppStyle.textColors[_textType],
        ),
        onPressed: () {
          if (_shouldAllowDescriptionEditing.value) {
            swapOutOfEditingMode();
          } else {
            swapToEditingMode();
          }
        },
      ),
    );
  }

  Widget _getBlankTitle() {
    return Container(
      alignment: Alignment.centerLeft,
      height: _height,
      child: GestureDetector(
        child: Container(
          width: _width,
          height: _height,
          color: _blankButtonBackgroundColor,
          alignment: Alignment.bottomLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                height: _height,
                alignment: Alignment.bottomLeft,
                child: Container(
                  width: 0.07 * _width,
                  height: getBlankButtonHeight(_height),
                  alignment: Alignment.centerLeft,
                  child: Icon(
                    _blankButtonIconData,
                    color: _blankButtonTextColor,
                  ),
                ),
              ),
              Container(
                height: _height,
                alignment: Alignment.bottomLeft,
                child: Container(
                  width: 0.75 * _width,
                  height: getBlankButtonHeight(_height),
                  alignment: Alignment.centerLeft,
                  child: TFC_Text(
                    " " + _blankButtonText,
                    _textType,
                    color: _blankButtonTextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          _shouldAllowDescriptionEditing.value = true;
          if (reload != null) {
            reload();
          }
        },
      ),
    );
  }

  void swapToEditingMode() {
    _shouldAllowDescriptionEditing.value = true;
    if (_textField != null) {
      _textField.requestFocus();
    }
  }

  void swapOutOfEditingMode() {
    if (_textField != null) {
      _textField.unFocus();
    }
    _shouldAllowDescriptionEditing.value = false;
    if ((_sourceAttribute.value == null && _sourceAttribute.value == "") &&
        reload != null) {
      reload();
    }
  }

  static double getBlankButtonHeight(double height) {
    return 0.75 * height;
  }
}

class _TFC_EditableTitleButton extends StatefulWidget {
  late void Function(bool) reload;

  @override
  _TFC_EditableTitleButtonState createState() =>
      _TFC_EditableTitleButtonState();
}

class _TFC_EditableTitleButtonState extends State<_TFC_EditableTitleButton> {
  bool isInEditMode;
  double width;
  TFC_TextType textType;
  void Function() swapOutOfEditingMode;
  void Function() swapToEditingMode;

  _TFC_EditableTitleButtonState({
      this.width = 0.5,
      this.isInEditMode,
      this.textType,
      this.swapOutOfEditingMode,
      this.swapToEditingMode}) {
    widget.reload = (bool newIsInEditingMode) {
      setState(() {
        isInEditMode = newIsInEditingMode;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    Map<bool, IconData> buttonIconDataFromIsInEditMode = {
      false: Icons.edit,
      true: Icons.done,
    };

    return Container(
      width: 0.15 * width,
      child: FlatButton(
        color: TFC_AppStyle.COLOR_BACKGROUND,
        child: Icon(
          buttonIconDataFromIsInEditMode[isInEditMode],
          color: TFC_AppStyle.textColors[textType],
        ),
        onPressed: () {
          if (isInEditMode) {
            swapOutOfEditingMode();
          } else {
            swapToEditingMode();
          }
        },
      ),
    );
  }
}*/
