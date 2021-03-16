import 'package:flutter/material.dart';
import '../Utilities/TFC_Utilities.dart';

abstract class TFC_ReloadableWidget extends StatefulWidget {
  //_TFC_ReloadableWidgetState _state;
  Future Function() reload;
  final bool Function() _mayReload;
  bool checkIfMayReload() {
    if (_mayReload != null) {
      return _mayReload();
    } else {
      return true;
    }
  }

  TFC_ReloadableWidget({Key key, bool Function() mayReload})
      : _mayReload = mayReload,
        super(key: key) {
    //_state = _TFC_ReloadableWidgetState(onInit, onDispose, buildWidget);
    //reload = _state.reload;
  }

  void onInit() {}
  void onDispose() {}
  Widget buildWidget(BuildContext context);

  @override
  State<StatefulWidget> createState() {
    _TFC_ReloadableWidgetState _state =
        _TFC_ReloadableWidgetState(onInit, onDispose, buildWidget);
    reload = _state.reload;
    return _state;
  }
}

class _TFC_ReloadableWidgetState extends State<TFC_ReloadableWidget> {
  final Widget Function(BuildContext context) _buildWidget;
  bool _buildIsInProgress = false;
  void Function() _onInit;
  void Function() _onDispose;

  _TFC_ReloadableWidgetState(this._onInit, this._onDispose, this._buildWidget);

  @override
  void initState() {
    super.initState();
    if (_onInit != null) {
      _onInit();
    }
  }

  @override
  void dispose() {
    if (_onDispose != null) {
      _onDispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _buildIsInProgress = true;
    Widget widgetToReturn = _buildWidget(context);
    _buildIsInProgress = false;
    return widgetToReturn;
  }

  Future reload() async {
    await TFC_Utilities.when(() {
      return !_buildIsInProgress;
    });
    if (setState != null && mounted && widget.checkIfMayReload()) {
      setState(() {});
    }
    return;
  }
}
