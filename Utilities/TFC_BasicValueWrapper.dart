import '../UI/FoundationalElements/TFC_OnAfterChange.dart';
import './TFC_Event.dart';

class TFC_BasicValueWrapper<ValueType> implements TFC_OnAfterChange {
  // On changed event
  final TFC_Event onAfterChange = TFC_Event();

  // Values
  ValueType _value;
  ValueType get value {
    return _value;
  }
  ValueType getValue() {
    return _value;
  }
  void set value(ValueType newValue) {
    _value = newValue;
    onAfterChange.trigger();
  }
  void setValue(ValueType newValue) {
    _value = newValue;
    onAfterChange.trigger();
  }

  TFC_BasicValueWrapper(this._value);
}