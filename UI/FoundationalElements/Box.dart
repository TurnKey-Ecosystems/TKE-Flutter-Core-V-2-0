import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../UI/FoundationalElements/TFC_BoxLimitations.dart';
import '../ConfigurationTypes/TFC_BoxDecoration.dart';
import '../ConfigurationTypes/ChildToChildSpacing.dart';
import '../ConfigurationTypes/AxisSize.dart';
import '../ConfigurationTypes/ChildToBoxSpacing.dart';
import '../ConfigurationTypes/TFC_TouchInteractionConfig.dart';
import './TU.dart';

enum Axis3D { HORIZONTAL, VERTICAL, Z_AXIS }

class Box<LimitationType extends TFC_BoxLimitation> extends StatefulWidget {
  static const bool SHOULD_PRINT_DEBUG_LOGS = false;
  final LimitationType? limitationType;
  final AxisSize width;
  final AxisSize height;
  final List<Widget?> children;
  final Axis3D mainAxis;
  final ChildToBoxSpacing childToBoxSpacing;
  final ChildToChildSpacing childToChildSpacingHorizontal;
  final ChildToChildSpacing childToChildSpacingVertical;
  final TFC_BoxDecoration boxDecoration;
  final TFC_TouchInteractionConfig touchInteractionConfig;
  final String debugName;
  bool get shouldPadInbetweenContents {
    switch(mainAxis) {
      case Axis3D.HORIZONTAL:
        return childToChildSpacingHorizontal.uniformPadding_tu != null;
      case Axis3D.VERTICAL:
        return childToChildSpacingVertical.uniformPadding_tu != null;
      case Axis3D.Z_AXIS:
        return false;
    }
  }

  @mustCallSuper
  const Box({
    this.width = const AxisSize.shrinkToFitContents(),
    this.height = const AxisSize.shrinkToFitContents(),
    this.children = const [],
    this.mainAxis = Axis3D.VERTICAL,
    this.childToBoxSpacing =
      const ChildToBoxSpacing.center(),
    this.childToChildSpacingHorizontal =
      const ChildToChildSpacing.noPadding(),
    this.childToChildSpacingVertical =
      const ChildToChildSpacing.noPadding(),
    this.boxDecoration =
      const TFC_BoxDecoration.undecorated(),
    this.touchInteractionConfig =
      const TFC_TouchInteractionConfig.notInteractable(),
    this.debugName = "",
  }) : limitationType = null;

  static Box<TFC_MustBeFixedSize> fixedSize({
    required bool widthIsTU,
    required double width_tuORfu,
    required bool heightIsTU,
    required double height_tuORfu,
    List<Widget?> children = const [],
    Axis3D mainAxis = Axis3D.VERTICAL,
    ChildToBoxSpacing childToBoxSpacing =
      const ChildToBoxSpacing.center(),
    ChildToChildSpacing childToChildSpacingHorizontal =
      const ChildToChildSpacing.noPadding(),
    ChildToChildSpacing childToChildSpacingVertical =
      const ChildToChildSpacing.noPadding(),
    TFC_BoxDecoration boxDecoration =
      const TFC_BoxDecoration.undecorated(),
    TFC_TouchInteractionConfig touchInteractionConfig =
      const TFC_TouchInteractionConfig.notInteractable(),
    String debugName = "",
  }) {
    return Box._withLimitationType(
      width: (widthIsTU)
        ? AxisSize.tu(width_tuORfu)
        : AxisSize.fu(width_tuORfu),
      height: (heightIsTU)
        ? AxisSize.tu(height_tuORfu)
        : AxisSize.fu(height_tuORfu),
      limitationType: const TFC_MustBeFixedSize(),
      children: children,
      mainAxis: mainAxis,
      childToBoxSpacing: childToBoxSpacing,
      childToChildSpacingHorizontal: childToChildSpacingHorizontal,
      childToChildSpacingVertical: childToChildSpacingVertical,
      boxDecoration: boxDecoration,
      touchInteractionConfig: touchInteractionConfig,
      debugName: debugName,
    );
  }

  const Box._withLimitationType({
    required this.width,
    required this.height,
    required this.limitationType,
    this.children = const [],
    this.mainAxis = Axis3D.VERTICAL,
    this.childToBoxSpacing =
      const ChildToBoxSpacing.center(),
    this.childToChildSpacingHorizontal =
      const ChildToChildSpacing.noPadding(),
    this.childToChildSpacingVertical =
      const ChildToChildSpacing.noPadding(),
    this.boxDecoration =
      const TFC_BoxDecoration.undecorated(),
    this.touchInteractionConfig =
      const TFC_TouchInteractionConfig.notInteractable(),
    this.debugName = "",
  });

  const Box.empty()
    : this.width =
        const AxisSize.shrinkToFitContents(),
      this.height =
        const AxisSize.shrinkToFitContents(),
      this.childToBoxSpacing =
        const ChildToBoxSpacing.center(),
      this.mainAxis = Axis3D.VERTICAL,
      this.childToChildSpacingHorizontal =
        const ChildToChildSpacing.noPadding(),
      this.childToChildSpacingVertical =
        const ChildToChildSpacing.noPadding(),
      this.children = const [],
      this.boxDecoration =
        const TFC_BoxDecoration.undecorated(),
      this.touchInteractionConfig =
        const TFC_TouchInteractionConfig.notInteractable(),
      this.debugName = "",
      limitationType = null;

  _BoxState createState() {
    return _BoxState();
  }
}

