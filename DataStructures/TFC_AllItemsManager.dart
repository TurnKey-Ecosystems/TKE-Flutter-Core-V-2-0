import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../AppManagment/TFC_DiskController.dart';
import '../AppManagment/TFC_FlutterApp.dart';
import '../Serialization/TFC_AutoSaving.dart';
import '../Utilities/TFC_Event.dart';
import 'package:tuple/tuple.dart';
import 'TFC_SyncDepth.dart';
import '../AppManagment/TFC_SyncController.dart';
import 'TFC_Change.dart';



/* Item changes made by this device are handled slightly differently than item
 * changes recieved form the cloud. */
enum TFC_ChangeSource { DEVICE, CLOUD }


// Manages all item instances, only touch this if you know what you are doing.
abstract class TFC_AllItemsManager {
  static const String ITEM_ID_DIVIDER = "-";

  // Item Instances
  static Map<String, TFC_SingleItemManager> _itemInstances = Map();


  // The itemIDs belonging to each itemType
  static Map<String, Set<String>> _itemIDsForEachItemType = {};


  // Gets the itemIDs belonging to the given itemType
  static Set<String> getItemIDsForItemType(String itemType) {
    if (_itemIDsForEachItemType[itemType] == null) {
      return {};
    } else {
      return Set.from(_itemIDsForEachItemType[itemType]!);
    }
  }


  // Return the instance of the requested item
  static TFC_SingleItemManager? getItemInstance(String itemID) {
    return _itemInstances[itemID];
  }


  // On item of type created or destroyed events
  static Map<String, TFC_Event> _onItemOfTypeCreatedOrDestroyedEvent = {};
  static TFC_Event getOnItemOfTypeCreatedOrDestroyedEvent({
    required String itemType,
  }) {
    // These events are lazy-loaded
    if (!_onItemOfTypeCreatedOrDestroyedEvent.containsKey(itemType)) {
      _onItemOfTypeCreatedOrDestroyedEvent[itemType] = TFC_Event();
    }
    return _onItemOfTypeCreatedOrDestroyedEvent[itemType]!;
  }


  // Perform any necessary setup for TFC_AllItemsManager 
  static void setupAllItemsManager() {
    // Load all existing item files
    List<String> itemFileNames = TFC_DiskController.getLocalFileNamesFromFileExtension(TFC_SingleItemManager._FILE_EXTENTION);
    debugPrint(jsonEncode(itemFileNames));
    for (String itemFileName in itemFileNames) {
      // Load the item instance
      TFC_SingleItemManager itemInstance = TFC_SingleItemManager._fromFile(
        fileName: itemFileName,
      );
      _itemInstances[itemInstance.itemID] = itemInstance;

      // Record the itemId under its item type
      debugPrint("itemType: ${itemInstance.itemType}");
      if (_itemIDsForEachItemType[itemInstance.itemType] == null) {
        _itemIDsForEachItemType[itemInstance.itemType] = {};
      }
      _itemIDsForEachItemType[itemInstance.itemType]!.add(itemInstance.itemID);
    }
    for (String itemType in _itemIDsForEachItemType.keys) {
      debugPrint("${itemType}: ${jsonEncode(List.from(_itemIDsForEachItemType[itemType]!))}");
    }
  }


