import 'package:flutter/cupertino.dart';
import 'TFC_AllItemsManager.dart';
import 'TFC_SyncDepth.dart';

// The current legal change types
enum TFC_ChangeType {
  ITEM_CREATION,
  ITEM_DELETION,
  ATTRIBUTE_INIT,
  ATTRIBUTE_SET_VALUE,
  ATTRIBUTE_ADD_VALUE,
  ATTRIBUTE_REMOVE_VALUE,
}


// Describes a change made to items
abstract class TFC_Change {
  // The change details for the specifc type of change
  //late final Map<String, dynamic> _changeDetails;


  // Versioning
  static const int _CURRENT_API_VERSION = 1;
  static const String _API_VERSION_KEY = "apiVersion";
  final int apiVersion;


  // The type of change
  static const String _CHANGE_TYPE_KEY = "changeTypeIndex";
  final TFC_ChangeType changeType;
  

  // The sync depth of this change
  static const String _CHANGE_APPLICATION_DEPTH_KEY = "syncDepth";
  TFC_SyncDepth changeApplicationDepth;


  // The time, in milliseconds since epoch, this change was made
  static const String _CHANGE_TIME_POSIX_KEY = "changeTimePosix";
  final int changeTimePosix;
  
  // The itemID of the item that was changed
  final String itemID;
  

  /** Create a new change object */
  TFC_Change._({
    required this.changeType,
    required this.changeApplicationDepth,
    required this.itemID,
  })
    : this.apiVersion = _CURRENT_API_VERSION,
      this.changeTimePosix = DateTime.now().millisecondsSinceEpoch;

  /** Creates a change object fron a json */
  TFC_Change._fromJson(dynamic json)
    : this.apiVersion = json[_API_VERSION_KEY],
      this.changeType =
        TFC_ChangeType.values[json[_CHANGE_TYPE_KEY]],
      this.changeApplicationDepth =
        TFC_SyncDepth.values[json[_CHANGE_APPLICATION_DEPTH_KEY]],
      this.itemID = json[TFC_SingleItemManager.ITEM_ID_KEY],
      this.changeTimePosix = json[_CHANGE_TIME_POSIX_KEY];

  /** Covnerts this change log to a json */
  @mustCallSuper
  Map<String, dynamic> toJson() {
    return {
      _API_VERSION_KEY: apiVersion,
      _CHANGE_TYPE_KEY: changeType.index,
      _CHANGE_APPLICATION_DEPTH_KEY: changeApplicationDepth.index,
      TFC_SingleItemManager.ITEM_ID_KEY: itemID,
      _CHANGE_TIME_POSIX_KEY: changeTimePosix,
    };
  }
  

  /** Load a change object from a json as the correct dart class.  */
  static TFC_Change fromJson(dynamic json) {
    TFC_ChangeType changeType = TFC_ChangeType.values[json[_CHANGE_TYPE_KEY]];
    switch(changeType) {
      case TFC_ChangeType.ITEM_CREATION:
        return TFC_ChangeItemCreation.fromJson(json);
      case TFC_ChangeType.ITEM_DELETION:
        return TFC_ChangeItemDeletion.fromJson(json);
      case TFC_ChangeType.ATTRIBUTE_INIT:
        return TFC_ChangeAttributeInit.fromJson(json);
      case TFC_ChangeType.ATTRIBUTE_SET_VALUE:
        return TFC_ChangeAttributeSetValue.fromJson(json);
      case TFC_ChangeType.ATTRIBUTE_ADD_VALUE:
        return TFC_ChangeAttributeAddValue.fromJson(json);
      case TFC_ChangeType.ATTRIBUTE_REMOVE_VALUE:
        return TFC_ChangeAttributeRemoveValue.fromJson(json);
    }
  }

  /** Get the class type corresponding to the change type.  */
  static Type changeClassFromChangeType(TFC_ChangeType changeType) {
    switch(changeType) {
      case TFC_ChangeType.ITEM_CREATION:
        return TFC_ChangeItemCreation;
      case TFC_ChangeType.ITEM_DELETION:
        return TFC_ChangeItemDeletion;
      case TFC_ChangeType.ATTRIBUTE_INIT:
        return TFC_ChangeAttributeInit;
      case TFC_ChangeType.ATTRIBUTE_SET_VALUE:
        return TFC_ChangeAttributeSetValue;
      case TFC_ChangeType.ATTRIBUTE_ADD_VALUE:
        return TFC_ChangeAttributeAddValue;
      case TFC_ChangeType.ATTRIBUTE_REMOVE_VALUE:
        return TFC_ChangeAttributeRemoveValue;
    }
  }
}



