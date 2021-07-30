//import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../../DataStructures/TFC_Attribute.dart';
import '../FoundationalElements/TFC_AppStyle.dart';
import '../FoundationalElements/TFC_SelfReloadingWidget.dart';
import 'TFC_CustomWidgets.dart';

// TODO: Make email and physical address input fields have input validation
// TODO: Turn the TextField red if the input is not formatted properly.
// TODO: In large numeric input fields, insert a comman(10,000)

class TFC_NumericField extends TFC_InputField {
  final Type? _specficNumType;
  final num defaultValueAsNum;
  final int decimalCount;
  final num Function() getSourceValue;
  final void Function(num) setSourceValue;
  final TFC_BorderType borderType;

  TFC_NumericField({
    required this.getSourceValue,
    required this.setSourceValue,
    required this.defaultValueAsNum,
    Color defaultValueColor = TFC_AppStyle.COLOR_HINT,
    Color nonDefaultValueColor = TFC_AppStyle.COLOR_BLACK,
    bool shouldChangeColorIfNotEqualToDefaultValue = true,
    void Function()? onSubmitted,
    void Function()? onFocused,
    bool shouldSubmitOnFocusLost = true,
    TextAlign textAlign = TextAlign.center,
    TextInputAction textInputAction = TextInputAction.done,
    TextStyle? style,
    bool shouldStartWithFocus = false,
    int maxLength = 10,
    this.decimalCount = 0,
    this.borderType = TFC_BorderType.OUTLINED,
  })  : _specficNumType = null,
        super(
          defaultValue: defaultValueAsNum.toStringAsFixed(decimalCount),
          onSubmitted: onSubmitted,
          onFocused: onFocused,
          shouldSubmitOnFocusLost: shouldSubmitOnFocusLost,
          hintText: defaultValueAsNum.toStringAsFixed(decimalCount),
          textColor: nonDefaultValueColor,
          hintColor: defaultValueColor,
          autocorrect: false,
          textCapitalization: TextCapitalization.none,
          textAlign: textAlign,
          keyboardType: TextInputType.numberWithOptions(
              signed: false, decimal: decimalCount != 0),
          textInputAction: textInputAction,
          givenTextStyle: style,
          shouldStartWithFocus: shouldStartWithFocus,
          maxLength: maxLength,
        );

  TFC_NumericField.fromNumAttribute({
    required TFC_AttributeProperty<num> source,
    Color defaultValueColor = TFC_AppStyle.COLOR_HINT,
    Color nonDefaultValueColor = TFC_AppStyle.COLOR_BLACK,
    bool shouldChangeColorIfNotEqualToDefaultValue = true,
    void Function()? onSubmitted,
    void Function()? onFocused,
    bool shouldSubmitOnFocusLost = true,
    TextAlign textAlign = TextAlign.center,
    TextInputAction textInputAction = TextInputAction.done,
    TextStyle? style,
    bool shouldStartWithFocus = false,
    int maxLength = 10,
    this.decimalCount = 0,
    this.borderType = TFC_BorderType.OUTLINED,
  })  : _specficNumType = null,
        getSourceValue = source.getValue,
        setSourceValue = source.setValue,
        defaultValueAsNum = source.getDefaultValue(),
        super(
          defaultValue: source.getDefaultValue().toStringAsFixed(decimalCount),
          onSubmitted: onSubmitted,
          onFocused: onFocused,
          shouldSubmitOnFocusLost: shouldSubmitOnFocusLost,
          hintText: source.getDefaultValue().toStringAsFixed(decimalCount),
          textColor: nonDefaultValueColor,
          hintColor: defaultValueColor,
          autocorrect: false,
          textCapitalization: TextCapitalization.none,
          textAlign: textAlign,
          keyboardType: TextInputType.numberWithOptions(
              signed: false, decimal: decimalCount != 0),
          textInputAction: textInputAction,
          givenTextStyle: style,
          shouldStartWithFocus: shouldStartWithFocus,
          maxLength: maxLength,
        );

  @override
  String getValueAsString() {
    return getSourceValue().toStringAsFixed(decimalCount);
  }

  @override
  void setValueFromString(String newValueAsString) {
    newValueAsString = newValueAsString.replaceAll(RegExp(r"[^0-9.]"), "");
    num? newValueAsNum = num.tryParse(newValueAsString);
    if (newValueAsString != "" && newValueAsNum != null) {
      if (_specficNumType != null) {
        if (_specficNumType == double) {
          setSourceValue(newValueAsNum.toDouble());
        } else if (_specficNumType == int) {
          setSourceValue(newValueAsNum.toInt());
        } else {
          throw ("TFC_NumericField._specficNumType = ${_specficNumType.toString()}, but TFC_NumericField.setValueFromString() does not handle this type.");
        }
      } else {
        setSourceValue(newValueAsNum);
      }
    } else {
      setSourceValue(defaultValueAsNum);
    }
  }