  /** Applies any relevant changes from the list */
  static void applyChangesIfRelevant({
    required List<TFC_Change> changes,
  }) {
    // Sort the changes into different collections
    Map<String, TFC_ChangeItemCreation> itemCreationChanges = {};
    Map<String, TFC_ChangeItemDeletion> itemDeletionChanges = {};
    Map<String, List<TFC_ChangeAttributeInit>> attributeInitChanges = {};
    List<TFC_ChangeAttributeUpdate> attributeUpdateChanges = [];
    for (TFC_Change change in changes) {
      switch(change.changeType) {
        // Add to the item creation changes collection
        case TFC_ChangeType.ITEM_CREATION:
          itemCreationChanges[change.itemID] = change as TFC_ChangeItemCreation;
          break;
          
        // Add to the item deletion changes collection
        case TFC_ChangeType.ITEM_DELETION:
          itemDeletionChanges[change.itemID] = change as TFC_ChangeItemDeletion;
          break;

        // Add to the attribute init changes collection
        case TFC_ChangeType.ATTRIBUTE_INIT:
          if (!attributeInitChanges.containsKey(change.itemID)) {
            attributeInitChanges[change.itemID] = [];
          }
          attributeInitChanges[change.itemID]!.add(change as TFC_ChangeAttributeInit);
          break;
        
        // Add to the attribute init update collection
        case TFC_ChangeType.ATTRIBUTE_SET_VALUE:
        case TFC_ChangeType.ATTRIBUTE_ADD_VALUE:
        case TFC_ChangeType.ATTRIBUTE_REMOVE_VALUE:
          attributeUpdateChanges.add(change as TFC_ChangeAttributeUpdate);
          break;
      }
    }

    // Discard any item creations that are going to be shortly deleted
    for (String itemID in itemDeletionChanges.keys) {
      if (itemCreationChanges.containsKey(itemID)) {
        itemCreationChanges.remove(itemID);
      }
      if (attributeInitChanges.containsKey(itemID)) {
        attributeInitChanges.remove(itemID);
      }
    }

    // Apply any relevant attribute inits to existing items
    for (String itemID in attributeInitChanges.keys) {
      if (_itemInstances.containsKey(itemID)) {
        for (TFC_ChangeAttributeInit attributeInit in attributeInitChanges[itemID]!) {
          if (!_itemInstances[itemID]!._attributes.containsKey(attributeInit.attributeKey)) {
            // Create the new attribute
            TFC_InstanceOfAttribute newAttribute = TFC_InstanceOfAttribute._createNew(
              attributeInitDetails: attributeInit,
            );

            // Apply the attribtue to the session
            _itemInstances[itemID]!._attributes[attributeInit.attributeKey] = newAttribute;

            // Apply the attribute to the device
            if (attributeInit.changeApplicationDepth.index >= TFC_SyncDepth.DEVICE.index) {
              TFC_SingleItemManager._updateAttributeValueInDeviceStorage(attribute: newAttribute);
            }

            // Apply the attribute to the device
            if (attributeInit.changeApplicationDepth.index >= TFC_SyncDepth.CLOUD.index) {
              TFC_SyncController.commitChange(attributeInit);
            }
          }
        }
      }
    }

    // Apply any relevant item creations
    for (TFC_ChangeItemCreation itemCreationChange in itemCreationChanges.values) {
      if (!_itemInstances.containsKey(itemCreationChange.itemID)) {
        // Create the item instance
        TFC_SingleItemManager itemInstance = TFC_SingleItemManager._createNewItem(
          itemCreationChange: itemCreationChange,
          attributeInitChanges: attributeInitChanges[itemCreationChange.itemID] ?? [],
        );

        // Add the item instance to list of item instances
        _itemInstances[itemInstance.itemID] = itemInstance;

        // The itemID lists for each itemType are lazy loaded
        if (!_itemIDsForEachItemType.containsKey(itemInstance.itemType)) {
          _itemIDsForEachItemType[itemInstance.itemType] = {};
        }

        // Add this item's itemID to the list of itemIDs for its itemType
        _itemIDsForEachItemType[itemInstance.itemType]!.add(itemInstance.itemID);

        // Trigger the item type creation event
        getOnItemOfTypeCreatedOrDestroyedEvent(itemType: itemCreationChange.itemType).trigger();
      }
    }

    // Apply any relevant attribute update chagnes
    for (TFC_ChangeAttributeUpdate change in attributeUpdateChanges) {
      if (
        _itemInstances.containsKey(change.itemID)
        && _itemInstances[change.itemID]!._attributes.containsKey(change.attributeKey)
      ) {
        _itemInstances[change.itemID]!._attributes[change.attributeKey]!._applyChangeIfRelevant(change);
      }
    }

    // Apply any relevant item deletions
    for (TFC_ChangeItemDeletion change in itemDeletionChanges.values) {
      if (_itemInstances.containsKey(change.itemID)) {
        // Let listenners know that this item is being deleted
        _itemInstances[change.itemID]!.onDelete.trigger();

        // Commit this change
        if (change.changeApplicationDepth.index >= TFC_SyncDepth.CLOUD.index) {
          TFC_SyncController.commitChange(change);
        }

        // Delete the local save file
        if (change.changeApplicationDepth.index >= TFC_SyncDepth.DEVICE.index) {
          TFC_DiskController.deleteFile(TFC_SingleItemManager._getItemFileName(itemID: change.itemID));
        }

        // Remove the item instance from the list of item instances
        _itemInstances.remove(change.itemID);

        // Remove this item's itemID form the list of itemIDs of items of its type
        if (_itemIDsForEachItemType.containsKey(change.itemType)) {
          _itemIDsForEachItemType[change.itemType]!.remove(change.itemID);
        }

        // Trigger the item type deletion event
        getOnItemOfTypeCreatedOrDestroyedEvent(itemType: change.itemType).trigger();
      }
    }
  }


