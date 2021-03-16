import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';
import '../Serialization/TFC_SerializingContainers.dart';
import 'TFC_ItemInstances.dart';

class TFC_AttributeInt extends TFC_AttributeProperty<int> {
  TFC_AttributeInt({
    @required String attributeKey,
    @required TFC_AttributeSetupDataFromItemInstance attributeSetupDataFromItemInstance,
    void Function() onBeforeGetListener,
    void Function() onAfterSetListener,
  }) : super(
    attributeKey: attributeKey,
    attributeSetupDataFromItemInstance: attributeSetupDataFromItemInstance,
    onBeforeGetListener: onBeforeGetListener,
    onAfterSetListener: onAfterSetListener,
  );

  @override
  int getDefaultValue() {
    return 0;
  }
}

class TFC_AttributeString extends TFC_AttributeProperty<String> {
  final int maxLength;

  TFC_AttributeString({
    @required String attributeKey,
    @required TFC_AttributeSetupDataFromItemInstance attributeSetupDataFromItemInstance,
    @required this.maxLength,
    void Function() onBeforeGetListener,
    void Function() onAfterSetListener,
  }) : super(
    attributeKey: attributeKey,
    attributeSetupDataFromItemInstance: attributeSetupDataFromItemInstance,
    onBeforeGetListener: onBeforeGetListener,
    onAfterSetListener: onAfterSetListener,
  );

  @override
  String getDefaultValue() {
    return "";
  }
}

abstract class TFC_AttributeProperty<AttributeType> extends TFC_Attribute {
  AttributeType get value {
    return getValue();
  }
  set value(AttributeType newValue) {
    setValue(newValue);
  }

  TFC_AttributeProperty({
    @required String attributeKey,
    @required TFC_AttributeSetupDataFromItemInstance attributeSetupDataFromItemInstance,
    void Function() onBeforeGetListener,
    void Function() onAfterSetListener,
  }) : super(
    attributeKey: attributeKey,
    attributeSetupDataFromItemInstance: attributeSetupDataFromItemInstance,
    onBeforeGetListener: onBeforeGetListener,
    onAfterSetListener: onAfterSetListener,
  );

  AttributeType getValue() {
    dynamic instanceValue = TFC_ItemInstances.getAttributeValue(_itemID, _itemType, _attributeKey, getDefaultValue());
    if (instanceValue == null) {
      return getDefaultValue();
    } else {
      return instanceValue;
    }
  }

  void setValue(AttributeType newValue) {
    TFC_ItemInstances.setAttributeValue(_itemID, _itemType, _attributeKey, newValue);
  }
}

class TFC_AttributeSet extends TFC_Attribute {
  TFC_SerializingSet get serializingSet {
    return getSet();
  }

  TFC_AttributeSet({
    @required String attributeKey,
    @required TFC_AttributeSetupDataFromItemInstance attributeSetupDataFromItemInstance,
    void Function() onBeforeGetListener,
    void Function() onAfterSetListener,
  }) : super(
    attributeKey: attributeKey,
    attributeSetupDataFromItemInstance: attributeSetupDataFromItemInstance,
    onBeforeGetListener: onBeforeGetListener,
    onAfterSetListener: onAfterSetListener,
  );

  @override
  List getDefaultValue() {
    return [];
  }

  TFC_SerializingSet getSet() {
    return TFC_ItemInstances.getAttributeValue(_itemID, _itemType, _attributeKey, getDefaultValue());
  }

  void add(dynamic element) {
    getSet().add(element);
  }

  dynamic remove(dynamic element) {
    return getSet().remove(element);
  }

  bool contains(dynamic element) {
    return getSet().contains(element);
  }
}

abstract class TFC_Attribute {
  final String _itemID;
  final String _itemType;
  final String _attributeKey;

  TFC_Attribute({
    @required String attributeKey,
    @required TFC_AttributeSetupDataFromItemInstance attributeSetupDataFromItemInstance,
    void Function() onBeforeGetListener,
    void Function() onAfterSetListener,
  }) :
    _itemID = attributeSetupDataFromItemInstance.itemID,
    _itemType = attributeSetupDataFromItemInstance.itemType,
    _attributeKey = attributeKey
  {
    attributeSetupDataFromItemInstance.listToAddTo.add(this);
    if (onBeforeGetListener != null) {
      TFC_ItemInstances.addOnBeforeGetListener(_itemID, _attributeKey, onBeforeGetListener);
    }
    if (onBeforeGetListener != null) {
      TFC_ItemInstances.addOnAfterSetListener(_itemID, _attributeKey, onAfterSetListener);
    }
  }

  void addOnBeforeGetListener(void Function() listener) {
    TFC_ItemInstances.addOnBeforeGetListener(_itemID, _attributeKey, listener);
  }

  void removeOnBeforeGetListener(void Function() listener) {
    TFC_ItemInstances.removeOnBeforeGetListener(_itemID, _attributeKey, listener);
  }

  void addOnAfterSetListener(void Function() listener) {
    TFC_ItemInstances.addOnAfterSetListener(_itemID, _attributeKey, listener);
  }

  void removeOnAfterSetListener(void Function() listener) {
    TFC_ItemInstances.removeOnAfterSetListener(_itemID, _attributeKey, listener);
  }

  dynamic getDefaultValue();

  @override
  int get hashCode => hash2(_itemID.hashCode, _attributeKey.hashCode);

  @override
  bool operator == (dynamic other) {
    return other is TFC_Attribute && other._itemID.hashCode == _itemID.hashCode && other._attributeKey.hashCode == _attributeKey.hashCode;
  }
}

class TFC_AttributeSetupDataFromItemInstance {
  final String itemID;
  final String itemType;
  final List<dynamic> listToAddTo;

  TFC_AttributeSetupDataFromItemInstance(this.itemID, this.itemType, this.listToAddTo);
}