  @override
  InputBorder getInputBorder() {
    if (shouldChangeColorIfNotEqualToDefaultValue &&
        getSourceValue() == defaultValueAsNum) {
      return TFC_InputBorder.fromBorderType(
          borderType: borderType, color: defaultValueColor);
    } else {
      return TFC_InputBorder.fromBorderType(
          borderType: borderType, color: nonDefaultValueColor);
    }
  }

  @override
  InputBorder getFocusedInputBorder() {
    return TFC_InputBorder.fromBorderType(
        borderType: borderType, color: Colors.transparent);
  }
}

class TFC_TextField extends TFC_InputField {
  final String Function() getSourceValue;
  final void Function(String) setSourceValue;
  final Color _focusedInputBorderColor;
  final Color _unfocusedBlankInputBorderColor;
  final Color _unfocusedNonblankInputBorderColor;
  final TFC_BorderType borderType;

  TFC_TextField({
    required this.getSourceValue,
    required this.setSourceValue,
    void Function()? onSubmitted,
    void Function()? onFocused,
    bool shouldSubmitOnFocusLost = true,
    Icon? icon,
    String? hintText,
    Color nonDefaultValueColor = TFC_AppStyle.COLOR_TEXT_BODY,
    Color defaultValueColor = TFC_AppStyle.COLOR_HINT,
    Color? focusedInputBorderColor,
    Color? unfocusedBlankInputBorderColor,
    Color? unfocusedNonblankInputBorderColor,
    bool autocorrect = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextAlign textAlign = TextAlign.left,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.done,
    TextStyle? style,
    String? labelText,
    String? helperText,
    bool shouldStartWithFocus = false,
    int maxLength = 256,
    int maxLines = 1,
    Key? key,
    this.borderType = TFC_BorderType.UNDERLINED,
  })  : _focusedInputBorderColor = (focusedInputBorderColor != null)
            ? focusedInputBorderColor
            : Colors.transparent,
        _unfocusedBlankInputBorderColor =
            (unfocusedBlankInputBorderColor != null)
                ? unfocusedBlankInputBorderColor
                : nonDefaultValueColor,
        _unfocusedNonblankInputBorderColor =
            (unfocusedNonblankInputBorderColor != null)
                ? unfocusedNonblankInputBorderColor
                : defaultValueColor,
        super(
          onSubmitted: onSubmitted,
          onFocused: onFocused,
          shouldSubmitOnFocusLost: shouldSubmitOnFocusLost,
          icon: icon,
          hintText: hintText,
          textColor: (nonDefaultValueColor != null)
              ? nonDefaultValueColor
              : (style != null)
                  ? style.color!
                  : TFC_AppStyle.instance.textStyleBody.color!,
          hintColor: defaultValueColor,
          autocorrect: autocorrect,
          textCapitalization: textCapitalization,
          textAlign: textAlign,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          givenTextStyle: style,
          labelText: labelText,
          helperText: helperText,
          shouldStartWithFocus: shouldStartWithFocus,
          maxLength: maxLength,
          maxLines: maxLines,
          onBeforeBuild: (BuildContext context) {},
          key: key,
        );