  /** Generate a new itemID */
  static String requestNewItemID({
    required String itemType,
  }) {
    TFC_AutoSavingProperty<int> nextItemIndex = TFC_AutoSavingProperty(
      initialValue: 0,
      fileNameWithoutExtension: "next" + itemType + "ItemIDIndex",
    );
    String itemID =
      itemType
      + ITEM_ID_DIVIDER
      + TFC_FlutterApp.deviceID.value
      + ITEM_ID_DIVIDER
      + nextItemIndex.value.toString().padLeft(10, "0");
    nextItemIndex.value++;
    return itemID;
  }
}









/** Manages a local item instance */
class TFC_SingleItemManager {
  static const String _FILE_EXTENTION = ".itm";
  static const String ITEM_TYPE_KEY = "itemType";
  static const String ITEM_ID_KEY = "itemID";
  static const String ATTRIBUTES_KEY = "attributes";

  // Item type
  late final String itemType;

  // Item ID
  late final String itemID;


  /** All the attributes in this item. */
  Map<String, TFC_InstanceOfAttribute> _attributes = Map();

  /** Retrieves an instance of an attribute */
  TFC_InstanceOfAttribute? getAttributeInstance({
    required String attributeKey,
  }) {
    return _attributes[attributeKey];
  }
  
  /** This will be triggered when this item is deleted */
  TFC_Event onDelete = TFC_Event();


  /** Creates a new item */
  TFC_SingleItemManager._createNewItem({
    required TFC_ChangeItemCreation itemCreationChange,
    required List<TFC_ChangeAttributeInit> attributeInitChanges,
  }) {
    // Apply changes at the session depth
    this.itemType = itemCreationChange.itemType;
    this.itemID = itemCreationChange.itemID;
    for (TFC_ChangeAttributeInit attributeInit in attributeInitChanges) {
      _attributes[attributeInit.attributeKey] = TFC_InstanceOfAttribute._createNew(
        attributeInitDetails: attributeInit,
      );
    }

    // Apply changes at the device depth
    if (itemCreationChange.changeApplicationDepth.index >= TFC_SyncDepth.CLOUD.index) {
      // Add the item creation change
      List<TFC_Change> changesToCommitToTheCloud = [ itemCreationChange ];

      // Add the cloud depth attribute inits
      for (TFC_ChangeAttributeInit attributeInit in attributeInitChanges) {
        if (attributeInit.changeApplicationDepth.index >= TFC_SyncDepth.DEVICE.index) {
          changesToCommitToTheCloud.add(attributeInit);
        }
      }

      // Commit the changes
      TFC_SyncController.commitChanges(changesToCommitToTheCloud);
    }
    
    // Apply changes at the device depth
    if (itemCreationChange.changeApplicationDepth.index >= TFC_SyncDepth.DEVICE.index) {
      // Generate a file name
      String fileName = _getItemFileName(itemID: itemID);

      // Convert the item instance into a json
      Map<String, dynamic> json = Map();
      json[ITEM_TYPE_KEY] = this.itemType;
      json[ITEM_ID_KEY] = this.itemID;

      // Add all the attributes to the json
      Map<String, dynamic> attributesAsJson = Map();
      for (TFC_ChangeAttributeInit attributeInit in attributeInitChanges) {
        if (attributeInit.changeApplicationDepth.index >= TFC_SyncDepth.DEVICE.index) {
          TFC_InstanceOfAttribute attribute = _attributes[attributeInit.attributeKey]!;
          attributesAsJson[attribute.attributeKey] = attribute.toJson();
        }
      }
      json[ATTRIBUTES_KEY] = attributesAsJson;

      // Save the new item instance locally
      TFC_DiskController.writeFileAsString(fileName, jsonEncode(json));
    }
  }


