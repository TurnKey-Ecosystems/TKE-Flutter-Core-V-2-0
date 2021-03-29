import 'dart:convert';
//import 'dart:developer';
import '../Serialization/TFC_SerializingContainers.dart';
import '../Utilities/TFC_Event.dart';
//import '../AppManagment/TFC_SyncController.dart';
import '../AppManagment/TFC_DiskController.dart';
import 'TFC_ItemUtilities.dart';

abstract class TFC_ItemInstances {
  static Map<String, Map<String, dynamic>> _itemInstances = Map();
  static Map<String, TFC_Event> _onItemOfTypeCreatedOrDestroyed = Map();
  static Map<String, Map<String, TFC_Event>> _onBeforeAttributeGetsByItemID =
      Map();
  static Map<String, Map<String, TFC_Event>> _onAfterAttributeSetsByItemID =
      Map();

  static void loadItemInstance(String itemID) {
    if (!_itemInstances.containsKey(itemID)) {
      String itemFileName = TFC_ItemUtilities.generateFileName(itemID);
      if (TFC_DiskController.fileExists(itemFileName)) {
        // Load the file
        String encodedItemJson =
            TFC_DiskController.readFileAsString(itemFileName);
        Map decodedItemJson = jsonDecode(encodedItemJson);
        String nameOfItemType = decodedItemJson["itemType"];

        // Create an instance map for this item
        _itemInstances[itemID] = Map<String, dynamic>();

        // Setup the on change event maps for this item
        _onBeforeAttributeGetsByItemID[itemID] = Map();
        _onAfterAttributeSetsByItemID[itemID] = Map();
        for (String attributeKey in decodedItemJson.keys) {
          if (decodedItemJson[attributeKey] is List ||
              decodedItemJson[attributeKey] is Set) {
            _itemInstances[itemID][attributeKey] =
                _createSerializingSetForItemInstances(itemID, nameOfItemType,
                    attributeKey, decodedItemJson[attributeKey]);
          } else {
            _itemInstances[itemID][attributeKey] =
                decodedItemJson[attributeKey];
          }

          // Setup the on change events for this attribute
          _onBeforeAttributeGetsByItemID[itemID][attributeKey] = TFC_Event();
          _onAfterAttributeSetsByItemID[itemID][attributeKey] = TFC_Event();
          _onAfterAttributeSetsByItemID[itemID][attributeKey].addListener(() {
            saveItem(itemID);
          });
        }
      }
    }
  }

  static void unloadAllItemInstances() {
    while (_itemInstances != null && _itemInstances.keys.length > 0) {
      unloadItemInstance(_itemInstances.keys.first);
    }
  }

  static void unloadItemInstance(String itemID) {
    if (_itemInstances != null && _itemInstances.containsKey(itemID)) {
      _itemInstances.remove(itemID);
    }
  }

  static TFC_SerializingSet _createSerializingSetForItemInstances(
      String itemID, String itemType, String attributeKey, List<dynamic> json) {
    return TFC_SerializingSet.fromJson(
        onSet: () {
          saveItem(itemID);
        },
        json: json,
        onElementAdded: (dynamic element, bool shouldLogChange) {
          /*if (shouldLogChange) {
            TFC_SyncController.logElementAddedToSetAttribute(
                itemID, itemType, attributeKey, element);
          }*/
          _onAfterAttributeSetsByItemID[itemID][attributeKey].trigger();
        },
        onElementRemoved: (dynamic element, bool shouldLogChange) {
          /*if (shouldLogChange) {
            TFC_SyncController.logElementRemovedFromSetAttribute(
                itemID, itemType, attributeKey, element);
          }*/
          _onAfterAttributeSetsByItemID[itemID][attributeKey].trigger();
        });
  }

  static void addNewItemFromServerItem(
      Map<String, dynamic> itemData, String itemID) {
    String nameOfItemType = itemData["itemType"];
    String fileName = TFC_ItemUtilities.generateFileName(itemID);
    String itemAsEncodedJson = json.encode(itemData);
    TFC_DiskController.writeFileAsString(fileName, itemAsEncodedJson);
    saveItem(itemID);
    if (_onItemOfTypeCreatedOrDestroyed.containsKey(nameOfItemType)) {
      _onItemOfTypeCreatedOrDestroyed[nameOfItemType].trigger();
    }
  }