  TFC_TextField.fromStringAttribute({
    required TFC_AttributeString source,
    void Function()? onSubmitted,
    void Function()? onFocused,
    bool shouldSubmitOnFocusLost = true,
    Icon? icon,
    String? hintText,
    Color nonDefaultValueColor = TFC_AppStyle.COLOR_TEXT_BODY,
    Color defaultValueColor = TFC_AppStyle.COLOR_HINT,
    Color? focusedInputBorderColor,
    Color? unfocusedBlankInputBorderColor,
    Color? unfocusedNonblankInputBorderColor,
    bool autocorrect = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextAlign textAlign = TextAlign.left,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.done,
    TextStyle? style,
    String? labelText,
    String? helperText,
    bool bshouldStartWithFocus = false,
    int maxLength = 256,
    int? maxLines = 1,
    Key? key,
    this.borderType = TFC_BorderType.UNDERLINED,
  })  : getSourceValue = source.getValue,
        setSourceValue = source.setValue,
        _focusedInputBorderColor = (focusedInputBorderColor != null)
            ? focusedInputBorderColor
            : Colors.transparent,
        _unfocusedBlankInputBorderColor =
            (unfocusedBlankInputBorderColor != null)
                ? unfocusedBlankInputBorderColor
                : nonDefaultValueColor,
        _unfocusedNonblankInputBorderColor =
            (unfocusedNonblankInputBorderColor != null)
                ? unfocusedNonblankInputBorderColor
                : defaultValueColor,
        super(
          onSubmitted: onSubmitted,
          onFocused: onFocused,
          shouldSubmitOnFocusLost: shouldSubmitOnFocusLost,
          icon: icon,
          hintText: hintText,
          textColor: (nonDefaultValueColor != null)
              ? nonDefaultValueColor
              : (style != null)
                  ? style.color!
                  : TFC_AppStyle.instance.textStyleBody.color!,
          hintColor: defaultValueColor,
          autocorrect: autocorrect,
          textCapitalization: textCapitalization,
          textAlign: textAlign,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          givenTextStyle: style,
          labelText: labelText,
          helperText: helperText,
          shouldStartWithFocus: bshouldStartWithFocus,
          maxLength: maxLength,
          maxLines: maxLines,
          onBeforeBuild: (BuildContext context) {},
          key: key,
        );

  @override
  String getValueAsString() {
    return getSourceValue();
  }

  @override
  void setValueFromString(String newValue) {
    setSourceValue(newValue);
  }

  @override
  InputBorder getInputBorder() {
    InputBorder inputBorder;

    if (getSourceValue() == "") {
      inputBorder = TFC_InputBorder.fromBorderType(
          borderType: borderType, color: _unfocusedBlankInputBorderColor);
    } else {
      inputBorder = TFC_InputBorder.fromBorderType(
          borderType: borderType, color: _unfocusedNonblankInputBorderColor);
    }

    return inputBorder;
  }

  @override
  InputBorder getFocusedInputBorder() {
    return TFC_InputBorder.fromBorderType(
        borderType: borderType, color: _focusedInputBorderColor);
  }
}

abstract class TFC_InputField extends TFC_SelfReloadingWidget {
  static FocusNode? _focus;
  static FocusNode? get focus {
    return _focus;
  }
  static void setFocusVar(FocusNode newFocusNode) {
    _focus = newFocusNode;
  }

  final String? defaultValue;
  final void Function()? onSubmitted;
  final void Function()? onFocused;
  final bool shouldSubmitOnFocusLost;
  final Icon? icon;
  final String? hintText;
  final Color textColor;
  final Color hintColor;
  final bool autocorrect;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final TextAlignVertical textAlignVertical;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextStyle style;
  final String? labelText;
  final String? helperText;
  final Color nonDefaultValueColor;
  final Color defaultValueColor;
  final bool shouldChangeColorIfNotEqualToDefaultValue;
  /* This is a bool, but for whatever reason, if we put bool instead of dynamic,
   despite this being final, between initialization and build, dart will change 
   the value to false. */
  final dynamic shouldStartWithFocus;
  final int? maxLength;
  final int? maxLines;
  final void Function(BuildContext)? onBeforeBuild;
  final TextEditingController _controller;
  //final FocusNode _focusNode;
  InputBorder getInputBorder();
  InputBorder getFocusedInputBorder();
  String getValueAsString();
  void setValueFromString(String newValue);
  final Key inputKey;

  TFC_InputField({
    this.defaultValue,
    this.onSubmitted,
    this.onFocused,
    this.shouldSubmitOnFocusLost = true,
    this.icon,
    this.hintText,
    this.textColor = TFC_AppStyle.COLOR_BLACK,
    this.hintColor = TFC_AppStyle.COLOR_HINT,
    this.autocorrect = false,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.left,
    this.textAlignVertical = TextAlignVertical.center,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    TextStyle? givenTextStyle,
    this.labelText,
    this.helperText,
    this.nonDefaultValueColor = TFC_AppStyle.COLOR_BLACK,
    this.defaultValueColor = TFC_AppStyle.COLOR_HINT,
    this.shouldChangeColorIfNotEqualToDefaultValue = false,
    this.shouldStartWithFocus = true,
    this.maxLength,
    this.maxLines = 1,
    this.onBeforeBuild,
    Key? key,
  })  : _focusNode = FocusNode(),
        _controller = TextEditingController(),
        inputKey = Key(key.toString() + "inputKey"),
        style = (givenTextStyle != null)
            ? givenTextStyle
            : TFC_AppStyle.instance.textStyleBody,
        super(reloadTriggers: []) {
    // Apply any external changes to the value
    if (defaultValue != null && getValueAsString() == defaultValue) {
      _controller.text = "";
    } else {
      _controller.text = getValueAsString();
    }
    //_controller.addListener(applyTextChangesToValue);
    _focusNode.addListener(focusChanged);
  }

