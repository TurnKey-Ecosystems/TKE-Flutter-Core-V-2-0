import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:tke_dev_time_tracker_flutter_tryw/TKE-Flutter-Core/AppManagment/TFC_DiskController.dart';

import '../AppManagment/TFC_FlutterApp.dart';
import '../Serialization/TFC_AutoSaving.dart';
import '../Utilities/TFC_Event.dart';
import 'TFC_SingleItemManager.dart';
import 'package:tuple/tuple.dart';
import 'TFC_SyncLevel.dart';


/* Item changes made by this device are handled slightly differently than item
 * changes recieved form the cloud. */
enum TFC_ChangeSource { DEVICE, CLOUD }


// Manages all item instances, only touch this if you know what you are doing.
abstract class TFC_AllItemsManager {
  // Item Constants
  static const String FILE_EXTENTION = ".itm";
  static const String ITEM_ID_DIVIDER = "-";
  static const String ITEM_TYPE_KEY = "itemType";
  static const String ITEM_ID_KEY = "itemID";


  // Item Instances
  static Map<String, TFC_SingleItemManager> _itemInstances = Map();


  // The itemIDs belonging to each itemType
  static Map<String, Set<String>> _itemIDsForEachItemType = {};


  // Gets the itemIDs belonging to the given itemType
  static Set<String> getItemIdsForItemType(String itemType) {
    if (_itemIDsForEachItemType[itemType] == null) {
      return {};
    } else {
      return Set.from(_itemIDsForEachItemType[itemType]!);
    }
  }


  // Return the instance of the requested item
  static TFC_SingleItemManager getItemInstance(String itemID) {
    return _itemInstances[itemID]!;
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
    List<String> itemFileNames = TFC_DiskController.getLocalFileNamesFromFileExtension(FILE_EXTENTION);
    debugPrint(jsonEncode(itemFileNames));
    for (String itemFileName in itemFileNames) {
      // Load the item instance
      TFC_SingleItemManager itemInstance = TFC_SingleItemManager.fromFile(
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


  // Create a new item for the given item type
  static TFC_SingleItemManager createNewItem({
    required String itemType,
    required Map<String, Tuple2<TFC_SyncLevel, dynamic>> initialAttributeValues,
    required TFC_ChangeSource changeSource,
  }) {
    // Generate a new itemID
    TFC_AutoSavingProperty nextItemIndex = TFC_AutoSavingProperty(0, "next"+ itemType + "ItemIDIndex");
    String itemID =
      itemType
      + ITEM_ID_DIVIDER
      + TFC_FlutterApp.deviceID.value
      + ITEM_ID_DIVIDER
      + nextItemIndex.value.toString().padLeft(10, "0");
    nextItemIndex.value++;

    // Create the item instance
    TFC_SingleItemManager itemInstance = TFC_SingleItemManager.createNewItem(
      itemType: itemType,
      itemID: itemID,
      initialAttributeValues: initialAttributeValues,
      changeSource: changeSource,
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
    getOnItemOfTypeCreatedOrDestroyedEvent(itemType: itemType).trigger();

    // Return the manger of the newly created item.
    return _itemInstances[itemInstance.itemID]!;
  }


  // Deletes the given item
  static void deleteItem({
    required String itemID,
    required TFC_ChangeSource changeSource,
  }) {
    // Record this item's item type
    String itemType = _itemInstances[itemID]!.itemType;

    // Delete this item
    _itemInstances[itemID]!.deleteItem(changeSource: changeSource);

    // Remove the item instance from list of item instances
    _itemInstances.remove(itemID);

    // Remove this item's itemID form the list of itemIDs of items of its type
    if (_itemIDsForEachItemType.containsKey(itemType)) {
      _itemIDsForEachItemType[itemType]!.remove(itemID);
    }

    // Trigger the item type deletion event
    getOnItemOfTypeCreatedOrDestroyedEvent(itemType: itemType).trigger();
  }
}