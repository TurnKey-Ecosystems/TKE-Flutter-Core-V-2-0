import 'dart:math';
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
  final String debugName;
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
    this.debugName = "",
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
        const TFC_TouchInteractionConfig.notInteractable(),
      this.debugName = "";

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
      if (widget.width.isScrollable) {
        maxChildWidth = double.infinity;
      } else if (widget.width.size_fu != null && widget.width.size_fu! > 0 && widget.width.size_fu! < constraints.maxWidth) {
        maxChildWidth = widget.width.size_fu!;
      }
      double maxChildHeight = constraints.maxHeight;
      if (widget.height.isScrollable) {
        maxChildHeight = double.infinity;
      } else if (widget.height.size_fu != null && widget.height.size_fu! > 0 && widget.height.size_fu! < constraints.maxHeight) {
        maxChildHeight = widget.height.size_fu!;
      }
      BoxConstraints childConstraints = BoxConstraints(
        minWidth: min(constraints.minWidth, maxChildWidth),
        maxWidth: maxChildWidth,
        minHeight: min(constraints.minHeight, maxChildHeight),
        maxHeight: maxChildHeight,
      );

      // Wrap children in constraints
      for (int i = 0; i < children.length; i ++) {
        children[i] = ConstrainedBox(
          constraints: childConstraints,
          child: children[i],
        );
      }

      // Detrimine if we need to use an alternate child structure for some reason
      bool shouldUseRowForAlignment = false;
      bool shouldUseColumnForAlignment = false;
      if (children.length == 1) {
        if (widget.width.size_tu != null && widget.height.size_tu == null) {
          shouldUseRowForAlignment = true;
        } else if (widget.width.size_tu == null && widget.height.size_tu != null) {
          shouldUseColumnForAlignment = true;
        }
      }

      // Determine what structure to use for the children
      Widget? newWidget;
      debugPrint("${widget.debugName} - child count: ${children.length}.");
      if (children.length == 0) {
        newWidget = null;
        debugPrint("${widget.debugName} - used null.");
      } else if (children.length == 1 && !shouldUseRowForAlignment && !shouldUseColumnForAlignment) {
        newWidget = children[0];
        debugPrint("${widget.debugName} - used child.");
      } else {
        TFC_Axis mainAxis = widget.mainAxis;
        
        if (shouldUseRowForAlignment) {
          mainAxis = TFC_Axis.HORIZONTAL;
        } else if (shouldUseColumnForAlignment) {
          mainAxis = TFC_Axis.VERTICAL;
        }

        switch(mainAxis) {
          case TFC_Axis.HORIZONTAL:
          newWidget = Row(
            mainAxisSize: widget.width.axisSize,
            mainAxisAlignment: 
              widget.childToChildSpacingHorizontal.axisAlignment
              ?? TFC_ChildToBoxSpacing.tfcAlignToMainAxisAlignment(
                  widget.childToBoxSpacing.horizontalAlignment,
                ),
            crossAxisAlignment: TFC_ChildToBoxSpacing.tfcAlignToCrossAxisAlignment(
              widget.childToBoxSpacing.verticalAlignment,
            ),
            children: children,
          );
          debugPrint("${widget.debugName} - used row.");
          break;
          case TFC_Axis.VERTICAL:
          newWidget = Column(
            mainAxisSize: widget.width.axisSize,
            mainAxisAlignment: 
              widget.childToChildSpacingVertical.axisAlignment
              ?? TFC_ChildToBoxSpacing.tfcAlignToMainAxisAlignment(
                  widget.childToBoxSpacing.verticalAlignment,
                ),
            crossAxisAlignment: TFC_ChildToBoxSpacing.tfcAlignToCrossAxisAlignment(
              widget.childToBoxSpacing.horizontalAlignment,
            ),
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          );
          debugPrint("${widget.debugName} - used column.");
          break;
          case TFC_Axis.Z_AXIS:
          newWidget = Stack(
            children: children,
          );
          break;
        }
      }

      // Setup child-to-box alingment
      if (
        newWidget != null
        && widget.width.size_tu != null
        && widget.height.size_tu != null
      ) {
        newWidget = Align(
          alignment: widget.childToBoxSpacing.flutterAlignment,
          child: newWidget,
        );
        debugPrint("${widget.debugName} - used Align!.");
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
      debugPrint("${widget.debugName} - childConstraints: ${childConstraints.toString()}");

      // Finally, return the new widget
      return newWidget;
    });
  }
}