  static void addNewItemFromServerItemChange(
      Map<String, dynamic> itemDataFromServer, String itemID) {
    String itemType = itemDataFromServer["itemType"];
    Map<String, dynamic> itemsAsDecodedJson = Map();
    itemsAsDecodedJson["itemID"] = itemID;
    itemsAsDecodedJson["itemType"] = itemType;
    for (String attributeKey in itemDataFromServer["attributes"].keys) {
      dynamic attributeValue = itemDataFromServer["attributes"][attributeKey];
      itemsAsDecodedJson[attributeKey] = attributeValue;
    }
    for (String setAttributeKey in itemDataFromServer["setAttributes"].keys) {
      itemsAsDecodedJson[setAttributeKey] = [];
      for (dynamic element in itemDataFromServer["setAttributes"]
          [setAttributeKey]["addedElements"]) {
        itemsAsDecodedJson[setAttributeKey].add(element);
      }
    }
    String fileName = TFC_ItemUtilities.generateFileName(itemID);
    String itemAsEncodedJson = json.encode(itemsAsDecodedJson);
    TFC_DiskController.writeFileAsString(fileName, itemAsEncodedJson);
    saveItem(itemID);
    if (_onItemOfTypeCreatedOrDestroyed.containsKey(itemType)) {
      _onItemOfTypeCreatedOrDestroyed[itemType].trigger();
    }
  }

  static String locallyCreateNewItem(String itemType) {
    // Load the default item for this item type
    String defaultItemIDForItemOfThisType =
        TFC_ItemUtilities.getDefaultItemIDForItemType(itemType);
    String defaultItemIDForItemOfThisTypeFileName =
        TFC_ItemUtilities.generateFileName(defaultItemIDForItemOfThisType);
    Map<String, dynamic> initialItemData;
    if (TFC_DiskController.fileExists(defaultItemIDForItemOfThisTypeFileName)) {
      String encodedDefaultItemJson = TFC_DiskController.readFileAsString(
          defaultItemIDForItemOfThisTypeFileName);
      initialItemData = jsonDecode(encodedDefaultItemJson);
    } else {
      initialItemData = Map();
    }

    // Create a new item
    String itemID = TFC_ItemUtilities.generateLocalItemID(itemType);
    Map<String, dynamic> itemData = initialItemData;
    itemData["itemID"] = itemID;
    itemData["itemType"] = itemType;
    String fileName = TFC_ItemUtilities.generateFileName(itemID);
    String itemAsEncodedJson = json.encode(itemData);
    TFC_DiskController.writeFileAsString(fileName, itemAsEncodedJson);
    if (_onItemOfTypeCreatedOrDestroyed.containsKey(itemType)) {
      _onItemOfTypeCreatedOrDestroyed[itemType].trigger();
    }
    /*TFC_SyncController.logItemCreation(itemID, itemType);
    for (String attributeKey in itemData.keys) {
      if (attributeKey != "itemID") {
        if (itemData[attributeKey] is List || itemData[attributeKey] is Set) {
          for (dynamic element in itemData[attributeKey]) {
            TFC_SyncController.logElementAddedToSetAttribute(
                itemID, itemType, attributeKey, element);
          }
        } else {
          TFC_SyncController.logAttributeChange(
              itemID, itemType, attributeKey, itemData[attributeKey]);
        }
      }
    }*/
    return itemID;
  }

  static TFC_Event getOnItemOfTypeCreatedOrDestroyedEvent(
      String nameOfItemType) {
    if (!_onItemOfTypeCreatedOrDestroyed.containsKey(nameOfItemType) ||
        _onItemOfTypeCreatedOrDestroyed[nameOfItemType] == null) {
      _onItemOfTypeCreatedOrDestroyed[nameOfItemType] = TFC_Event();
    }
    return _onItemOfTypeCreatedOrDestroyed[nameOfItemType];
  }

  static void saveItem(String itemID) {
    if (_itemInstances.containsKey(itemID)) {
      String fileName = TFC_ItemUtilities.generateFileName(itemID);
      String encodedJson = jsonEncode(_itemInstances[itemID]);
      TFC_DiskController.writeFileAsString(fileName, encodedJson);
    }
  }

  static void deleteItem(String itemID, {bool shouldLogDeletion = true}) {
    String fileName = TFC_ItemUtilities.generateFileName(itemID);
    String itemType =
        jsonDecode(TFC_DiskController.readFileAsString(fileName))["itemType"];
    unloadItemInstance(itemID);
    if (TFC_DiskController.fileExists(fileName)) {
      TFC_DiskController.deleteFile(fileName);
    }
    /*if (shouldLogDeletion) {
      TFC_SyncController.logItemDeleteion(itemID, itemType);
    }*/
    // Do this after we log the item deletion
    if (_onItemOfTypeCreatedOrDestroyed.containsKey(itemType)) {
      _onItemOfTypeCreatedOrDestroyed[itemType].trigger();
    }
  }

  static void addOnBeforeGetListener(
      String itemID, String attributeKey, void Function() listener) {
    if (_itemInstances.containsKey(itemID) &&
        _itemInstances[itemID].containsKey(attributeKey)) {
      _onBeforeAttributeGetsByItemID[itemID][attributeKey]
          .addListener(listener);
    }
  }

  static void removeOnBeforeGetListener(
      String itemID, String attributeKey, void Function() listener) {
    if (_itemInstances.containsKey(itemID) &&
        _itemInstances[itemID].containsKey(attributeKey)) {
      _onBeforeAttributeGetsByItemID[itemID][attributeKey]
          .removeListener(listener);
    }
  }

