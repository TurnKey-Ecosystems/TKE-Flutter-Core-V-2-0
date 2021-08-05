import 'dart:convert';
import '../Utilities/TFC_Event.dart';
import 'package:tuple/tuple.dart';
import 'TFC_ItemChangeLog.dart';
import '../AppManagment/TFC_DiskController.dart';
import 'Attributes/TFC_InstanceOfAttribute.dart';
import 'TFC_AllItemsManager.dart';
import 'TFC_SyncLevel.dart';

// Manages a local item instance
class TFC_SingleItemManager {
  // Some item constants
  static const Set<TFC_SyncLevel> _LOCALLY_SAVED_SYNCLEVELS = const { TFC_SyncLevel.CLOUD, TFC_SyncLevel.DEVICE };


  // Item type
  late final String itemType;


  // Item ID
  late final String itemID;


  // Attributes by SyncLevel
  Map<String, TFC_InstanceOfAttribute> _cloudSyncedAttributes = Map();
  Map<String, TFC_InstanceOfAttribute> _deviceSyncedAttributes = Map();
  Map<String, TFC_InstanceOfAttribute> _sessionSyncedAttributes = Map();
  Map<String, TFC_InstanceOfAttribute> getAttributesAtSyncLevel(TFC_SyncLevel syncLevel) {
    switch(syncLevel) {
      case TFC_SyncLevel.CLOUD:
        return _cloudSyncedAttributes;
      case TFC_SyncLevel.DEVICE:
        return _deviceSyncedAttributes;
      case TFC_SyncLevel.SESSION:
        return _sessionSyncedAttributes;
    }
  }


  // This should only be called by TFC_Item. Ensures that the given session attibutes exist.
  void ensureSessionAttributesHaveBeenInitialized(Map<String, dynamic> initialSessionAttributeValues) {
    // Setup all the attributes
    for (String attributeKey in initialSessionAttributeValues.keys) {
      dynamic attributeValue = initialSessionAttributeValues[attributeKey];
      if (!_sessionSyncedAttributes.containsKey(attributeKey)) {
        _addAttribute(
          syncLevel: TFC_SyncLevel.SESSION,
          attributeKey: attributeKey,
          attributeValue: attributeValue,
        );
      }
    }
  }


  // Creates a new item
  TFC_SingleItemManager.createNewItem({
    required this.itemType,
    required this.itemID,
    required Map<String, Tuple2<TFC_SyncLevel, dynamic>> initialAttributeValues,
    required TFC_ChangeSource changeSource,
  }) {
    // Setup all the attributes
    for (String attributeKey in initialAttributeValues.keys) {
      TFC_SyncLevel syncLevel = initialAttributeValues[attributeKey]!.item1;
      dynamic attributeValue = initialAttributeValues[attributeKey]!.item2;
      _addAttribute(
        syncLevel: syncLevel,
        attributeKey: attributeKey,
        attributeValue: attributeValue,
      );
    }

    // Log this item createion
    if (changeSource == TFC_ChangeSource.DEVICE) {
      List<TFC_ItemChangeLog> creationChangeLogs = [];

      // Log the fact that the item was created
      creationChangeLogs.add(
        TFC_ItemChangeLog.newItemCreationLog(itemID: itemID),
      );

      // Log the inital value of each attribute
      for (String attributeKey in initialAttributeValues.keys) {
        TFC_SyncLevel syncLevel = initialAttributeValues[attributeKey]!.item1;
        if (syncLevel != TFC_SyncLevel.SESSION) {
          dynamic attributeValue = initialAttributeValues[attributeKey]!.item2;
          if (attributeValue is List || attributeValue is Set) {
            for (dynamic element in attributeValue) {
              creationChangeLogs.add(
                TFC_ItemChangeLog.newAttributeSetAddLog(
                  itemID: itemID,
                  attributeKey: attributeKey,
                  addedValue: element,
                ),
              );
            }
          } else {
            creationChangeLogs.add(
              TFC_ItemChangeLog.newAttributePropertySetLog(
                itemID: itemID,
                attributeKey: attributeKey,
                newValue: attributeValue,
              ),
            );
          }
        }
      }
    }
    // TODO: Add to sync change logs here.

    // Only once logs have been created do we save the new item
    _saveItemToFile();
  }


