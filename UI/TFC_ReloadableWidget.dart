import 'package:flutter/material.dart';
import '../Utilities/TFC_Utilities.dart';

abstract class TFC_ReloadableWidget extends StatefulWidget {
  //_TFC_ReloadableWidgetState _state;
  final bool Function()? _mayReload;
  bool checkIfMayReload() {
    if (_mayReload != null) {
      return _mayReload!();
    } else {
      return true;
    }
  }

  TFC_ReloadableWidget({Key? key, bool Function()? mayReload})
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
    _reloadWrapper.reload = _state.reload;
    return _state;
  }
  
  // This is janky, but it works
  final _TFC_ReloadFunctionWrapper _reloadWrapper = _TFC_ReloadFunctionWrapper();
  Future reload() async {
    _reloadWrapper.reload();
  }

  // Let the children have access to the state object at build time
  static Map<int, _TFC_ReloadableWidgetState> _stateInstances = Map();

  _TFC_ReloadableWidgetState getStateInstance(BuildContext context) {
    return _stateInstances[context.hashCode]!;
  }

  static void registerStateInstance(
      BuildContext context, _TFC_ReloadableWidgetState stateInstance) {
    _stateInstances[context.hashCode] = stateInstance;
  }

  static void deregisterStateInstance(BuildContext context) {
    _stateInstances.remove(context.hashCode);
  }
}

class _TFC_ReloadFunctionWrapper {
  Future Function() reload = () async {};
}

class _TFC_ReloadableWidgetState extends State<TFC_ReloadableWidget>
    with TickerProviderStateMixin {
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
    TFC_ReloadableWidget.registerStateInstance(context, this);
    Widget widgetToReturn = _buildWidget(context);
    TFC_ReloadableWidget.deregisterStateInstance(context);
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