/** Item creation and deletion change types */
abstract class TFC_ChangeItemExistance extends TFC_Change {
  // The itemType of the item that was changed
  final String itemType;

  /** Creates a new item existance change. */
  TFC_ChangeItemExistance({
    required TFC_ChangeType changeType,
    required TFC_SyncDepth changeApplicationDepth,
    required this.itemType,
    required String itemID,
  })
    : super._(
      changeType: changeType,
      changeApplicationDepth: changeApplicationDepth,
      itemID: itemID,
    );

  /** Loads a item existance change from a json. */
  TFC_ChangeItemExistance.fromJson(dynamic json)
    : this.itemType = json[TFC_SingleItemManager.ITEM_TYPE_KEY],
      super._fromJson(json);
  
  /** Converts an Item existance change to a json. */
  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json[TFC_SingleItemManager.ITEM_TYPE_KEY] = itemType;
    return json;
  }
}

/** Item creation change type */
class TFC_ChangeItemCreation extends TFC_ChangeItemExistance {
  /** Creates a new item creation change object. */
  TFC_ChangeItemCreation({
    required String itemType,
    required String itemID,
    required TFC_SyncDepth changeApplicationDepth,
  })
    : super(
      changeType: TFC_ChangeType.ITEM_CREATION,
      changeApplicationDepth: changeApplicationDepth,
      itemType: itemType,
      itemID: itemID,
    );

  /** Loads an item creation change from a json. */
  TFC_ChangeItemCreation.fromJson(dynamic json) : super.fromJson(json);
}

/** Item deletion change type */
class TFC_ChangeItemDeletion extends TFC_ChangeItemExistance {
  /** Creates a new item deletion change object. */
  TFC_ChangeItemDeletion({
    required String itemType,
    required String itemID,
    required TFC_SyncDepth changeApplicationDepth,
  })
    : super(
      changeType: TFC_ChangeType.ITEM_DELETION,
      changeApplicationDepth: changeApplicationDepth,
      itemType: itemType,
      itemID: itemID,
    );

  /** Loads an item deletion change from a json. */
  TFC_ChangeItemDeletion.fromJson(dynamic json) : super.fromJson(json);
}



/** Attribute change types */
abstract class TFC_AttributeChange extends TFC_Change {
  // The type of the attribute that is being changed
  static const String _ATTRIBUTE_TYPE_KEY = "attributeType";
  final TFC_AttributeType attributeType;

  // The attributeKey of the attribute that was changed
  static const String _ATTRIBUTE_KEY_KEY = "attributeKey";
  final String attributeKey;

  // A generic value related to the type of change
  static const String _VALUE_KEY = "value";
  final dynamic value;
  

  /** Creates a new attribute change. */
  TFC_AttributeChange({
    required TFC_ChangeType changeType,
    required TFC_SyncDepth changeApplicationDepth,
    required String itemID,
    required this.attributeType,
    required this.attributeKey,
    required this.value,
  })
    : super._(
      changeType: changeType,
      changeApplicationDepth: changeApplicationDepth,
      itemID: itemID,
    );

  /** Loads an atribute change from a json. */
  TFC_AttributeChange.fromJson(dynamic json)
    : this.attributeType = TFC_AttributeType.values[json[_ATTRIBUTE_TYPE_KEY]],
      this.attributeKey = json[_ATTRIBUTE_KEY_KEY],
      this.value = json[_VALUE_KEY],
      super._fromJson(json);
  
  /** Converts an Item existance change to a json. */
  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json[_ATTRIBUTE_TYPE_KEY] = attributeType.index;
    json[_ATTRIBUTE_KEY_KEY] = attributeKey;
    json[_VALUE_KEY] = value;
    return json;
  }
}

