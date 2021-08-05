import 'package:flutter/cupertino.dart';
import '../TFC_SyncLevel.dart';
import '../TFC_ItemChangeLog.dart';
import '../TFC_AllItemsManager.dart';
import '../../Utilities/TFC_Event.dart';


// Manages an instance of an attribute
abstract class TFC_InstanceOfAttribute {
  // The actual value of this attribute
  dynamic _value;


  // On after change Event
  final TFC_Event onAfterChange = TFC_Event();


  // The type of the item this attribute is associated with
  final String itemType;


  // The itemID of the item this attribute is associated with
  final String itemID;


  // The attributeKey of this attribute
  final String attributeKey;


  // The sync level of this attribute
  final TFC_SyncLevel syncLevel;


  // All children should override this
  dynamic toJson();
  
  // All children should override this
  TFC_InstanceOfAttribute.fromJson({
    required this.itemType,
    required this.itemID,
    required this.attributeKey,
    required this.syncLevel,
    required dynamic json,
  });


  // Notifies listenners, and log the change when applicable
  void _notifyOfChange({
    required TFC_ItemChangeLog change,
    required TFC_ChangeSource changeSource,
  }) {
    // Log this change
    if (changeSource == TFC_ChangeSource.DEVICE && syncLevel != TFC_SyncLevel.SESSION) {
      // TODO: Log the change to the sync controller
    }

    // Let listeners know that this attribute has been changed
    onAfterChange.trigger();
  }
}




// Lets an attribute instance be accessed like a simple property
class TFC_InstanceOfAttributeProperty<PropertyType> extends TFC_InstanceOfAttribute {
  // Allow anyone to read this attribute's value
  PropertyType get value {
    return _value;
  }


  // Allows the propety's value to be set
  void setValue({
    required PropertyType newValue,
    required TFC_ChangeSource changeSource,
  }) {
    _value = newValue;
    _notifyOfChange(
      change: TFC_ItemChangeLog.newAttributePropertySetLog(
        itemID: itemID,
        attributeKey: attributeKey,
        newValue: newValue,
      ),
      changeSource: changeSource,
    );
  }


  // Convert this attribute to a json value
  @override
  dynamic toJson() {
    return _value;
  }

  // Load this attribute from a json value
  TFC_InstanceOfAttributeProperty.fromJson({
    required String itemType,
    required String itemID,
    required String attributeKey,
    required TFC_SyncLevel syncLevel,
    required dynamic json,
  }) : super.fromJson(
        itemType: itemType,
        itemID: itemID,
        attributeKey: attributeKey,
        syncLevel: syncLevel,
        json: json,
      ) {
        _value = json;
      }
}




// Lets an attribute instance be accessed like a set
class TFC_InstanceOfAttributeSet<CententType> extends TFC_InstanceOfAttribute {
  // Allow anyone to read this attribute's value
  Set<CententType> get allValues {
    return Set.from(_value);
  }


  // Allows the set to be added to
  void addValue({
    required CententType addedValue,
    required TFC_ChangeSource changeSource,
  }) {
    _value.add(addedValue);
    _notifyOfChange(
      change: TFC_ItemChangeLog.newAttributeSetAddLog(
        itemID: itemID,
        attributeKey: attributeKey,
        addedValue: addedValue,
      ),
      changeSource: changeSource,
    );
  }


  // Allows the set to be added to
  void removeValue({
    required CententType removedValue,
    required TFC_ChangeSource changeSource,
  }) {
    _value.remove(removedValue);
    _notifyOfChange(
      change: TFC_ItemChangeLog.newAttributeSetRemoveLog(
        itemID: itemID,
        attributeKey: attributeKey,
        removedValue: removedValue,
      ),
      changeSource: changeSource,
    );
  }


  // Convert this attribute to a json value
  @override
  dynamic toJson() {
    return List.from(_value);
  }

  // Load this attribute from a json value
  TFC_InstanceOfAttributeSet.fromJson({
    required String itemType,
    required String itemID,
    required String attributeKey,
    required TFC_SyncLevel syncLevel,
    required dynamic json,
  }) : super.fromJson(
        itemType: itemType,
        itemID: itemID,
        attributeKey: attributeKey,
        syncLevel: syncLevel,
        json: json,
      ) {
        _value = Set.from(json);
      }
}