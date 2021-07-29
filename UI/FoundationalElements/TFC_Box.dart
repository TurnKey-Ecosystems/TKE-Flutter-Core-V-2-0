import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../ConfigurationTypes/TFC_BoxDecoration.dart';
import '../ConfigurationTypes/TFC_ChildToChildSpacing.dart';
import '../ConfigurationTypes/TFC_AxisSize.dart';
import '../ConfigurationTypes/TFC_ChildToBoxSpacing.dart';
import '../ConfigurationTypes/TFC_TouchInteractionConfig.dart';
import './TU.dart';

enum TFC_Axis { HORIZONTAL, VERTICAL, Z_AXIS }

class TFC_Box extends StatefulWidget {
  final TFC_AxisSize width;
  final TFC_AxisSize height;
  final List<Widget> children;
  final TFC_Axis mainAxis;
  final TFC_ChildToBoxSpacing childToBoxSpacing;
  final TFC_ChildToChildSpacing childToChildSpacingHorizontal;
  final TFC_ChildToChildSpacing childToChildSpacingVertical;
  final TFC_BoxDecoration boxDecoration;
  final TFC_TouchInteractionConfig touchInteractionConfig;
  bool get shouldPadInbetweenContents {
    switch(mainAxis) {
      case TFC_Axis.HORIZONTAL:
        return childToChildSpacingHorizontal.uniformPadding_tu != null;
      case TFC_Axis.VERTICAL:
        return childToChildSpacingVertical.uniformPadding_tu != null;
      case TFC_Axis.Z_AXIS:
        return false;
    }
  }

  @mustCallSuper
  const TFC_Box({
    required this.width,
    required this.height,
    this.children = const [],
    this.mainAxis = TFC_Axis.VERTICAL,
    this.childToBoxSpacing =
      const TFC_ChildToBoxSpacing.center(),
    this.childToChildSpacingHorizontal =
      const TFC_ChildToChildSpacing.noPadding(),
    this.childToChildSpacingVertical =
      const TFC_ChildToChildSpacing.noPadding(),
    this.boxDecoration =
      const TFC_BoxDecoration.undecorated(),
    this.touchInteractionConfig =
      const TFC_TouchInteractionConfig.notInteractable(),
  });

  const TFC_Box.empty()
    : this.width =
        const TFC_AxisSize.shrinkToFitContents(),
      this.height =
        const TFC_AxisSize.shrinkToFitContents(),
      this.childToBoxSpacing =
        const TFC_ChildToBoxSpacing.center(),
      this.mainAxis = TFC_Axis.VERTICAL,
      this.childToChildSpacingHorizontal =
        const TFC_ChildToChildSpacing.noPadding(),
      this.childToChildSpacingVertical =
        const TFC_ChildToChildSpacing.noPadding(),
      this.children = const [],
      this.boxDecoration =
        const TFC_BoxDecoration.undecorated(),
      this.touchInteractionConfig =
        const TFC_TouchInteractionConfig.notInteractable();

  _TFC_BoxState createState() {
    return _TFC_BoxState();
  }
}

class _TFC_BoxState extends State<TFC_Box> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {

      // Decide whether or not to add uniform padding between children
      bool shouldPadBetweenChildren;
      switch(widget.mainAxis) {
        case TFC_Axis.HORIZONTAL:
          shouldPadBetweenChildren = widget.childToChildSpacingHorizontal.uniformPadding_tu != null;
          break;
        case TFC_Axis.VERTICAL:
          shouldPadBetweenChildren = widget.childToChildSpacingVertical.uniformPadding_tu != null;
          break;
        case TFC_Axis.Z_AXIS:
          shouldPadBetweenChildren = false;
          break;
      }

