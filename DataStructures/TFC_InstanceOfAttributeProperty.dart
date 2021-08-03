import 'TFC_InstanceOfAttribute.dart';

class TFC_InstanceOfAttributeProperty<PropertyType> extends TFC_InstanceOfAttribute<PropertyType> {
  // Handle getting and setting the value
  PropertyType _value;
  PropertyType get value {
    return _value;
  }
  void set value(PropertyType newValue) {
    _value = newValue;
    onAfterChange.trigger();
  }

  // Serialization API
  dynamic toJson() {
    return _value;
  }
  TFC_InstanceOfAttributeProperty.fromJson(dynamic json)
    : _value = json as PropertyType,
      super.fromJson(json);
}