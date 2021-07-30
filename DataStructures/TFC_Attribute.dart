import 'package:quiver/core.dart';
import '../Utilities/TFC_Event.dart';
import '../Serialization/TFC_SerializingContainers.dart';
import 'TFC_Item.dart';
import 'TFC_ItemInstances.dart';

class TFC_AttributeItem<ItemType extends TFC_Item> implements TFC_Attribute {
  final String _attributeKey;
  final ItemType Function() _getDefaultItemOnCreateNew;
  final ItemType Function(String) _getItemFromItemID;
  late TFC_AttributeString _itemIDAttribute;
  TFC_Event? get onBeforeGetEvent {
    return _itemIDAttribute.onBeforeGetEvent;
  }
  TFC_Event? get onAfterSetEvent {
    return _itemIDAttribute.onAfterSetEvent;
  }

  String get _itemID {
    return _itemIDAttribute._itemID;
  }

  void set _itemID(String newItemID) {
    _itemIDAttribute._itemID = newItemID;
  }

  String get _itemType {
    return _itemIDAttribute._itemType;
  }

  void set _itemType(String newItemType) {
    _itemIDAttribute._itemType = newItemType;
  }

  TFC_AttributeItem({
    required String attributeKey,
    required ItemType Function() getDefaultItemOnCreateNew,
    required ItemType Function(String) getItemFromItemID,
    void Function()? onBeforeGetListener,
    void Function()? onAfterSetListener,
  })  : _attributeKey = attributeKey,
        _getDefaultItemOnCreateNew = getDefaultItemOnCreateNew,
        _getItemFromItemID = getItemFromItemID {
    _itemIDAttribute = TFC_AttributeString(
      attributeKey: _attributeKey,
      maxLength: TFC_Item.MAX_ITEM_ID_LENGTH,
      onBeforeGetListener: onBeforeGetListener,
      onAfterSetListener: onAfterSetListener,
    );

    // Call create new if the item is undefined
    if (_itemIDAttribute.value == null || _itemIDAttribute.value == "") {
      _itemIDAttribute.value = _getDefaultItemOnCreateNew().itemID;
    }
  }

  void injectSetupDataFromItemInstance({
    required String itemID,
    required String itemType,
  }) {
    _itemID = itemID;
    _itemType = itemType;
  }

  ItemType get value {
    return _getItemFromItemID(_itemIDAttribute.value);
  }

  set value(ItemType newItem) {
    _itemIDAttribute.value = newItem.itemID;
  }

  void addOnBeforeGetListener(void Function() listener) {
    TFC_ItemInstances.addOnBeforeGetListener(
        _itemIDAttribute.value, _attributeKey, listener);
  }

  void removeOnBeforeGetListener(void Function() listener) {
    TFC_ItemInstances.removeOnBeforeGetListener(
        _itemIDAttribute.value, _attributeKey, listener);
  }

  void addOnAfterSetListener(void Function() listener) {
    TFC_ItemInstances.addOnAfterSetListener(
        _itemIDAttribute.value, _attributeKey, listener);
  }

  void removeOnAfterSetListener(void Function() listener) {
    TFC_ItemInstances.removeOnAfterSetListener(
        _itemIDAttribute.value, _attributeKey, listener);
  }

  @override
  int get hashCode =>
      hash2(_itemIDAttribute.value.hashCode, _attributeKey.hashCode);

  @override
  bool operator ==(dynamic other) {
    return other is TFC_AttributeItem &&
        other._itemIDAttribute.value.hashCode ==
            _itemIDAttribute.value.hashCode &&
        other._attributeKey.hashCode == _attributeKey.hashCode;
  }
}

class TFC_AttributeDouble extends TFC_AttributeProperty<double> {
  final double _defaultValue;

  TFC_AttributeDouble({
    required String attributeKey,
    double defaultValue = 0.0,
    void Function()? onBeforeGetListener,
    void Function()? onAfterSetListener,
  })  : _defaultValue = defaultValue,
        super(
          attributeKey: attributeKey,
          onBeforeGetListener: onBeforeGetListener,
          onAfterSetListener: onAfterSetListener,
        );

  @override
  double getDefaultValue() {
    return _defaultValue;
  }
}

class TFC_AttributeInt extends TFC_AttributeProperty<int> {
  final int _defaultValue;

  TFC_AttributeInt({
    required String attributeKey,
    int defaultValue = 0,
    void Function()? onBeforeGetListener,
    void Function()? onAfterSetListener,
  })  : _defaultValue = defaultValue,
        super(
          attributeKey: attributeKey,
          onBeforeGetListener: onBeforeGetListener,
          onAfterSetListener: onAfterSetListener,
        );

  @override
  int getDefaultValue() {
    return _defaultValue;
  }
}

class TFC_AttributeString extends TFC_AttributeProperty<String> {
  final String _defaultValue;
  final int maxLength;

  TFC_AttributeString({
    required String attributeKey,
    String defaultValue = "",
    required this.maxLength,
    void Function()? onBeforeGetListener,
    void Function()? onAfterSetListener,
  })  : _defaultValue = defaultValue,
        super(
          attributeKey: attributeKey,
          onBeforeGetListener: onBeforeGetListener,
          onAfterSetListener: onAfterSetListener,
        );

  @override
  String getDefaultValue() {
    return _defaultValue;
  }
}

class TFC_AttributeBool extends TFC_AttributeProperty<bool> {
  final bool _defaultValue;