  void requestFocus() {
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
  }

  void unFocus() {
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
    }
  }

  final FocusNode _focusNode;
  /*FocusNode get _focusNode {
    return getFocusNode(key);
  }*/

  static Map<Key, FocusNode> focusNodesByKey = Map();
  static FocusNode? getFocusNode(Key key) {
    if (!focusNodesByKey.containsKey(key)) {
      focusNodesByKey[key] = FocusNode();
    }
    return focusNodesByKey[key];
  }

  void focusChanged() {
    if (_focusNode.hasFocus) {
      // On focus gained
      if (_focus != null && _focus != _focusNode && _focus!.hasFocus) {
        _focus!.unfocus();
      }
      _focus = _focusNode;
      if (onFocused != null) {
        onFocused!();
      }
    } else {
      // On focus lost
      if (_focus == _focusNode) {
        _focus = null;
      }
      if (reload != null) {
        reload();
      }
      if (shouldSubmitOnFocusLost && onSubmitted != null) {
        onSubmitted!();
      }
    }
  }

  void applyTextChangesToValue() {
    setValueFromString(_controller.text);
  }

  @override
  Widget buildWidget(BuildContext context) {
    if (onBeforeBuild != null) {
      onBeforeBuild!(context);
    }

    if (!_focusNode.hasFocus) {
      _controller.text = getValueAsString();
    }

    TextField textField = TextField(
      focusNode: _focusNode,
      onSubmitted: (shouldSubmitOnFocusLost)
          ? null
          : (String text) {
              if (onSubmitted != null) {
                onSubmitted!();
              }
            },
      autofocus: shouldStartWithFocus,
      autocorrect: autocorrect,
      textCapitalization: textCapitalization,
      textAlign: textAlign,
      textAlignVertical: textAlignVertical,
      controller: _controller,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      keyboardAppearance: Brightness.light,
      style: style.apply(color: textColor),
      maxLength: maxLength,
      onChanged: (String newValue) {
        applyTextChangesToValue();
      }, //setValueFromString,
      //expands: true,
      maxLines: maxLines,
      cursorColor: TFC_AppStyle.COLOR_HINT,
      //key: inputKey,
      decoration: InputDecoration(
        //prefixIcon: icon,
        contentPadding: EdgeInsets.all(0.0),
        hintText: hintText,
        hintStyle: style.apply(color: hintColor),
        labelText: labelText,
        labelStyle: style.apply(color: hintColor),
        helperText: helperText,
        border: getInputBorder(),
        enabledBorder: getInputBorder(),
        focusedBorder: getFocusedInputBorder(),
        counterText: "",
      ),
      key: key,
    );

    return textField;

    /*if (icon != null) {
      return Row(
        children: [
          icon,
          textField,
        ],
      );
    } else {
      return textField;
    }*/
  }

  static void unFocusActiveInputField() {
    if (_focus != null && _focus!.hasFocus) {
      _focus!.unfocus();
    }
  }
}

