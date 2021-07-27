import 'dart:developer';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../ConfigurationTypes/TFC_BoxDecoration.dart';
import '../ConfigurationTypes/TFC_InterChildAlign.dart';
import '../ConfigurationTypes/TFC_AxisSize.dart';
import '../ConfigurationTypes/TFC_BoxToChildAlign.dart';
import '../ConfigurationTypes/TFC_TouchInteractionConfig.dart';
import './TU.dart';
//import './TFC_WidgetBrick.dart';

enum TFC_Axis { HORIZONTAL, VERTICAL, Z_AXIS }

class TFC_Box extends StatefulWidget {
  final TFC_AxisSize width;
  final TFC_AxisSize height;
  final TFC_BoxToChildAlign boxToChildAlignmentConfiguration;
  final TFC_Axis mainAxis;
  final TFC_InterChildAlign interChildAlignHorizontal;
  final TFC_InterChildAlign interChildAlignmentVertical;
  final List<Widget> children;
  final TFC_BoxDecoration boxDecoration;
  final TFC_TouchInteractionConfig touchInteractionConfigurations;
  bool get shouldPadInbetweenContents {
    switch(mainAxis) {
      case TFC_Axis.HORIZONTAL:
        return interChildAlignHorizontal.uniformPadding_tu != null;
      case TFC_Axis.VERTICAL:
        return interChildAlignmentVertical.uniformPadding_tu != null;
      case TFC_Axis.Z_AXIS:
        return false;
    }
  }

  @mustCallSuper
  const TFC_Box({
    required this.width,
    required this.height,
    this.boxToChildAlignmentConfiguration =
      const TFC_BoxToChildAlign.center(),
    this.mainAxis = TFC_Axis.VERTICAL,
    this.interChildAlignHorizontal =
      const TFC_InterChildAlign.noPadding(),
    this.interChildAlignmentVertical =
      const TFC_InterChildAlign.noPadding(),
    this.children = const [],
    this.boxDecoration =
      const TFC_BoxDecoration.undecorated(),
    this.touchInteractionConfigurations =
      const TFC_TouchInteractionConfig.notInteractable(),
  });

  const TFC_Box.empty()
    : this.width =
        const TFC_AxisSize.shrinkToFitContents(),
      this.height =
        const TFC_AxisSize.shrinkToFitContents(),
      this.boxToChildAlignmentConfiguration =
        const TFC_BoxToChildAlign.center(),
      this.mainAxis = TFC_Axis.VERTICAL,
      this.interChildAlignHorizontal =
        const TFC_InterChildAlign.noPadding(),
      this.interChildAlignmentVertical =
        const TFC_InterChildAlign.noPadding(),
      this.children = const [],
      this.boxDecoration =
        const TFC_BoxDecoration.undecorated(),
      this.touchInteractionConfigurations =
        const TFC_TouchInteractionConfig.notInteractable();

  _TFC_BoxState createState() {
    return _TFC_BoxState();
  }
}

class _TFC_BoxState extends State<TFC_Box> {
  @override
  Widget build(BuildContext context) {
    // Add padding between children
    List<Widget> childrenWithPaddingInbetween = [];
    for (int i = 0; i < widget.children.length; i++) {
      if (widget.shouldPadInbetweenContents && i > 0) {
        childrenWithPaddingInbetween.add(
          Container(
            width: TU.toFU(widget.interChildAlignHorizontal.uniformPadding_tu),
            height: TU.toFU(widget.interChildAlignmentVertical.uniformPadding_tu),
          ),
        );
      }
      childrenWithPaddingInbetween.add(widget.children[i]);
    }

    // Determine what structure to use for the children
    Widget? child;
    if (widget.children.length <= 1) {
      child = (widget.children.length > 0) ? widget.children[0] : null;
    } else if (widget.mainAxis == TFC_Axis.HORIZONTAL) {
      child = Column(
        mainAxisAlignment: 
          widget.interChildAlignmentVertical.axisAlignment
          ?? MainAxisAlignment.start,
        mainAxisSize: widget.height.axisSize ?? MainAxisSize.max,
        children: [Row(
          mainAxisAlignment: 
            widget.interChildAlignHorizontal.axisAlignment
            ?? MainAxisAlignment.start,
          mainAxisSize: widget.width.axisSize ?? MainAxisSize.max,
          children: childrenWithPaddingInbetween,
        )],
      );
    } else if (widget.mainAxis == TFC_Axis.VERTICAL) {
      child = Row(
        mainAxisAlignment: 
          widget.interChildAlignHorizontal.axisAlignment
          ?? MainAxisAlignment.start,
        mainAxisSize: widget.width.axisSize ?? MainAxisSize.max,
        children: [Column(
          mainAxisAlignment: 
            widget.interChildAlignmentVertical.axisAlignment
            ?? MainAxisAlignment.start,
          mainAxisSize: widget.height.axisSize ?? MainAxisSize.max,
          children: childrenWithPaddingInbetween,
        )],
          );
    } else if (widget.mainAxis == TFC_Axis.Z_AXIS) {
      child = Stack(
        children: childrenWithPaddingInbetween,
      );
    }

    // Determine the padding in case of an outline
    EdgeInsetsGeometry? paddingForOutline = null;
    EdgeInsetsGeometry? potentialyReducedBoxedToChildrenPading =
      widget.boxToChildAlignmentConfiguration.flutterPadding;
    if (widget.boxDecoration.isOutlined) {
      paddingForOutline = EdgeInsets.all(
        widget.boxDecoration.borderWidth_fu!
      );

      if (potentialyReducedBoxedToChildrenPading != null) {
        potentialyReducedBoxedToChildrenPading =
          potentialyReducedBoxedToChildrenPading.subtract(paddingForOutline);
      }
    }

    // Compile the box container
    Widget container = Container(
      padding: paddingForOutline,
      child: Ink(
        width: TU.toFU(widget.width.size),
        height: TU.toFU(widget.height.size),
        child: Container(
          child: child,
          padding: potentialyReducedBoxedToChildrenPading,
          alignment: widget.boxToChildAlignmentConfiguration.flutterAlignment,
        ),
        decoration: widget.boxDecoration.flutterBoxDecoration,
      )
    );

    // Finally, add the gesture detector.
    return widget.touchInteractionConfigurations.ifIntractableWrapInGestureDetector(child: container);
  }
}