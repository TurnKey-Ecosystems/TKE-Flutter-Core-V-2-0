import 'package:flutter/foundation.dart';

class TFC_KeyedMapWithDefaultValue<ValueType> {
  final ValueType _defaultValue;
  TFC_KeyedMapWithDefaultValue(this._defaultValue);

  Map<Key, ValueType> _keyedMap = Map();

  ValueType getValue(Key key) {
    if (!_keyedMap.containsKey(key)) {
      _keyedMap[key] = _defaultValue;
    }
    return _keyedMap[key];
  }

  void setValue(Key key, ValueType value) {
    _keyedMap[key] = value;
  }
}

class TFC_ReferenceToKeyedMapValue<ValueType> {
  final TFC_KeyedMapWithDefaultValue<ValueType> _keyedMap;
  final Key _key;

  ValueType get value {
    return getValue();
  }

  set value(ValueType newValue) {
    setValue(newValue);
  }

  TFC_ReferenceToKeyedMapValue(this._key, this._keyedMap);

  ValueType getValue() {
    return _keyedMap.getValue(_key);
  }

  void setValue(ValueType newValue) {
    _keyedMap.setValue(_key, newValue);
  }
}