  // Loads an item instance from a file.
  TFC_SingleItemManager.fromFile({required String fileName}) {
    // Read in the file
    Map<String, dynamic> json = jsonDecode(TFC_DiskController.readFileAsString(fileName)!);

    // Extract the itemType and itemID
    this.itemType = json[TFC_AllItemsManager.ITEM_TYPE_KEY];
    this.itemID = json[TFC_AllItemsManager.ITEM_ID_KEY];
    
    // Parse the json
    if (
      json.containsKey(TFC_SyncLevel.CLOUD.attributesMapKey)
      || json.containsKey(TFC_SyncLevel.DEVICE.attributesMapKey)
    ) {
      // Extract the attributes for each sync level
      for (TFC_SyncLevel syncLevel in _LOCALLY_SAVED_SYNCLEVELS) {
        Map<String, dynamic> attributes = json[syncLevel.attributesMapKey];
        for (String attributeKey in attributes.keys) {
          dynamic attributeValue = attributes[attributeKey];
          _addAttribute(
            syncLevel: syncLevel,
            attributeKey: attributeKey,
            attributeValue: attributeValue,
          );
        }
      }
    
    // Import old item files as cloud synced attributes
    } else {
      for (String attributeKey in json.keys) {
        if (
          attributeKey != TFC_AllItemsManager.ITEM_TYPE_KEY
          && attributeKey != TFC_AllItemsManager.ITEM_ID_KEY
        ) {
          dynamic attributeValue = json[attributeKey];
          _addAttribute(
            syncLevel: TFC_SyncLevel.CLOUD,
            attributeKey: attributeKey,
            attributeValue: attributeValue,
          );
        }
      }
      _saveItemToFile();
    }

  }


  // Both create a new item and loading one from a file add attributes in the same way
  void _addAttribute({
    required TFC_SyncLevel syncLevel,
    required String attributeKey,
    required dynamic attributeValue,
  }) {
      TFC_InstanceOfAttribute attributeInstance = (attributeValue is List)
        ? TFC_InstanceOfAttributeSet.fromJson(
            itemType: itemType,
            itemID: itemID,
            attributeKey: attributeKey,
            syncLevel: syncLevel,
            json: attributeValue,
          )
        : TFC_InstanceOfAttributeProperty.fromJson(
            itemType: itemType,
            itemID: itemID,
            attributeKey: attributeKey,
            syncLevel: syncLevel,
            json: attributeValue,
          );
      if (syncLevel != TFC_SyncLevel.SESSION) {
        attributeInstance.onAfterChange.addListener(_saveItemToFile);
      }
      getAttributesAtSyncLevel(syncLevel)[attributeKey] = attributeInstance;
  }
  

  // Stores a file instance in a local file
  void _saveItemToFile() {
    // Get the file name
    String fileName = _generateFileName(itemID: this.itemID);

    // Convert the item instance into a json
    Map<String, dynamic> json = Map();
    json[TFC_AllItemsManager.ITEM_TYPE_KEY] = this.itemType;
    json[TFC_AllItemsManager.ITEM_ID_KEY] = this.itemID;
    for (TFC_SyncLevel syncLevel in _LOCALLY_SAVED_SYNCLEVELS) {
      Map<String, dynamic> attributesAsJson = Map();
      Map<String, TFC_InstanceOfAttribute> attributes = getAttributesAtSyncLevel(syncLevel);
      for (String attributeKey in attributes.keys) {
        attributesAsJson[attributeKey] = attributes[attributeKey]!.toJson();
      }
      json[syncLevel.attributesMapKey] = attributesAsJson;
    }

    // Save the item instance locally
    TFC_DiskController.writeFileAsString(fileName, jsonEncode(json));
  }
  

  // This will be triggered when this item is deleted
  TFC_Event onDelete = TFC_Event();

  // This should only be called by TFC_ItemManager
  void deleteItem({
    required TFC_ChangeSource changeSource,
  }) {
    // Let listeners know that this item is being deleted
    onDelete.trigger();

    // Log the item deletion
    if (changeSource == TFC_ChangeSource.DEVICE) {
        // TODO: Add to sync change logs here.
      TFC_ItemChangeLog.newItemDeletionLog(itemID: itemID);
    }

    // Delete the local item file
    TFC_DiskController.deleteFile(_generateFileName(itemID: itemID));
  }


  // Converts an itemID into an item file name
  static String _generateFileName({required String itemID}) {
    return itemID + TFC_AllItemsManager.FILE_EXTENTION;
  }
}