  /** Loads a item instance from a json object */
  TFC_SingleItemManager._fromJson(dynamic json) {
    // Extract the itemType and itemID
    this.itemType = json[ITEM_TYPE_KEY];
    this.itemID = json[ITEM_ID_KEY];
    
    // Parse the attributes from the json
    Map<String, dynamic> attributesFromJson = json[ATTRIBUTES_KEY];
    for (String attributeKey in attributesFromJson.keys) {
      dynamic attributeAsJson = attributesFromJson[attributeKey];
      _attributes[attributeKey] = TFC_InstanceOfAttribute._fromJson(
        itemID: itemID,
        attributeKey: attributeKey,
        attributeAsJson: attributeAsJson,
      );
    }
  }


  // Loads an item instance from a file.
  factory TFC_SingleItemManager._fromFile({required String fileName}) {
    // Read in the file
    Map<String, dynamic> json = jsonDecode(TFC_DiskController.readFileAsString(fileName)!);

    // If it looks correct, then parse it
    if (json.containsKey(ATTRIBUTES_KEY)) {
      return TFC_SingleItemManager._fromJson(json);
    
    // Import old item files
    } else {
      // We'll create a new item.
      String itemType = json[ITEM_TYPE_KEY];
      String itemID = json[ITEM_ID_KEY];
      TFC_ChangeItemCreation itemCreationChange = TFC_ChangeItemCreation(
        itemType: itemType,
        itemID: itemID,
        changeApplicationDepth: TFC_SyncDepth.CLOUD,
      );

      // Import all the old attributes
      List<TFC_ChangeAttributeInit> attributeInitChanges = [];
      List<TFC_ChangeAttributeUpdate> attributeUpdateChanges = [];
      for (String attributeKey in json.keys) {
        if (attributeKey != ITEM_TYPE_KEY && attributeKey != ITEM_ID_KEY) {
          // Read in the old value
          dynamic oldAttributeValue = json[attributeKey];

          // Attribute's of type Set need to be initialized and have all their values added back in.
          if (oldAttributeValue is Set || oldAttributeValue is List) {
            // Add the init change
            attributeInitChanges.add(
              TFC_ChangeAttributeInit.set(
                changeApplicationDepth: TFC_SyncDepth.CLOUD,
                itemID: itemID,
                attributeKey: attributeKey,
              ),
            );

            // Add all the elements back
            for (dynamic element in oldAttributeValue) {
              attributeUpdateChanges.add(
                TFC_ChangeAttributeAddValue(
                  changeApplicationDepth: TFC_SyncDepth.CLOUD,
                  itemID: itemID,
                  attributeKey: attributeKey,
                  value: element,
                ),
              );
            }
          
          // Create a property type attribute
          } else {
            attributeInitChanges.add(
              TFC_ChangeAttributeInit.property(
                changeApplicationDepth: TFC_SyncDepth.CLOUD,
                itemID: itemID,
                attributeKey: attributeKey,
                value: oldAttributeValue,
              ),
            );
          }
        }
      }

      // Create the new item
      TFC_SingleItemManager item = TFC_SingleItemManager._createNewItem(
        itemCreationChange: itemCreationChange,
        attributeInitChanges: attributeInitChanges,
      );

      // Add all Set Attribute elements back in
      item._applyChangesIfRelevant(attributeUpdateChanges);

      // Return the new item
      return item;
    }
  }


  /** */
  void _applyChangesIfRelevant(List<TFC_ChangeAttributeUpdate> attributeChanges) {
    for (TFC_ChangeAttributeUpdate attributeUpdate in attributeChanges) {
      if (_attributes.containsKey(attributeUpdate.attributeKey)) {
        bool changeWasRelevant = 
          _attributes[attributeUpdate.attributeKey]!._applyChangeIfRelevant(attributeUpdate);
        
      }
    }
  }

  /** Updates the value of an attribute in device storage */
  static void _updateAttributeValueInDeviceStorage({required TFC_InstanceOfAttribute attribute}) {
    String itemFileName = _getItemFileName(itemID: attribute.itemID);

    // Read in the item file
    Map<String, dynamic> itemJson = jsonDecode(TFC_DiskController.readFileAsString(itemFileName)!);

    // Update the attributes value
    itemJson[ATTRIBUTES_KEY][attribute.attributeKey] = attribute.toJson();

    // Save the updated item json.
    TFC_DiskController.writeFileAsString(itemFileName, jsonEncode(itemJson));
  }