/*

abstract class TFC_InputField extends StatefulWidget {
  static FocusNode _focus;
  static FocusNode get focus {
    return _focus;
  }

  final String defaultValue;
  final void Function() onSubmitted;
  final void Function() onFocused;
  final bool shouldSubmitOnFocusLost;
  final Icon icon;
  final String hintText;
  final Color textColor;
  final Color hintColor;
  final bool autocorrect;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final TextAlignVertical textAlignVertical;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextStyle style;
  final String labelText;
  final String helperText;
  final Color nonDefaultValueColor;
  final Color defaultValueColor;
  final bool shouldChangeColorIfNotEqualToDefaultValue;
  /* This is a bool, but for whatever reason, if we put bool instead of dynamic,
   despite this being final, between initialization and build, dart will change 
   the value to false. */
  final dynamic shouldStartWithFocus;
  final int maxLength;
  final int maxLines;
  final void Function(BuildContext) onBeforeBuild;
  final TextEditingController _controller;
  //final FocusNode _focusNode;
  final Key inputKey;
  InputBorder getInputBorder();
  InputBorder getFocusedInputBorder();
  String getValueAsString();
  void setValueFromString(String newValue);

  TFC_InputField({
    this.defaultValue,
    this.onSubmitted,
    this.onFocused,
    this.shouldSubmitOnFocusLost = true,
    this.icon,
    this.hintText,
    this.textColor = TFC_AppStyle.COLOR_BLACK,
    this.hintColor = TFC_AppStyle.COLOR_HINT,
    this.autocorrect = false,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.left,
    this.textAlignVertical = TextAlignVertical.center,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    TextStyle givenTextStyle,
    this.labelText,
    this.helperText,
    this.nonDefaultValueColor = TFC_AppStyle.COLOR_BLACK,
    this.defaultValueColor = TFC_AppStyle.COLOR_HINT,
    this.shouldChangeColorIfNotEqualToDefaultValue = false,
    this.shouldStartWithFocus = true,
    this.maxLength,
    this.maxLines = 1,
    this.onBeforeBuild,
    Key? key,
  })  : _focusNode = FocusNode(),
        _controller = TextEditingController(),
        inputKey = Key(key.toString() + "inputKey"),
        style = (givenTextStyle != null)
            ? givenTextStyle
            : TFC_AppStyle.instance.textStyleBody,
        super(key: key) {
    // Apply any external changes to the value
    if (defaultValue != null && getValueAsString() == defaultValue) {
      _controller.text = "";
    } else {
      _controller.text = getValueAsString();
    }
    //_controller.addListener(applyTextChangesToValue);
    _focusNode.addListener(focusChanged);
  }

  final FocusNode _focusNode;
  /*FocusNode get _focusNode {
    return getFocusNode(key);
  }*/

  static Map<Key, FocusNode> focusNodesByKey = Map();
  static FocusNode getFocusNode(Key key) {
    if (!focusNodesByKey.containsKey(key)) {
      focusNodesByKey[key] = FocusNode();
    }
    return focusNodesByKey[key];
  }

  @override
  _TFC_InputFieldState createState() => _TFC_InputFieldState();

  static void unFocusActiveInputField() {
    if (_focus != null && _focus.hasFocus) {
      _focus.unfocus();
    }
  }

  void focusChanged() {
    if (_focusNode.hasFocus) {
      // On focus gained
      if (TFC_InputField._focus != null &&
          TFC_InputField._focus != _focusNode &&
          TFC_InputField._focus.hasFocus) {
        TFC_InputField._focus.unfocus();
      }
      TFC_InputField._focus = _focusNode;
      if (onFocused != null) {
        onFocused();
      }
    } else {
      // On focus lost
      if (TFC_InputField._focus == _focusNode) {
        TFC_InputField._focus = null;
      }
      /*if (reload != null) {
        reload();
      }*/
      if (shouldSubmitOnFocusLost && onSubmitted != null) {
        onSubmitted();
      }
    }
  }

  void requestFocus() {
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
  }

  void unFocus() {
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
    }
  }
}

class _TFC_InputFieldState extends State<TFC_InputField> {
  void applyTextChangesToValue() {
    widget.setValueFromString(widget._controller.text);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onBeforeBuild != null) {
      widget.onBeforeBuild(context);
    }

    return TextField(
      focusNode: widget._focusNode,
      onSubmitted: (widget.shouldSubmitOnFocusLost)
          ? null
          : (String text) {
              if (widget.onSubmitted != null) {
                widget.onSubmitted();
              }
            },
      autofocus: widget.shouldStartWithFocus,
      autocorrect: widget.autocorrect,
      textCapitalization: widget.textCapitalization,
      textAlign: widget.textAlign,
      textAlignVertical: widget.textAlignVertical,
      controller: widget._controller,
      textInputAction: widget.textInputAction,
      keyboardType: widget.keyboardType,
      keyboardAppearance: Brightness.light,
      style: widget.style.apply(color: widget.textColor),
      maxLength: widget.maxLength,
      onChanged: (String newValue) {
        applyTextChangesToValue();
      }, //setValueFromString,
      //expands: true,
      maxLines: widget.maxLines,
      cursorColor: TFC_AppStyle.COLOR_HINT,
      //key: inputKey,
      decoration: InputDecoration(
        icon: widget.icon,
        contentPadding: EdgeInsets.all(0.0),
        hintText: widget.hintText,
        hintStyle: widget.style.apply(color: widget.hintColor),
        labelText: widget.labelText,
        labelStyle: widget.style.apply(color: widget.hintColor),
        helperText: widget.helperText,
        border: widget.getInputBorder(),
        enabledBorder: widget.getInputBorder(),
        focusedBorder: widget.getFocusedInputBorder(),
        counterText: "",
      ),
      //key: widget.key,
    );
  }
}
*/
