import './TFC_Event.dart';

class TFC_BasicValueWrapper<ValueType> {
  // On changed event
  final TFC_Event onChanged = TFC_Event();

  // Values
  ValueType _value;
  ValueType get value {
    return _value;
  }
  void set value(ValueType newValue) {
    _value = newValue;
    onChanged.trigger();
  }

  TFC_BasicValueWrapper(this._value);
}