      // When applicable add uniform padding between children
      List<Widget> children = [];
      for (int i = 0; i < widget.children.length; i++) {
        if (shouldPadBetweenChildren && i > 0) {
          children.add(
            SizedBox(
              width: (widget.childToChildSpacingHorizontal.uniformPadding_tu != null)
                ? TU.toFU(widget.childToChildSpacingHorizontal.uniformPadding_tu!)
                : null,
              height: (widget.childToChildSpacingVertical.uniformPadding_tu != null)
                ? TU.toFU(widget.childToChildSpacingVertical.uniformPadding_tu!)
                : null,
            ),
          );
        }
        children.add(widget.children[i]);
      }

      // Determine the constraints for the children
      double maxChildWidth = constraints.maxWidth;
      if (widget.width.size_fu != null && widget.width.size_fu! > 0 && widget.width.size_fu! < constraints.maxWidth) {
        maxChildWidth = widget.width.size_fu!;
      }
      double maxChildHeight = constraints.maxHeight;
      if (widget.height.size_fu != null && widget.height.size_fu! > 0 && widget.height.size_fu! < constraints.maxHeight) {
        maxChildHeight = widget.height.size_fu!;
      }
      BoxConstraints childConstraints = BoxConstraints(
        minWidth: constraints.minWidth,
        maxWidth: maxChildWidth,
        minHeight: constraints.minHeight,
        maxHeight: maxChildHeight,
      );

      // Wrap children in constraints
      for (int i = 0; i < children.length; i ++) {
        children[i] = ConstrainedBox(
          constraints: childConstraints,
          child: children[i],
        );
      }

      // Determine what structure to use for the children
      Widget? newWidget;
      if (children.length == 0) {
        newWidget = null;
      } else if (children.length == 1) {
        newWidget = children[0];
      } else {
        switch(widget.mainAxis) {
          case TFC_Axis.HORIZONTAL:
          newWidget = Row(
            mainAxisSize: widget.width.axisSize,
            mainAxisAlignment: widget.childToChildSpacingHorizontal.axisAlignment ?? MainAxisAlignment.center,
            children: children,
          );
          break;
          case TFC_Axis.VERTICAL:
          newWidget = Column(
            mainAxisSize: widget.width.axisSize,
            mainAxisAlignment: widget.childToChildSpacingHorizontal.axisAlignment ?? MainAxisAlignment.center,
            children: children,
          );
          break;
          case TFC_Axis.Z_AXIS:
          newWidget = Stack(
            children: children,
          );
          break;
        }
      }

      // Setup child-to-box alingment
      if (newWidget != null) {
        newWidget = Align(
          alignment: widget.childToBoxSpacing.flutterAlignment,
          child: newWidget,
        );
      }

      // Compute and add padding
      EdgeInsetsGeometry? boxPadding =
        widget.childToBoxSpacing.flutterPadding;
      if (boxPadding != null) {
        if (widget.boxDecoration.isOutlined) {
          EdgeInsetsGeometry paddingForOutline = EdgeInsets.all(
            widget.boxDecoration.borderWidth_fu!
          );

          boxPadding.subtract(paddingForOutline);
        }
        newWidget = Padding(
          padding: boxPadding,
          child: newWidget,
        );
      }

      // Add decoration
      if (widget.boxDecoration.isDecorated) {
        newWidget = DecoratedBox(
          decoration: widget.boxDecoration.flutterBoxDecoration!,
          child: newWidget,
        );
      }

      // Add the sized box
      newWidget = SizedBox(
        width: widget.width.size_fu,
        height: widget.height.size_fu,
        child: newWidget,
      );

      // When applicable add gesture detection
      if (widget.touchInteractionConfig.isAnInteractableWidget) {
        newWidget = widget.touchInteractionConfig.ifIntractableWrapInGestureDetector(
          child: Ink(
            child: newWidget,
          ),
        );
      }

      // When applicable, make this box scrollable
      if (widget.width.isScrollable) {
        newWidget = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: newWidget,
        );
      }
      if (widget.height.isScrollable) {
        newWidget = SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: newWidget,
        );
      }

      // Finally, return the new widget
      return newWidget;
    });
  }
}