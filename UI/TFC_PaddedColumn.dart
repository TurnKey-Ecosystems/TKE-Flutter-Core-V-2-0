import 'package:flutter/material.dart';
import 'TFC_AppStyle.dart';

class TFC_PaddedColumn extends StatelessWidget {
  final List<Widget> _givenChildren;
  final double _padding;

  TFC_PaddedColumn({
    @required List<Widget> children,
    double padding = 0.0
  }) :
    _givenChildren = children,
    _padding = (padding != 0.0) ? padding : 1.0 * TFC_AppStyle.instance.pageMargins
  ;

  @override
  Widget build(BuildContext context) {
    List<Widget> buildTimeChildren = List();

    // Add padding between each given child
    for (int givenChildIndex = 0; givenChildIndex < _givenChildren.length; givenChildIndex++) {
      if (givenChildIndex != 0) {
        buildTimeChildren.add(Container(height: _padding,));
      }
      buildTimeChildren.add(_givenChildren[givenChildIndex]);
    }

    return Column(
      children: buildTimeChildren,
    );
  }
}