  /** Generates the file name for the given item */
  static String _getItemFileName({required String itemID}) {
    return itemID + _FILE_EXTENTION;
  }
}








/** These are the basic types of allowed attributes. */
enum TFC_AttributeType { PROPERTY, SET }


/** Manages an instance of an either a property or a set attribute. */
class TFC_InstanceOfAttribute {
  // The itemID of the item this attribute is associated with
  final String itemID;

  // The attributeKey of this attribute
  final String attributeKey;
  
  // On after change Event
  final TFC_Event onAfterChange = TFC_Event();


  /** We keep this attribute as a json map, and just modify the values in the json. */
  Map<String, dynamic> _attributeAsJson;
  
  /** This is the key to use for storing the last time this attribute was changed. */
  static const String _TIME_OF_LAST_CHANGE_JSON_KEY = "timeOfLastChangePosix";

  /** This attribute serializes to an object. This is the json key of this
   * attribute's value. */
  static const String _VALUE_JSON_KEY = "value";


  /** Retrieves this attribute as if it was a property attribute. */
  dynamic get valueAsProperty {
    return _attributeAsJson[_VALUE_JSON_KEY];
  }

  /** Checks if the change is relevant, and, if so, sets this attribute's value. */
  bool _setValueIfRelevant({
    required dynamic value,
    required int changeTimePosix,
  }) {
    bool wasRelevant = false;

    // Grab the current value for comparison
    dynamic currentValue = _attributeAsJson[_VALUE_JSON_KEY];
    int currentChangeTimePosix = _attributeAsJson[_TIME_OF_LAST_CHANGE_JSON_KEY];

    // If the new value is more recent and different, then it is relevant
    if (
      changeTimePosix > currentChangeTimePosix
      && value != currentValue
    ) {
      _attributeAsJson[_VALUE_JSON_KEY] = value;
      _attributeAsJson[_TIME_OF_LAST_CHANGE_JSON_KEY] = changeTimePosix;
      wasRelevant = true;
    }

    // Let the caller know whether or not the change was relevant
    return wasRelevant;
  }


  /** This attribute serializes to an object. This is the json key of this
   * attribute's value. */
  static const String _REMOVED_VALUES_JSON_KEY = "removedValues";

  /** Get all the values in this attribute as if it was a Set. */
  Set<ExpectedType> getAllValuesAsSet<ExpectedType>() {
    return Set.from(_attributeAsJson[_VALUE_JSON_KEY].keys);
  }

  /** Checks if the change is relevant, and, if so, adds the value to this set. */
  bool _addValueIfRelevant({
    required dynamic value,
    required int changeTimePosix,
  }) {
    bool wasRelevant = false;

    // Grab the current value for comparison
    bool isInSet = _attributeAsJson[_VALUE_JSON_KEY][value] != null;
    int currentChangeTimePosix = (isInSet)
      ? _attributeAsJson[_VALUE_JSON_KEY][value]
      : _attributeAsJson[_REMOVED_VALUES_JSON_KEY][value] ?? 0;

    // If the new value is more recent, then we at least want to update the change time
    if (changeTimePosix > currentChangeTimePosix ) {
      _attributeAsJson[_VALUE_JSON_KEY][value] = changeTimePosix;

      // The add was only relevant if it actually changed the list
      wasRelevant = !isInSet;

      // The value is back in the set now, so we can remove its deletion time
      if (_attributeAsJson[_REMOVED_VALUES_JSON_KEY].containsKey(value)) {
        _attributeAsJson[_REMOVED_VALUES_JSON_KEY].remove(value);
      }
    }

    // Let the caller know whether or not the change was relevant
    return wasRelevant;
  }

