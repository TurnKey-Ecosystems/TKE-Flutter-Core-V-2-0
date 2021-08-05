import 'TFC_AllItemsManager.dart';

// The current legal change types
enum TFC_ChangeType {
  ITEM_CREATE,
  ITEM_DELETE,
  ATTRIBUTE_PROPERTY_SET,
  ATTRIBUTE_SET_ADD,
  ATTRIBUTE_SET_REMOVE,
}


// Describes a change made to items
class TFC_ItemChangeLog {
  // The change details for the specifc type of change
  final Map<String, dynamic> _changeDetails;


  // Versioning
  static const int CURRENT_API_VERSION = 1;
  static const String API_VERSION_KEY = "apiVersion";
  int get apiVersion {
    return _changeDetails[API_VERSION_KEY]!;
  }


  // The type of change
  static const String CHANGE_TYPE_KEY = "changeTypeIndex";
  TFC_ChangeType get changeType {
    return TFC_ChangeType.values[_changeDetails[CHANGE_TYPE_KEY]!];
  }


  // The time, in milliseconds since epoch, this change was made
  static const String CHANGE_TIME_POSIX_KEY = "changeTimePosix";
  int get changeTimePosix {
    return _changeDetails[CHANGE_TIME_POSIX_KEY]!;
  }


  // The itemID of the item that was changed
  static const String ITEM_ID_KEY = TFC_AllItemsManager.ITEM_ID_KEY;
  String? get itemID {
    return _changeDetails[ITEM_ID_KEY];
  }


  // The attributeKey of the attribute that was changed
  static const String ATTRIBUTE_KEY_KEY = "attributeKey";
  String? get attributeKey {
    return _changeDetails[ATTRIBUTE_KEY_KEY];
  }


  // A generic value related to the type of change
  static const String VALUE_KEY = "value";
  dynamic get value {
    return _changeDetails[VALUE_KEY];
  }

  
  // This constructor should only be used internally
  TFC_ItemChangeLog._fromChangeDetailsMap(this._changeDetails);
  
  // This constructor should only be used internally
  factory TFC_ItemChangeLog._createNew({
    required TFC_ChangeType changeType,
    String? itemID = null,
    String? attributeKey = null,
    dynamic value = null,
  }) {
    // Create the known change details
    Map<String, dynamic> changeDetails = {
      API_VERSION_KEY: CURRENT_API_VERSION,
      CHANGE_TYPE_KEY: changeType.index,
      CHANGE_TIME_POSIX_KEY: DateTime.now().millisecondsSinceEpoch,
    };

    // When they exist, add the other change details
    if (itemID != null) {
      changeDetails[ITEM_ID_KEY] = itemID;
    }
    if (attributeKey != null) {
      changeDetails[ATTRIBUTE_KEY_KEY] = attributeKey;
    }
    if (value != null) {
      changeDetails[VALUE_KEY] = value;
    }

    // Return the new change details
    return TFC_ItemChangeLog._fromChangeDetailsMap(changeDetails);
  }

  // Creates a new item deleteion change log
  factory TFC_ItemChangeLog.newItemCreationLog({
    required String itemID,
  }) {
    return TFC_ItemChangeLog._createNew(
      changeType: TFC_ChangeType.ITEM_CREATE,
      itemID: itemID,
    );
  }
  
  // Creates a new item deleteion change log
  factory TFC_ItemChangeLog.newItemDeletionLog({
    required String itemID,
  }) {
    return TFC_ItemChangeLog._createNew(
      changeType: TFC_ChangeType.ITEM_DELETE,
      itemID: itemID,
    );
  }
  
  // Creates a new AttributeProperty set change log
  factory TFC_ItemChangeLog.newAttributePropertySetLog({
    required String itemID,
    required String attributeKey,
    required dynamic newValue,
  }) {
    return TFC_ItemChangeLog._createNew(
      changeType: TFC_ChangeType.ATTRIBUTE_PROPERTY_SET,
      itemID: itemID,
      attributeKey: attributeKey,
      value: newValue,
    );
  }
  
  // Creates a new AttributeSet add change log
  factory TFC_ItemChangeLog.newAttributeSetAddLog({
    required String itemID,
    required String attributeKey,
    required dynamic addedValue,
  }) {
    return TFC_ItemChangeLog._createNew(
      changeType: TFC_ChangeType.ATTRIBUTE_SET_ADD,
      itemID: itemID,
      attributeKey: attributeKey,
      value: addedValue,
    );
  }
  
  // Creates a new AttributeSet remove change log
  factory TFC_ItemChangeLog.newAttributeSetRemoveLog({
    required String itemID,
    required String attributeKey,
    required dynamic removedValue,
  }) {
    return TFC_ItemChangeLog._createNew(
      changeType: TFC_ChangeType.ATTRIBUTE_SET_REMOVE,
      itemID: itemID,
      attributeKey: attributeKey,
      value: removedValue,
    );
  }


  // Creates a change log object based on a change log json
  factory TFC_ItemChangeLog.fromJson(dynamic json) {
    return TFC_ItemChangeLog._fromChangeDetailsMap(json);
  }

  // Covnerts this change log to a json
  dynamic toJson() {
    return Map.from(_changeDetails);
  }
}