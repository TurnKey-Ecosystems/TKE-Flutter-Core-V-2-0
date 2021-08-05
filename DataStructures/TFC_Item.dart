import 'TFC_SyncLevel.dart';
import 'package:tuple/tuple.dart';
import 'TFC_AllItemsManager.dart';
import 'TFC_SingleItemManager.dart';
import '../Utilities/TFC_Event.dart';
import 'package:flutter/foundation.dart';
import 'Attributes/TFC_Attribute.dart';


// Acts a a control pannel for an item instance
@immutable
abstract class TFC_Item {
  // We can't require subtypes to provide an itemType, so this is the best we can do.
  String get itemType;


  // The instnace of this item
  late final TFC_SingleItemManager _itemManager;


  // Expose the itemID for getting
  String get itemID {
    return _itemManager.itemID;
  }


  // Expose the onDelete event for listeners
  TFC_Event get onDelete {
    return _itemManager.onDelete;
  }
  

  // Item subtypes should override this
  @protected
  List<TFC_Attribute> getAllAttributes();


  // Creates a new item
  TFC_Item.createNew() {
    // Get the create new value of each attribute
    Map<String, Tuple2<TFC_SyncLevel, dynamic>> initialAttributeValues = {};
    for (TFC_Attribute attribute in getAllAttributes()) {
      initialAttributeValues[attribute.attributeKey] =
        Tuple2(attribute.syncLevel, attribute.valueOnCreateNew);
    }

    // Create a new item
    _itemManager = TFC_AllItemsManager.createNewItem(
      itemType: itemType,
      initialAttributeValues: initialAttributeValues,
      changeSource: TFC_ChangeSource.DEVICE,
    );

    // Now connect the attributes to their attribute instances on the new item
    _connectAttributesToAttributeInstances();
  }


  // Creates a new item control pannel for the item with the given itemID.
  TFC_Item.fromItemID(String givenItemID) {
    _itemManager = TFC_AllItemsManager.getItemInstance(givenItemID);
    _connectAttributesToAttributeInstances();
  }


  // Give each of the attributes their attribute instance
  void _connectAttributesToAttributeInstances() {
    // Make sure all session attributes have associated instances
    Map<String, dynamic> initialSessionAttributeValues = {};
    for (TFC_Attribute attribute in getAllAttributes()) {
      if (attribute.syncLevel == TFC_SyncLevel.SESSION) {
        initialSessionAttributeValues[attribute.attributeKey] =
          attribute.valueOnCreateNew;
      }
    }
    TFC_AllItemsManager.getItemInstance(itemID)
      .ensureSessionAttributesHaveBeenInitialized(initialSessionAttributeValues);

    // Setup all the attributes
    for (TFC_Attribute attribute in getAllAttributes()) {
      attribute.injectSetupDataFromItemInstance(
        attributeInstance:
          TFC_AllItemsManager.getItemInstance(itemID)
            .getAttributesAtSyncLevel(attribute.syncLevel)[attribute.attributeKey]!,
      );
    }
  }


  // Allow devs to delete this item
  @mustCallSuper
  void delete() {
    TFC_AllItemsManager.deleteItem(
      itemID: itemID,
      changeSource: TFC_ChangeSource.DEVICE,
    );
  }


  // Items are identified by their itemID
  @override
  int get hashCode => itemID.hashCode;

  // Items are identified by their itemID
  @override
  bool operator ==(dynamic other) {
    return other is TFC_Item && other.itemID == itemID;
  }
}