  static void addOnAfterSetListener(
      String itemID, String attributeKey, void Function() listener) {
    if (_itemInstances.containsKey(itemID) &&
        _itemInstances[itemID].containsKey(attributeKey)) {
      _onAfterAttributeSetsByItemID[itemID][attributeKey].addListener(listener);
    }
  }

  static void removeOnAfterSetListener(
      String itemID, String attributeKey, void Function() listener) {
    if (_itemInstances.containsKey(itemID) &&
        _itemInstances[itemID].containsKey(attributeKey)) {
      _onAfterAttributeSetsByItemID[itemID][attributeKey]
          .removeListener(listener);
    }
  }

  static dynamic getAttributeValue(String itemID, String itemType,
      String attributeKey, dynamic defaultValue) {
    if (!_itemInstances.containsKey(itemID)) {
      if (TFC_ItemUtilities.itemExists(itemID)) {
        loadItemInstance(itemID);
      } else {
        if (defaultValue is List || defaultValue is Set) {
          return TFC_SerializingSet.fromJson(
            onSet: () {},
            json: defaultValue as List<dynamic>,
          );
        } else {
          return defaultValue;
        }
      }
    }

    if (!_itemInstances[itemID].containsKey(attributeKey) ||
        _itemInstances[itemID][attributeKey] == null) {
      if (defaultValue is List || defaultValue is Set) {
        _itemInstances[itemID][attributeKey] =
            _createSerializingSetForItemInstances(
                itemID, itemType, attributeKey, defaultValue as List<dynamic>);
      } else {
        _itemInstances[itemID][attributeKey] = defaultValue;
      }
      _onAfterAttributeSetsByItemID[itemID][attributeKey] = TFC_Event();
      _onBeforeAttributeGetsByItemID[itemID][attributeKey] = TFC_Event();
      _onAfterAttributeSetsByItemID[itemID][attributeKey].addListener(() {
        saveItem(itemID);
      });
    }

    _onBeforeAttributeGetsByItemID[itemID][attributeKey].trigger();
    return _itemInstances[itemID][attributeKey];
  }

  static void setAttributeValue(String itemID, String nameOfItemType,
      String attributeKey, dynamic newValue,
      {bool shouldLogChange = true, bool shouldNotifyListeners = true}) {
    if (!_itemInstances.containsKey(itemID)) {
      if (TFC_ItemUtilities.itemExists(itemID)) {
        loadItemInstance(itemID);
      } else {
        /* If the item has been delted, then don't worry about setting any of it's attribtues' values. */
        return;
      }
    }
    if (_itemInstances.containsKey(itemID)) {
      if (!_itemInstances[itemID].containsKey(attributeKey)) {
        _itemInstances[itemID][attributeKey] = newValue;
        _onAfterAttributeSetsByItemID[itemID][attributeKey] = TFC_Event();
        _onBeforeAttributeGetsByItemID[itemID][attributeKey] = TFC_Event();
        _onAfterAttributeSetsByItemID[itemID][attributeKey].addListener(() {
          saveItem(itemID);
        });
        /*if (shouldLogChange) {
          TFC_SyncController.logAttributeChange(itemID, nameOfItemType,
              attributeKey, _itemInstances[itemID][attributeKey]);
        }*/
        if (shouldNotifyListeners) {
          _onAfterAttributeSetsByItemID[itemID][attributeKey].trigger();
        }
      } else if (_itemInstances[itemID][attributeKey] != newValue) {
        _itemInstances[itemID][attributeKey] = newValue;
        /*if (shouldLogChange) {
          TFC_SyncController.logAttributeChange(itemID, nameOfItemType,
              attributeKey, _itemInstances[itemID][attributeKey]);
        }*/
        if (shouldNotifyListeners) {
          _onAfterAttributeSetsByItemID[itemID][attributeKey].trigger();
        }
      }
    }
  }

  static List<String> getLocalItemIDsFromItemType(String nameOfItemType) {
    List<String> localItemIDsForItemType = [];

    // Get the name of every item file in the app directory
    List<String> allItemFileNames =
        TFC_DiskController.getLocalFileNamesFromFileExtension(".itm");

    // Pick out the files that belong to customer files and extract their itemIDs
    for (String fileName in allItemFileNames) {
      String defaultItemIDForItemOfThisType =
          TFC_ItemUtilities.getDefaultItemIDForItemType(nameOfItemType);
      String defaultItemFileNameForItemOfThisType =
          TFC_ItemUtilities.generateFileName(defaultItemIDForItemOfThisType);
      if (fileName.startsWith("$nameOfItemType-") &&
          fileName != defaultItemFileNameForItemOfThisType) {
        String itemID = fileName.substring(
            0, fileName.length - TFC_ItemUtilities.FILE_EXTENTION.length);
        localItemIDsForItemType.add(itemID);
      }
    }

    return localItemIDsForItemType;
  }
}