/** Attribute-init change type */
class TFC_ChangeAttributeInit extends TFC_AttributeChange {
  /** Creates an attribute-init change for a property type attribute */
  TFC_ChangeAttributeInit.property({
    required TFC_SyncDepth changeApplicationDepth,
    required String itemID,
    required String attributeKey,
    required dynamic value,
  }) : super(
      changeType: TFC_ChangeType.ATTRIBUTE_INIT,
      changeApplicationDepth: changeApplicationDepth,
      itemID: itemID,
      attributeType: TFC_AttributeType.PROPERTY,
      attributeKey: attributeKey,
      value: value,
    );

  /** Creates an attribute-init change for a set type attribute */
  TFC_ChangeAttributeInit.set({
    required TFC_SyncDepth changeApplicationDepth,
    required String itemID,
    required String attributeKey,
  }) : super(
      changeType: TFC_ChangeType.ATTRIBUTE_INIT,
      changeApplicationDepth: changeApplicationDepth,
      itemID: itemID,
      attributeType: TFC_AttributeType.SET,
      attributeKey: attributeKey,
      value: [],
    );

  /** Loads an atribute-init change from a json. */
  TFC_ChangeAttributeInit.fromJson(dynamic json) : super.fromJson(json);
}



/** Attribute update types */
abstract class TFC_ChangeAttributeUpdate extends TFC_AttributeChange {
  /** Creates a new attribute update change. */
  TFC_ChangeAttributeUpdate({
    required TFC_ChangeType changeType,
    required TFC_SyncDepth changeApplicationDepth,
    required String itemID,
    required TFC_AttributeType attributeType,
    required String attributeKey,
    required dynamic value,
  })
    : super(
      changeType: changeType,
      changeApplicationDepth: changeApplicationDepth,
      itemID: itemID,
      attributeType: attributeType,
      attributeKey: attributeKey,
      value: value,
    );

  /** Loads an atribute update change from a json. */
  TFC_ChangeAttributeUpdate.fromJson(dynamic json) : super.fromJson(json);
}

/** Attribute set value change type */
class TFC_ChangeAttributeSetValue extends TFC_ChangeAttributeUpdate {
  /** Creates a set value change object */
  TFC_ChangeAttributeSetValue({
    required TFC_SyncDepth changeApplicationDepth,
    required String itemID,
    required String attributeKey,
    required dynamic value,
  }) : super(
      changeType: TFC_ChangeType.ATTRIBUTE_SET_VALUE,
      changeApplicationDepth: changeApplicationDepth,
      itemID: itemID,
      attributeType: TFC_AttributeType.PROPERTY,
      attributeKey: attributeKey,
      value: value,
    );

  /** Loads a set value change from a json. */
  TFC_ChangeAttributeSetValue.fromJson(dynamic json) : super.fromJson(json);
}

/** Attribute add value change type */
class TFC_ChangeAttributeAddValue extends TFC_ChangeAttributeUpdate {
  /** Creates an add value change object */
  TFC_ChangeAttributeAddValue({
    required TFC_SyncDepth changeApplicationDepth,
    required String itemID,
    required String attributeKey,
    required dynamic value,
  }) : super(
      changeType: TFC_ChangeType.ATTRIBUTE_ADD_VALUE,
      changeApplicationDepth: changeApplicationDepth,
      itemID: itemID,
      attributeType: TFC_AttributeType.SET,
      attributeKey: attributeKey,
      value: value,
    );

  /** Loads an add value change from a json. */
  TFC_ChangeAttributeAddValue.fromJson(dynamic json) : super.fromJson(json);
}

/** Attribute remove value change type */
class TFC_ChangeAttributeRemoveValue extends TFC_ChangeAttributeUpdate {
  /** Creates a remove value change object */
  TFC_ChangeAttributeRemoveValue({
    required TFC_SyncDepth changeApplicationDepth,
    required String itemID,
    required String attributeKey,
    required dynamic value,
  }) : super(
      changeType: TFC_ChangeType.ATTRIBUTE_REMOVE_VALUE,
      changeApplicationDepth: changeApplicationDepth,
      itemID: itemID,
      attributeType: TFC_AttributeType.SET,
      attributeKey: attributeKey,
      value: value,
    );

  /** Loads a remove value change from a json. */
  TFC_ChangeAttributeRemoveValue.fromJson(dynamic json) : super.fromJson(json);
}