class _BoxState extends State<Box> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      logToConsole("");
      logToConsole("Starting Build");

      // Discard all null children
      List<Widget> children = [];
      for (int i = 0; i < widget.children.length; i++) {
        if (widget.children[i] != null) {
          children.add(widget.children[i]!);
        }
      }

      // Decide whether or not to add uniform padding between children
      bool shouldPadBetweenChildren;
      switch(widget.mainAxis) {
        case Axis3D.HORIZONTAL:
          shouldPadBetweenChildren = widget.childToChildSpacingHorizontal.uniformPadding_tu != null;
          break;
        case Axis3D.VERTICAL:
          shouldPadBetweenChildren = widget.childToChildSpacingVertical.uniformPadding_tu != null;
          break;
        case Axis3D.Z_AXIS:
          shouldPadBetweenChildren = false;
          break;
      }

      // When applicable add uniform padding between children
      List<Widget> temporaryChildren = [];
      for (int i = 0; i < children.length; i++) {
        if (shouldPadBetweenChildren && i > 0) {
          temporaryChildren.add(
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
        temporaryChildren.add(children[i]);
      }
      children = temporaryChildren;

      // Determine the constraints for the children
      double maxChildWidth = constraints.maxWidth;
      if (widget.width.isScrollable) {
        maxChildWidth = double.infinity;
        logToConsole("Gave children infinite width.");
      } else if (widget.width.size_fu != null && widget.width.size_fu! > 0 && widget.width.size_fu! < constraints.maxWidth) {
        maxChildWidth = widget.width.size_fu!;
      }
      if (maxChildWidth != double.infinity) {
        double amountToTakeOffForPadding = 0.0;
        if (widget.childToBoxSpacing.flutterPadding != null) {
          amountToTakeOffForPadding = widget.childToBoxSpacing.flutterPadding!.horizontal;
        }
        logToConsole("Took ${amountToTakeOffForPadding} off of horizontal for padding.");
        maxChildWidth = max(0, maxChildWidth - amountToTakeOffForPadding);
      }

      double maxChildHeight = constraints.maxHeight;
      if (widget.height.isScrollable) {
        maxChildHeight = double.infinity;
        logToConsole("Gave children infinite height.");
      } else if (widget.height.size_fu != null && widget.height.size_fu! > 0 && widget.height.size_fu! < constraints.maxHeight) {
        maxChildHeight = widget.height.size_fu!;
      }
      if (maxChildHeight != double.infinity) {
        double amountToTakeOffForPadding = 0.0;
        if (widget.childToBoxSpacing.flutterPadding != null) {
          amountToTakeOffForPadding = widget.childToBoxSpacing.flutterPadding!.horizontal;
        }
        logToConsole("Took ${amountToTakeOffForPadding} off of vertical for padding.");
        maxChildHeight = max(0, maxChildHeight - amountToTakeOffForPadding);
      }
      BoxConstraints childConstraints = BoxConstraints(
        minWidth: min(constraints.minWidth, maxChildWidth),
        maxWidth: maxChildWidth,
        minHeight: min(constraints.minHeight, maxChildHeight),
        maxHeight: maxChildHeight,
      );

      // Wrap children in constraints
      for (int i = 0; i < children.length; i ++) {
        if (!(children[i] is Flexible)) {
          children[i] = ConstrainedBox(
            constraints: childConstraints,
            child: children[i],
          );
        }
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
      logToConsole("child count: ${children.length}.");
      if (children.length == 0) {
        newWidget = null;
        logToConsole("used null.");
      } else if (children.length == 1 && !shouldUseRowForAlignment && !shouldUseColumnForAlignment) {
        newWidget = children[0];
        logToConsole("used child.");
      } else {
        Axis3D mainAxis = widget.mainAxis;
        
        if (shouldUseRowForAlignment) {
          mainAxis = Axis3D.HORIZONTAL;
        } else if (shouldUseColumnForAlignment) {
          mainAxis = Axis3D.VERTICAL;
        }

        // Horizontal
        switch(mainAxis) {
          case Axis3D.HORIZONTAL:
          newWidget = Row(
            mainAxisSize: widget.width.axisSize,
            mainAxisAlignment: 
              widget.childToChildSpacingHorizontal.axisAlignment
              ?? ChildToBoxSpacing.tfcAlignToMainAxisAlignment(
                  widget.childToBoxSpacing.horizontalAlignment,
                ),
            crossAxisAlignment: ChildToBoxSpacing.tfcAlignToCrossAxisAlignment(
              widget.childToBoxSpacing.verticalAlignment,
            ),
            children: children,
          );
          logToConsole("used row.");
          break;

          // Vertical
          case Axis3D.VERTICAL:
          newWidget = Column(
            mainAxisSize: widget.height.axisSize,
            mainAxisAlignment:
              widget.childToChildSpacingVertical.axisAlignment
              ?? ChildToBoxSpacing.tfcAlignToMainAxisAlignment(
                  widget.childToBoxSpacing.verticalAlignment,
                ),
            crossAxisAlignment: ChildToBoxSpacing.tfcAlignToCrossAxisAlignment(
              widget.childToBoxSpacing.horizontalAlignment,
            ),
            children: children,
          );
          logToConsole("used column.");
          break;
          case Axis3D.Z_AXIS:
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
        logToConsole("used Align!.");
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
      logToConsole("width: ${widget.width.size_fu}");
      logToConsole("height: ${widget.height.size_fu}");
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
      logToConsole("childConstraints: ${childConstraints.toString()}");

      // Finally, return the new widget
      return newWidget;
    });
  }

  void logToConsole(String text) {
    if (Box.SHOULD_PRINT_DEBUG_LOGS) {
      debugPrint("${widget.debugName} - ${text}");
    }
  }
}