  TFC_AttributeBool({
    required String attributeKey,
    required bool defaultValue,
    void Function()? onBeforeGetListener,
    void Function()? onAfterSetListener,
  })  : _defaultValue = defaultValue,
        super(
          attributeKey: attributeKey,
          onBeforeGetListener: onBeforeGetListener,
          onAfterSetListener: onAfterSetListener,
        );

  @override
  bool getDefaultValue() {
    return _defaultValue;
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
    required String attributeKey,
    void Function()? onBeforeGetListener,
    void Function()? onAfterSetListener,
  }) : super(
          attributeKey: attributeKey,
          onBeforeGetListener: onBeforeGetListener,
          onAfterSetListener: onAfterSetListener,
        );

  AttributeType getValue() {
    dynamic instanceValue = TFC_ItemInstances.getAttributeValue(
        _itemID, _itemType, _attributeKey, getDefaultValue());
    if (instanceValue == null) {
      return getDefaultValue();
    } else {
      return instanceValue;
    }
  }

  dynamic getDefaultValue();

  void setValue(AttributeType newValue) {
    TFC_ItemInstances.setAttributeValue(
        _itemID, _itemType, _attributeKey, newValue);
  }
}

class TFC_AttributeItemSet<ItemType extends TFC_Item> extends TFC_Attribute {
  final ItemType Function(String) _getItemFromItemID;

  TFC_AttributeItemSet({
    required String attributeKey,
    required ItemType Function(String) getItemFromItemID,
    void Function()? onBeforeGetListener,
    void Function()? onAfterSetListener,
  })  : _getItemFromItemID = getItemFromItemID,
        super(
          attributeKey: attributeKey,
          onBeforeGetListener: onBeforeGetListener,
          onAfterSetListener: onAfterSetListener,
        );

  List getDefaultValue() {
    return [];
  }

  TFC_SerializingSet _getSerializingSet() {
    return TFC_ItemInstances.getAttributeValue(
        _itemID, _itemType, _attributeKey, getDefaultValue());
  }

  List<ItemType> getAllItems() {
    TFC_SerializingSet serializingSetOfItemIDs = _getSerializingSet();
    List<ItemType> items = [];

    for (String itemID in serializingSetOfItemIDs) {
      items.add(_getItemFromItemID(itemID));
    }

    return items;
  }

  List<ItemType> get allItems {
    return getAllItems();
  }

  void add(ItemType newItem) {
    _getSerializingSet().add(newItem.itemID);
  }

  void remove(ItemType itemToRemove) {
    _getSerializingSet().remove(itemToRemove.itemID);
  }

  bool contains(ItemType itemToFind) {
    return _getSerializingSet().contains(itemToFind.itemID);
  }
}

class TFC_AttributeSet extends TFC_Attribute {
  TFC_SerializingSet get serializingSet {
    return getSet();
  }

  TFC_AttributeSet({
    required String attributeKey,
    void Function()? onBeforeGetListener,
    void Function()? onAfterSetListener,
  }) : super(
          attributeKey: attributeKey,
          onBeforeGetListener: onBeforeGetListener,
          onAfterSetListener: onAfterSetListener,
        );

  List getDefaultValue() {
    return [];
  }

  TFC_SerializingSet getSet() {
    return TFC_ItemInstances.getAttributeValue(
        _itemID, _itemType, _attributeKey, getDefaultValue());
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
  late final String _itemID;
  late final String _itemType;
  final String _attributeKey;
  TFC_Event? get onBeforeGetEvent {
    return TFC_ItemInstances.getOnBeforeGetEvent(_itemID, _attributeKey);
  }
  TFC_Event? get onAfterSetEvent {
    return TFC_ItemInstances.getOnAfterSetEvent(_itemID, _attributeKey);
  }

  TFC_Attribute({
    required String attributeKey,
    void Function()? onBeforeGetListener,
    void Function()? onAfterSetListener,
  })  : _attributeKey = attributeKey {
    if (onBeforeGetListener != null) {
      TFC_ItemInstances.addOnBeforeGetListener(
          _itemID, _attributeKey, onBeforeGetListener);
    }
    if (onBeforeGetListener != null) {
      TFC_ItemInstances.addOnAfterSetListener(
          _itemID, _attributeKey, onAfterSetListener);
    }
  }

  void injectSetupDataFromItemInstance({
    required String itemID,
    required String itemType,
  }) {
    _itemID = itemID;
    _itemType = itemType;
  }

  void addOnBeforeGetListener(void Function() listener) {
    TFC_ItemInstances.addOnBeforeGetListener(_itemID, _attributeKey, listener);
  }

  void removeOnBeforeGetListener(void Function() listener) {
    TFC_ItemInstances.removeOnBeforeGetListener(
        _itemID, _attributeKey, listener);
  }

  void addOnAfterSetListener(void Function() listener) {
    TFC_ItemInstances.addOnAfterSetListener(_itemID, _attributeKey, listener);
  }

  void removeOnAfterSetListener(void Function() listener) {
    TFC_ItemInstances.removeOnAfterSetListener(
        _itemID, _attributeKey, listener);
  }

  @override
  int get hashCode => hash2(_itemID.hashCode, _attributeKey.hashCode);

  @override
  bool operator ==(dynamic other) {
    return other is TFC_Attribute &&
        other._itemID.hashCode == _itemID.hashCode &&
        other._attributeKey.hashCode == _attributeKey.hashCode;
  }
}