  /** Checks if the change is relevant, and, if so, removes the value from this set. */
  bool _removeValue({
    required dynamic value,
    required int changeTimePosix,
  }) {
    bool wasRelevant = false;

    // Grab the current value for comparison
    bool isInSet = _attributeAsJson[_VALUE_JSON_KEY][value] != null;
    int currentChangeTimePosix = (isInSet)
      ? _attributeAsJson[_VALUE_JSON_KEY][value]
      : _attributeAsJson[_REMOVED_VALUES_JSON_KEY][value] ?? 0;

    // If the new value is more recent, then we at least want to update the change time
    if (changeTimePosix > currentChangeTimePosix ) {
      _attributeAsJson[_REMOVED_VALUES_JSON_KEY][value] = changeTimePosix;

      // The remove was only relevant if it actually changed the list
      wasRelevant = isInSet;

      // Remove the value from the set
      if (_attributeAsJson[_VALUE_JSON_KEY].containsKey(value)) {
        _attributeAsJson[_VALUE_JSON_KEY].remove(value);
      }
    }

    // Let the caller know whether or not the change was relevant
    return wasRelevant;
  }


  /** All children should override this */
  Map<String, dynamic> toJson() {
    return _attributeAsJson;
  }
  
  /** Sets up a new attibute based on a json. */
  TFC_InstanceOfAttribute._fromJson({
    required this.itemID,
    required this.attributeKey,
    required Map<String, dynamic> attributeAsJson,
  }) : _attributeAsJson = attributeAsJson;
  
  /** Sets up a new attibute based on a change. */
  TFC_InstanceOfAttribute._createNew({
    required TFC_ChangeAttributeInit attributeInitDetails
  }) : this.itemID = attributeInitDetails.itemID,
      this.attributeKey = attributeInitDetails.attributeKey,
      this._attributeAsJson = Map()
  {
    // Different types of attributes need to be setup differently
    switch(attributeInitDetails.attributeType) {
      // Setup a set attribute
      case TFC_AttributeType.PROPERTY:
      _attributeAsJson[_VALUE_JSON_KEY] = attributeInitDetails.value;
      _attributeAsJson[_TIME_OF_LAST_CHANGE_JSON_KEY] = 0;
      break;

      // Setup a basic value attribute
      case TFC_AttributeType.SET:
      _attributeAsJson[_VALUE_JSON_KEY] = Map();
      _attributeAsJson[_REMOVED_VALUES_JSON_KEY] = Map();
      _attributeAsJson[_TIME_OF_LAST_CHANGE_JSON_KEY] = 0;
      break;
    }
  }


  /** Checks if the given change is relevant, and applies it. Returns whether or
   * not the change was relevant */
  bool _applyChangeIfRelevant(TFC_ChangeAttributeUpdate change) {
    bool wasRelevant = false;

    // Apply this change
    switch (change.changeType) {
      // Set value
      case TFC_ChangeType.ATTRIBUTE_SET_VALUE:
      wasRelevant = _setValueIfRelevant(
        value: change.value,
        changeTimePosix: change.changeTimePosix,
      );
      break;

      // Add to Set
      case TFC_ChangeType.ATTRIBUTE_ADD_VALUE:
      wasRelevant = _addValueIfRelevant(
        value: change.value,
        changeTimePosix: change.changeTimePosix,
      );
      break;

      // Remove from Set
      case TFC_ChangeType.ATTRIBUTE_REMOVE_VALUE:
      wasRelevant = _removeValue(
        value: change.value,
        changeTimePosix: change.changeTimePosix,
      );
      break;

      // Theoretically we shouldn't get any non-attribute update change types
      case TFC_ChangeType.ATTRIBUTE_INIT:
      case TFC_ChangeType.ITEM_CREATION:
      case TFC_ChangeType.ITEM_DELETION:
      throw("TFC_InstanceOfAttribute.applyChangeIfRelevant() recieved an attribute of class \"TFC_ChangeAttributeUpdate\" but change type ${change.changeType}");
    }
    
    // Perform requested if-relevant actiosn
    if (wasRelevant) {
      // Save this change locally
      if (change.changeApplicationDepth.index >= TFC_SyncDepth.DEVICE.index) {
        TFC_SingleItemManager._updateAttributeValueInDeviceStorage(attribute: this);
      }

      // Commit this change
      if (change.changeApplicationDepth == TFC_SyncDepth.CLOUD) {
        TFC_SyncController.commitChange(change);
      }

      // Let listeners know that this attribute has been changed
      onAfterChange.trigger();
    }

    // Tell the caller whether or not this change was relevant.
    return wasRelevant;
  }
}
