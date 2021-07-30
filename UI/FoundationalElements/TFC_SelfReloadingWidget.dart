import 'package:flutter/material.dart';
import '../../Utilities/TFC_Event.dart';
import '../../Utilities/TFC_Utilities.dart';

abstract class TFC_SelfReloadingWidget extends StatefulWidget {
  // Props
  final List<TFC_Event?> reloadTriggers;

  //_TFC_ReloadableWidgetState _state;
  final bool Function()? _mayReload;
  bool checkIfMayReload() {
    if (_mayReload != null) {
      return _mayReload!();
    } else {
      return true;
    }
  }

  TFC_SelfReloadingWidget({Key? key, bool Function()? mayReload, required this.reloadTriggers})
      : _mayReload = mayReload,
        super(key: key) {
    for (TFC_Event? event in reloadTriggers) {
      if (event != null) {
        event.addListener(reload);
      }
    }
    //_state = _TFC_ReloadableWidgetState(onInit, onDispose, buildWidget);
    //reload = _state.reload;
  }

  void onInit() {}
  void onDispose() {}
  Widget buildWidget(BuildContext context);

  @override
  State<StatefulWidget> createState() {
    _TFC_SelfReloadingWidgetState _state =
        _TFC_SelfReloadingWidgetState(onInit, onDispose, buildWidget);
    _reloadWrapper.reload = _state.reload;
    return _state;
  }
  
  // This is janky, but it works
  final _TFC_ReloadFunctionWrapper _reloadWrapper = _TFC_ReloadFunctionWrapper();
  Future reload() async {
    _reloadWrapper.reload();
  }

  // Let the children have access to the state object at build time
  static Map<int, _TFC_SelfReloadingWidgetState> _stateInstances = Map();

  _TFC_SelfReloadingWidgetState getStateInstance(BuildContext context) {
    return _stateInstances[context.hashCode]!;
  }

  static void registerStateInstance(
      BuildContext context, _TFC_SelfReloadingWidgetState stateInstance) {
    _stateInstances[context.hashCode] = stateInstance;
  }

  static void deregisterStateInstance(BuildContext context) {
    _stateInstances.remove(context.hashCode);
  }
}

class _TFC_ReloadFunctionWrapper {
  Future Function() reload = () async {};
}

class _TFC_SelfReloadingWidgetState extends State<TFC_SelfReloadingWidget>
    with TickerProviderStateMixin {
  final Widget Function(BuildContext context) _buildWidget;
  bool _buildIsInProgress = false;
  void Function() _onInit;
  void Function() _onDispose;

  _TFC_SelfReloadingWidgetState(this._onInit, this._onDispose, this._buildWidget);

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
    TFC_SelfReloadingWidget.registerStateInstance(context, this);
    Widget widgetToReturn = _buildWidget(context);
    TFC_SelfReloadingWidget.deregisterStateInstance(context);
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
