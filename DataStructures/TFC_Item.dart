import 'dart:developer';

import '../Utilities/TFC_Event.dart';
import 'package:flutter/foundation.dart';
import 'TFC_Attribute.dart';
import 'TFC_ItemUtilities.dart';
import 'TFC_ItemInstances.dart';

abstract class TFC_Item {
  static const int MAX_ITEM_ID_LENGTH = 256;
  late String _itemID;
  String get itemID {
    return _itemID;
  }

  String get itemType;
  List<TFC_Attribute> _attributes = [];
  String get fileName {
    return TFC_ItemUtilities.generateFileName(itemID);
  }

  final TFC_Event onAttributesChanged = TFC_Event();
  final TFC_Event onBeforeDelete = TFC_Event();

  @mustCallSuper
  TFC_Item.createNew() {
    _itemID = TFC_ItemInstances.locallyCreateNewItem(itemType);
    TFC_ItemInstances.loadItemInstance(itemID);
    _initialize();
    createNewInit();
    TFC_ItemInstances.triggerOnItemOfTypeCreatedOrDestroyed(itemType);
  }

  @mustCallSuper
  TFC_Item.fromItemID(String givenItemID) {
    _itemID = givenItemID;
    TFC_ItemInstances.loadItemInstance(itemID);
    _initialize();
  }

  void _initialize() {
    TFC_AttributeSetupDataFromItemInstance attributeSetupDataFromItemInstance =
        TFC_AttributeSetupDataFromItemInstance(_itemID, itemType, _attributes);
    initializeAttributes(attributeSetupDataFromItemInstance);
    for (TFC_Attribute attribute in _attributes) {
      attribute.addOnAfterSetListener(tempTrackable);
    }
  }

  void createNewInit() {}

  void tempTrackable() {
    onAttributesChanged.trigger();
  }
  //Saved Items can not  be > 400KB

  void initializeAttributes(
      TFC_AttributeSetupDataFromItemInstance
          attributeSetupDataFromItemInstance);

  @mustCallSuper
  void delete() {
    onBeforeDelete.trigger();
    TFC_ItemInstances.deleteItem(itemID);
  }

  @override
  int get hashCode => itemID.hashCode;

  @override
  bool operator ==(dynamic other) {
    return other is TFC_Item && other.itemID == itemID;
  }
}
