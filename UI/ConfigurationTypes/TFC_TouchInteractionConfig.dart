import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'TFC_Configuration.dart';

class TFC_TouchInteractionConfig extends TFC_Configuration {
  final void Function(TapDownDetails)? onTapDown;
  final void Function(TapUpDetails)? onTapUp;
  final void Function()? onTap;
  final void Function()? onTapCancel;
  final void Function()? onSecondaryTap;
  final void Function(TapDownDetails)? onSecondaryTapDown;
  final void Function(TapUpDetails)? onSecondaryTapUp;
  final void Function()? onSecondaryTapCancel;
  final void Function(TapDownDetails)? onTertiaryTapDown;
  final void Function(TapUpDetails)? onTertiaryTapUp;
  final void Function()? onTertiaryTapCancel;
  final void Function(TapDownDetails)? onDoubleTapDown;
  final void Function()? onDoubleTap;
  final void Function()? onDoubleTapCancel;
  final void Function()? onLongPress;
  final void Function(LongPressStartDetails)? onLongPressStart;
  final void Function(LongPressMoveUpdateDetails)? onLongPressMoveUpdate;
  final void Function()? onLongPressUp;
  final void Function(LongPressEndDetails)? onLongPressEnd;
  final void Function()? onSecondaryLongPress;
  final void Function(LongPressStartDetails)? onSecondaryLongPressStart;
  final void Function(LongPressMoveUpdateDetails)? onSecondaryLongPressMoveUpdate;
  final void Function()? onSecondaryLongPressUp;
  final void Function(LongPressEndDetails)? onSecondaryLongPressEnd;
  final void Function(DragDownDetails)? onVerticalDragDown;
  final void Function(DragStartDetails)? onVerticalDragStart;
  final void Function(DragUpdateDetails)? onVerticalDragUpdate;
  final void Function(DragEndDetails)? onVerticalDragEnd;
  final void Function()? onVerticalDragCancel;
  final void Function(DragDownDetails)? onHorizontalDragDown;
  final void Function(DragStartDetails)? onHorizontalDragStart;
  final void Function(DragUpdateDetails)? onHorizontalDragUpdate;
  final void Function(DragEndDetails)? onHorizontalDragEnd;
  final void Function()? onHorizontalDragCancel;
  final void Function(ForcePressDetails)? onForcePressStart;
  final void Function(ForcePressDetails)? onForcePressPeak;
  final void Function(ForcePressDetails)? onForcePressUpdate;
  final void Function(ForcePressDetails)? onForcePressEnd;
  final void Function(DragDownDetails)? onPanDown;
  final void Function(DragStartDetails)? onPanStart;
  final void Function(DragUpdateDetails)? onPanUpdate;
  final void Function(DragEndDetails)? onPanEnd;
  final void Function()? onPanCancel;
  final void Function(ScaleStartDetails)? onScaleStart;
  final void Function(ScaleUpdateDetails)? onScaleUpdate;
  final void Function(ScaleEndDetails)? onScaleEnd;
  final HitTestBehavior? behavior;
  final bool excludeFromSemantics;
  final DragStartBehavior dragStartBehavior;
  bool get isAnInteractableWidget {
    return onTap != null;
  }

const TFC_TouchInteractionConfig.notInteractable()
  : this.onTapDown = null,
    this.onTapUp = null,
    this.onTap = null,
    this.onTapCancel = null,
    this.onSecondaryTap = null,
    this.onSecondaryTapDown = null,
    this.onSecondaryTapUp = null,
    this.onSecondaryTapCancel = null,
    this.onTertiaryTapDown = null,
    this.onTertiaryTapUp = null,
    this.onTertiaryTapCancel = null,
    this.onDoubleTapDown = null,
    this.onDoubleTap = null,
    this.onDoubleTapCancel = null,
    this.onLongPress = null,
    this.onLongPressStart = null,
    this.onLongPressMoveUpdate = null,
    this.onLongPressUp = null,
    this.onLongPressEnd = null,
    this.onSecondaryLongPress = null,
    this.onSecondaryLongPressStart = null,
    this.onSecondaryLongPressMoveUpdate = null,
    this.onSecondaryLongPressUp = null,
    this.onSecondaryLongPressEnd = null,
    this.onVerticalDragDown = null,
    this.onVerticalDragStart = null,
    this.onVerticalDragUpdate = null,
    this.onVerticalDragEnd = null,
    this.onVerticalDragCancel = null,
    this.onHorizontalDragDown = null,
    this.onHorizontalDragStart = null,
    this.onHorizontalDragUpdate = null,
    this.onHorizontalDragEnd = null,
    this.onHorizontalDragCancel = null,
    this.onForcePressStart = null,
    this.onForcePressPeak = null,
    this.onForcePressUpdate = null,
    this.onForcePressEnd = null,
    this.onPanDown = null,
    this.onPanStart = null,
    this.onPanUpdate = null,
    this.onPanEnd = null,
    this.onPanCancel = null,
    this.onScaleStart = null,
    this.onScaleUpdate = null,
    this.onScaleEnd = null,
    this.behavior = null,
    this.excludeFromSemantics = false,
    this.dragStartBehavior = DragStartBehavior.start;


  const TFC_TouchInteractionConfig({
    this.onTapDown,
    this.onTapUp,
    this.onTap,
    this.onTapCancel,
    this.onSecondaryTap,
    this.onSecondaryTapDown,
    this.onSecondaryTapUp,
    this.onSecondaryTapCancel,
    this.onTertiaryTapDown,
    this.onTertiaryTapUp,
    this.onTertiaryTapCancel,
    this.onDoubleTapDown,
    this.onDoubleTap,
    this.onDoubleTapCancel,
    this.onLongPress,
    this.onLongPressStart,
    this.onLongPressMoveUpdate,
    this.onLongPressUp,
    this.onLongPressEnd,
    this.onSecondaryLongPress,
    this.onSecondaryLongPressStart,
    this.onSecondaryLongPressMoveUpdate,
    this.onSecondaryLongPressUp,
    this.onSecondaryLongPressEnd,
    this.onVerticalDragDown,
    this.onVerticalDragStart,
    this.onVerticalDragUpdate,
    this.onVerticalDragEnd,
    this.onVerticalDragCancel,
    this.onHorizontalDragDown,
    this.onHorizontalDragStart,
    this.onHorizontalDragUpdate,
    this.onHorizontalDragEnd,
    this.onHorizontalDragCancel,
    this.onForcePressStart,
    this.onForcePressPeak,
    this.onForcePressUpdate,
    this.onForcePressEnd,
    this.onPanDown,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
    this.onPanCancel,
    this.onScaleStart,
    this.onScaleUpdate,
    this.onScaleEnd,
    this.behavior,
    this.excludeFromSemantics = false,
    this.dragStartBehavior = DragStartBehavior.start,
  });

  Widget ifIntractableWrapInGestureDetector({required Widget child}) {
    if (this.isAnInteractableWidget) {
      return InkWell(child: child, onTap: onTap,);
    } else {
      return child;
    }
  }
}