import 'TFC_InstanceOfAttribute.dart';

class TFC_InstanceOfAttributeSet<ValueType> extends TFC_InstanceOfAttribute<Set<ValueType>> {
  // Handle getting and setting the value
  Set<ValueType> _value;
  Set<ValueType> get allValues {
    return Set.from(_value);
  }
  void add(ValueType newValue) {
    _value.add(newValue);
    onAfterChange.trigger();
  }
  void remove(ValueType valueToRemove) {
    _value.remove(valueToRemove);
    onAfterChange.trigger();
  }

  // Serialization API
  dynamic toJson() {
    return _value;
  }
  TFC_InstanceOfAttributeSet.fromJson(dynamic json)
    : _value = _jsonToSet(json),
      super.fromJson(json);
  
  // Converts a json set into a set in the proper format
  static Set<ValueType> _jsonToSet<ValueType>(dynamic json) {
    Set<ValueType> newSet = {};
    for (dynamic element in json) {
      newSet.add(element);
    }
    return newSet;
  }
}